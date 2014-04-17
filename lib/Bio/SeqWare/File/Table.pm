package Bio::SeqWare::File::Table;

use 5.014;      # Eval error handling unsafe before this.
use strict;
use warnings;
use Data::Dumper;
use Carp;       # Adds caller-relative error handling.
use IO::File;   # File handles done better.

=head1 NAME

Bio::SeqWare::File::Table - Data representation as a table, including file IO.

=cut

=head1 VERSION

Version 0.000.001

=cut

our $VERSION = '0.000001';

=head1 SYNOPSIS

    use Bio::SeqWare::File::Table;

    my $tableObj = Bio::SeqWare::File::Table->new( $fileName, $paranHR );

    my $fileName     = $tableObj->getFileName();
    my $headerLine   = $tableObj->getHeaderLine();
    my $dataLinesAR  = $tableObj->getDataLines();

=cut

=head1 Class Methods

=cut

=head2 new( $fileName )

    my $tableObj = Bio::SeqWare::File::Table->new( $fileName );

Loads data from the specified tab-delimited file. File format must match as
specified under FILE above.

   PARAM: $fileName
     Required. The file to read, as a full path or relative to current dir.
   RETURNS: A Bio::SeqWare::File::Table object containing the data from the
      specified file.
   ERRORS: $fileName parameter is required and must be readable.

=cut

sub new {
    my $class = shift;
    my $fileName = shift;

    my $self = {};
    $self = bless $self, $class;

    my $inFH = $self->getInFH( $fileName );
    $self->{'fileName'} = $fileName;

    # Load data

    my @rows;
    my $lineNum = 0;
    my $isFirstLine = 1;
    $self->{'index'}->{'DATA'} = [];
    my $lastLine;
    while ( my $line = <$inFH> ) {
        $lastLine = $line;
        chomp $line;
        push @rows, $line;
        if ( $isFirstLine ) {
            $isFirstLine = 0;
            $self->{'index'}->{'HEADER'} = $lineNum;
        }
        else {
            push @{$self->{'index'}->{'DATA'}}, $lineNum;
        }
        ++$lineNum;
    }
    if ($isFirstLine) {
        croak( sprintf( ERR()->{'in.file.empty'}, $fileName ));
    }

    # Close file
    $inFH->close();

    $self->{'raw'} = \@rows;
    $self->{'terminalEOL'} = 0;
    if ( substr( $lastLine, -1 ) eq "\n") {
        $self->{'terminalEOL'} = 1;
    }

    return $self;
}

=head1 Object Methods

=cut

=head2 getFileName()

    my $fileName = $tableObj->getFileName();

Returns the name of the file as read in. May be a relative file path.

    PARAM: N/A
    RETURNS: The file path as originally specified.
    ERRORS: N/A

=cut

sub getFileName {
    my $self = shift;
    return $self->{'fileName'};
}

=head2 getHeaderLine()

    my $headerLine = $tableObj->getHeaderLine();

Returns the unparsed header line, without any terminal EOL.

    PARAM: N/A
    RETURNS: The header line from the file, unparsed.
    ERRORS: N/A

=cut

sub getHeaderLine {
    my $self = shift;
    my $headerPos = $self->{'index'}->{'HEADER'};
    return $self->{'raw'}->[$headerPos];
}

=head2 getDataLines()

    my $headerLinesAR = $tableObj->getDataLines();

Returns the unparsed data lines, without any terminal EOL, as an array ref.
Lines are returned in the original order.

    PARAM: N/A
    RETURNS: The data lines from the file, as an array-ref, unparsed.
    ERRORS: N/A

=cut

sub getDataLines {
    my $self = shift;
    my @data = ();
    for my $dataPos (@{$self->{'index'}->{'DATA'}}) {
        push @data, $self->{'raw'}->[$dataPos];
    }
    return \@data;
}

=head2 getRawData()

    my $dataHR = $tableObj->getRawData();

