# NAME

Bio::SeqWare::File::Table - Data representation as a table, including file IO.

# VERSION

Version 0.000.002

# SYNOPSIS

    use Bio::SeqWare::File::Table;

    my $tableObj = Bio::SeqWare::File::Table->new( $fileName, $paranHR );

    my $fileName     = $tableObj->getFileName();
    my $headerLine   = $tableObj->getHeaderLine();
    my $dataLinesAR  = $tableObj->getDataLines();

# Class Methods

## new( $fileName )

    my $tableObj = Bio::SeqWare::File::Table->new( $fileName );

Loads data from the specified tab-delimited file. File format must match as
specified under FILE above.

    PARAM: $fileName
      Required. The file to read, as a full path or relative to current dir.
    RETURNS: A Bio::SeqWare::File::Table object containing the data from the
       specified file.
    ERRORS: $fileName parameter is required and must be readable.

# Object Methods

## getFileName()

    my $fileName = $tableObj->getFileName();

Returns the name of the file as read in. May be a relative file path.

    PARAM: N/A
    RETURNS: The file path as originally specified.
    ERRORS: N/A

## getHeaderLine()

    my $headerLine = $tableObj->getHeaderLine();

Returns the unparsed header line, without any terminal EOL.

    PARAM: N/A
    RETURNS: The header line from the file, unparsed.
    ERRORS: N/A

## getDataLines()

    my $headerLinesAR = $tableObj->getDataLines();

Returns the unparsed data lines, without any terminal EOL, as an array ref.
Lines are returned in the original order.

    PARAM: N/A
    RETURNS: The data lines from the file, as an array-ref, unparsed.
    ERRORS: N/A

## getRawData()

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

## write( $outFileName )

    $tableObj->write( $outFileName );

Writes out an identical copy of the original file. This is fairly expensive to
do and requires storing extra information soley for the purpose of outputting
an exact copy (e.g.. leading and trailing blanks on fields). By default this
information is NOT preserved, and calling this will generate a warning and
instead perform a default export( $outFileName ). To allow generating an
actual exact copy, must set the "duplicate" parameter to true when first
reading the file - see new( $outFileName \[$paramHR\] ).

    PARAM:   $outFileName
      Required. The file to write, as a full path or relative to current dir.
    RETURNS: N/A
    ERRORS:  $outFileName must be a valid file name and may not already exist.
             Writing to $outFileName must succeed.

## export( $outFileName )

    $tableObj->export( $fileName );

Write a copy of the file as the specified $outFileName, in canonical format.

That means: Adding a terminal EOL if none.

    PARAM:   N/A
    RETURNS: N/A
    ERRORS:  The $outFileName must be a valid file name and may not pre-exist.
       Writing the file must succeed.

# Internal Methods

## getInFH( $fileName )

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

## getOutFH( $fileName )

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

## ERR() {

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

# AUTHOR

Stuart R. Jefferys, `<srjefferys (at) gmail (dot) com>`

# CONTRIBUTING

This module is developed and hosted on GitHub, at
[p5-Bio-SeqWare-File-Table ](https://metacpan.org/pod/&#x20;
https:#github.com-theobio-p5-Bio-SeqWare-File-Table). It
is not currently on CPAN, and I don't have any immediate plans to post it
there unless requested by core SeqWare developers (It is not my place to
set out a module name hierarchy for the project as a whole :)

# INSTALLATION

You can install a version of this module directly from github using

      $ cpanm git://github.com/theobio/p5-Bio-SeqWare-File-Table.git@v0.000.002
    or
      $ cpanm https://github.com/theobio/p5-Bio-SeqWare-File-Table/archive/v0.000.002.tar.gz

Any version can be specified by modifying the tag name, following the @;
the above installs the latest _released_ version. If you leave off the @version
part of the link, you can install the bleading edge pre-release, if you don't
care about bugs...

You can select and download any package for any released version of this module
directly from [https://github.com/theobio/p5-Bio-SeqWare-File-Table/releases](https://github.com/theobio/p5-Bio-SeqWare-File-Table/releases).
Installing is then a matter of unzipping it, changing into the unzipped
directory, and then executing the normal (C>Module::Build>) incantation:

     perl Build.PL
     ./Build
     ./Build test
     ./Build install

# BUGS AND SUPPORT

No known bugs are present in this release. Unknown bugs are a virtual
certainty. Please report bugs (and feature requests) though the
Github issue tracker associated with the development repository, at:

[https://github.com/theobio/p5-Bio-SeqWare-File-Table/issues](https://github.com/theobio/p5-Bio-SeqWare-File-Table/issues)

Note: you must have a GitHub account to submit issues.

# ACKNOWLEDGEMENTS

This module was developed for use with [SegWare ](https://metacpan.org/pod/&#x20;http:#seqware.github.io)
at the University of North Carolina - Chapel Hill.

# LICENSE AND COPYRIGHT

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
