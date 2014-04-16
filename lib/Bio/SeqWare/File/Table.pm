package Bio::SeqWare::File::Table;

use 5.014;      # Eval error handling unsafe before this.
use strict;
use warnings;

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

    # param $fileName
    if (! defined $fileName) {
        croak( sprintf( ERR()->{'param.undefined'}, "\$fileName",  "new" ));
    }
    if (! -f $fileName) {
        croak( sprintf( ERR()->{'io.noSuchFile'}, "$fileName" ));
    }

    # property 'fileName'
    my $self = {
        'fileName' => $fileName,
    };

    # Get file handle to read from.

    my $inFH;
    $! = undef;
    $inFH = IO::File->new("< $fileName");
    if (! $inFH) {
        croak( sprintf( ERR()->{'io.open.file.read'}, $fileName, $!));
    }

    # Load data

    my @rows;
    my $lineNum = 0;
    my $isFirstLine = 1;
    $self->{'index'}->{'DATA'} = [];
    while ( my $line = <$inFH> ) {
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
    # Close file
    undef $inFH;

    $self->{'raw'} = \@rows;

    bless $self, $class;
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
    my @data;
    for my $dataPos (@{$self->{'index'}->{'DATA'}}) {
        push @data, $self->{'raw'}->[$dataPos];
    }
    return \@data;
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
    my $outFileName = shift;

    # param $fileName
    if (! defined $outFileName) {
        croak( sprintf( ERR()->{'param.undefined'}, "\$outFileName",  "write" ));
    }
    if (-f $outFileName) {
        croak( sprintf( ERR()->{'io.open.file.create'}, "$outFileName" ));
    }

    # Get file handle to write to.

    my $outFH = IO::File->new("> $outFileName");
    if (! $outFH) {
         croak( sprintf( ERR()->{'io.file.write'}, $outFileName, $!));
    }

    for my $line (@{$self->{'raw'}}) {
        # Rewritten during coverage testing so error is true branch?
        # uncoverable branch true
        print( $outFH $line . "\n")
            or croak( sprintf( ERR()->{'io.file.write'}, $outFileName, $!)); 
    }

    undef $outFH;
}
=head1 Internal Methods

=cut

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
      "Paramter \"%s\" in call to \"%s\" is missing or undefined.";
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