Returns a data structure that contains all the original rows and how they
were classified, including enough data to identically reproduce the original
file.

    PARAM: N/A
    RETURNS: Hash-ref. The record of the data as read in.
      $ret->{'fileName'} = The name of the file read in.
      $ret->{'terminalEOL} = True if original file has a terminal EOL on the
          last line.
      $ret->{'lines'} = Array-ref. The original data lines, without EOL.
      $ret->{'lines'}->[#] = The row from line # of the file read. From 0.
      $ret->{'structure'} = Array-ref. What type each data line is.
      $ret->{'structure'}->[#] = The structure of row #. Will be one of:
          'HEADER' or 'DATA'
      $ret->{'index'}->{'HEADER'} = The row containing the header.
      $ret->{'index'}->{'DATA'} = Array-ref. The row numbers that contain data.
      $ret->{'index'}->{'DATA'}->[#] = The #'th data row.
    ERRORS: N/A

=cut

sub getRawData() {
    my $self = shift;
    my $backHR;
    $backHR->{'fileName'} = $self->{'fileName'};
    $backHR->{'terminalEOL'} = $self->{'terminalEOL'};
    $backHR->{'lines'} = \@{$self->{'raw'}};
    $backHR->{'index'}->{'header'} = $self->{'index'}->{'HEADER'};
    $backHR->{'index'}->{'data'} = \@{$self->{'index'}->{'DATA'}};
    my $structureAR;
    $structureAR->[$self->{'index'}->{'HEADER'}] = 'HEADER';
    for my $dataPos (@{$self->{'index'}->{'DATA'}}) {
        $structureAR->[$dataPos] = 'DATA';
    }
    $backHR->{'structure'} = $structureAR;

    return $backHR;
}

=head2 write( $outFileName )

    $tableObj->write( $outFileName );

Writes out an identical copy of the original file. This is fairly expensive to
do and requires storing extra information soley for the purpose of outputting
an exact copy (e.g.. leading and trailing blanks on fields). By default this
information is NOT preserved, and calling this will generate a warning and
instead perform a default export( $outFileName ). To allow generating an
actual exact copy, must set the "duplicate" parameter to true when first
reading the file - see new( $outFileName [$paramHR] ).

   PARAM:   $outFileName
     Required. The file to write, as a full path or relative to current dir.
   RETURNS: N/A
   ERRORS:  $outFileName must be a valid file name and may not already exist.
            Writing to $outFileName must succeed.

=cut

sub write {
    my $self = shift;
    my $fileName = shift;

    # Checks $outFileName parameters.
    my $outFH = $self->getOutFH( $fileName );

    for ( my $pos = 0; $pos < scalar( @{$self->{'raw'}}) - 1; ++$pos) {

        # Stupid hard to mock print return values, so tagging to skip coverage
        # testing. Note: This code is rewritten during coverage testing so
        # error is the true branch.
        #
        # uncoverable branch true
        print( $outFH $self->{'raw'}->[$pos] . "\n")
            or croak( sprintf( ERR()->{'io.file.write'}, $fileName, $!)); 
    }
    my $lastEOL = "";
    if ($self->{'terminalEOL'}) {
        $lastEOL = "\n";
    }
    # uncoverable branch true
    print( $outFH $self->{'raw'}->[-1] . $lastEOL)
        or croak( sprintf( ERR()->{'io.file.write'}, $fileName, $!)); 

    $outFH->close();
}

=head2 export( $outFileName )

    $tableObj->export( $fileName );

Write a copy of the file as the specified $outFileName, in canonical format.

That means: Adding a terminal EOL if none.

    PARAM:   N/A
    RETURNS: N/A
    ERRORS:  The $outFileName must be a valid file name and may not pre-exist.
       Writing the file must succeed.

=cut

sub export{

    my $self = shift;
    my $fileName = shift;

    my $outFH = $self->getOutFH( $fileName );

    # Stupid hard to mock print return values, so tagging to skips coverage
    # testing. Note: This code is rewritten during coverage testing so
    # error is the true branch.
    #
    # uncoverable branch true
    print( $outFH $self->{'raw'}->[$self->{'index'}->{'HEADER'}] . "\n")
        or croak( sprintf( ERR()->{'io.file.write'}, $fileName, $!));

    for my $pos (@{$self->{'index'}->{'DATA'}}) {
        # uncoverable branch true
        print( $outFH $self->{'raw'}->[$pos] . "\n")
            or croak( sprintf( ERR()->{'io.file.write'}, $fileName, $!)); 
    }
    $outFH->close();
}

=head1 Internal Methods

=cut

=head2 getInFH( $fileName )

    my $inFH = $tableObj->getInFH( $fileName );
    #...
    $inFH->close();
      # or
    undef $inFH;

This checks to see if $fileName can be used as a file name and that it exists.
Then it returns the $inFH for use in reading from this file. The handle will
automatically be closed when it goes out of scope (including being explicitly
undefined.)

    PARAM: $fileName - The file to create for writting to (relative path ok.)
    RETURNS: A file handle open for writting.
    ERRORS: The $outFileName must be a valid file name and may not pre-exist.

=cut

sub getInFH {

    my $self = shift;
    my $fileName = shift;

    # param $fileName
    if (! defined $fileName) {
        croak( sprintf( ERR()->{'param.undefined'}, "\$fileName",  (caller(1))[3] ));
    }
    if (! -f $fileName) {
        croak( sprintf( ERR()->{'io.noSuchFile'}, "$fileName" ));
    }
    # Get file handle to read from.

    my $inFH;
    $! = undef;
    $inFH = IO::File->new("< $fileName");
    if (! $inFH) {
        croak( sprintf( ERR()->{'io.open.file.read'}, $fileName, $!));
    }

    return $inFH;
}


=head2 getOutFH( $fileName )

    my $outFH = $tableObj->getOutFH( $fileName );
    #...
    $inFH->close();
      # or
    undef $inFH;

This checks to see if $fileName can be used as a file name and that it does
not exist. Then it returns the $outFH for use. The handle will automatically be
closed when it goes out of scope (including being explicitly undefined.)

    PARAM: $fileName - The file to create for writting to (relative path ok.)
    RETURNS: A file handle open for writting.
    ERRORS: The $outFileName must be a valid file name and may not pre-exist.

=cut

sub getOutFH {

    my $self = shift;
    my $fileName = shift;

    # param $fileName
    if (! defined $fileName) {
        croak( sprintf( ERR()->{'param.undefined'}, "\$fileName",  (caller(1))[3] ));
    }
    if (-f $fileName) {
        croak( sprintf( ERR()->{'io.open.file.create'}, "$fileName" ));
    }

    # Get file handle to write to.

    my $outFH = IO::File->new("> $fileName");

    if (! $outFH) {
         croak( sprintf( ERR()->{'io.file.write'}, $fileName, $!));
    }

    return $outFH;
}

=head2 ERR() {

    Croak( sprintf( ERR()->{'io.noSuchFile'}, $fileName ));
    Croak( sprintf( ERR()->{'param.undefined'}, $paramName, $subName ));

    Provides error message hash-ref, messages looked up by heirarcichal name.
    Each message is intended for use as a sprintf string, with 0 or more "%s"
    place-holders. In all upper case as essentially just a wrapper for a
    constant set of named strings.

   Goal: Provide fixed-format error messages with variable data without using
   exception classes.

   Note: Spelling errors and incorrect base strings will not be caught by
   testing, although incorrect count or content of "%s" values probably will.

=cut

sub ERR {
   my $err;
   $err->{'param.undefined'} =
      "Parameter \"%s\" in call to \"%s\" is missing or undefined.";
   $err->{'param.empty'} =
      "Parameter \"%s\" in call to \"%s\" is empty.";
   $err->{'param.bad.type'} =
      "Parameter \"%s\" in call to \"%s\" should be of type \"%s\".";
   $err->{'io.noSuchFile'} =
      "No such file (perhaps a permissions issue?): \"%s\".";
   $err->{'io.open.file.read'} =
      "Error opening file for reading: \"%s\".\n\t%s";
   $err->{'io.open.file.create'} =
      "Error creating file - already exists: \"%s\".";
   $err->{'io.file.write'} =
      "Error writing to file: \"%s\".\n\t%s";
   $err->{'in.file.empty'} =
      "Error reading input file, file is empty: \"%s\".";
   return $err;
}

=head1 AUTHOR

Stuart R. Jefferys, C<< <srjefferys (at) gmail (dot) com> >>

=cut

=head1 BUGS

Please report any bugs or feature requests to C<bug-p5-bio-seqware-file-table at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=p5-Bio-SeqWare-File-Table>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=cut


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Bio::SeqWare::File::Table


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=p5-Bio-SeqWare-File-Table>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/p5-Bio-SeqWare-File-Table>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/p5-Bio-SeqWare-File-Table>

=item * Search CPAN

L<http://search.cpan.org/dist/p5-Bio-SeqWare-File-Table/>

=back

=cut

=head1 ACKNOWLEDGEMENTS

=cut

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Stuart R. Jefferys.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2 dated June, 1991 or at your option
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available in the source tree;
if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


=cut

1; # End of Bio::SeqWare::File::Table
