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

=cut

=head1 Class Methods

=cut

=head2 new()

    my $tableObj = Bio::SeqWare::File::Table->new( $fileName, $paramHR);

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
    eval {
        $inFH = IO::File->new("< $fileName");
    };
    my $error = $@;
    my $ioError = $!;
    if ($error || ! $inFH) {
        if ($ioError && $error) {
           $error .= "\n\t" . $ioError;
        }
        if(! $error) {
            $error = "Unknown error";
        }
        croak( sprintf( ERR()->{'io.open.file.read'}, $fileName, $error));
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
    $self->{'raw'} = \@rows;

    bless $self, $class;
    return $self;
}

=head1 Object Methods

=cut

=head2 getFileName()

    my $fileName = $tableObj->getFileName();
    
Returns the name of the file as read in. May be a relative file path.

=cut

sub getFileName {
    my $self = shift;
    return $self->{'fileName'};
}

=head2 getHeaderLine()

    my $headerLine = $tableObj->getHeaderLine();

Returns the unparsed header line, without any terminal EOL.

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

=cut

sub getDataLines {
    my $self = shift;
    my @data;
    for my $dataPos (@{$self->{'index'}->{'DATA'}}) {
        push @data, $self->{'raw'}->[$dataPos];
    }
    return \@data;
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
