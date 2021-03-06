#!/usr/env/perl
use 5.014;
use strict;
use warnings;
use Test::More;

use Bio::SeqWare::File::Table;
use File::Spec;
use File::Temp;
use Test::File::Contents;

plan tests => 13;

my $CLASS = "Bio::SeqWare::File::Table";
my $TEST_DATA_DIR = File::Spec->catdir( 't', 'data' );
my $ALT_EOL_TABLE_FILE = File::Spec->catfile( "$TEST_DATA_DIR", "altEOL.tsv" );

# Load file as new object
{
    my $obj;
    eval {
        $obj = $CLASS->new( $ALT_EOL_TABLE_FILE );
    };
    my $error = $@;
    {
        my $test = "No error creating new object from a simple table file.";
        ok( ! $error, $test);
    }
    {
        my $test = "Actually created a new object from a simple table file.";
        ok( $obj, $test);
    }
}

# Object has correct fileName
{
    my $obj = $CLASS->new( $ALT_EOL_TABLE_FILE );
    {
        my $test = "Correct file name can be retrieved.";
        my $got = $obj->getFileName();
        my $want = $ALT_EOL_TABLE_FILE;
        is( $got, $want, $test)
    }
}

# Object has correct header
{
    my $obj = $CLASS->new( $ALT_EOL_TABLE_FILE );
    {
        my $test = "Correct header can be retrieved.";
        my $got = $obj->getHeaderLine();
        my $want = "A_Column\tB_Column\tC_Column";
        is( $got, $want, $test)
    }
}

# Object has correct data
{
    my $obj = $CLASS->new( $ALT_EOL_TABLE_FILE );
    {
        my $test = "Correct data can be retrieved.";
        my $got = $obj->getDataLines();
        my $want = [
            "apple\tbanana\tcucumber",
            "Amy\tBob\tCarol",
            "antelope\tbee\tcat",
            "data for A\tdata for B\tdata for C",
        ];
        is_deeply( $got, $want, $test)
    }
}

# Object has correct raw data

{
    my $obj = $CLASS->new( $ALT_EOL_TABLE_FILE );
    {
        my $test = "Correct raw data can be retrieved.";
        my $got = $obj->getRawData();
        my $want = {
           'lines' => [
               "A_Column\tB_Column\tC_Column",
               "apple\tbanana\tcucumber",
               "Amy\tBob\tCarol",
               "antelope\tbee\tcat",
               "data for A\tdata for B\tdata for C",
           ],
           'fileName' => $ALT_EOL_TABLE_FILE,
           'terminalEOL' => 0,
           'structure' => ['HEADER', 'DATA', 'DATA', 'DATA', 'DATA'],
           'index' => {
                'header' => 0,
                'data' => [1,2,3,4]
           },
        };
        is_deeply( $got, $want, $test)
    }
}

# Write file - identical to original, alt EOL
{
     my $obj = $CLASS->new( $ALT_EOL_TABLE_FILE );
     my $dir = File::Temp->newdir();
     my $fh  = File::Temp->new( DIR => $dir );
     my $outFileName = $fh->filename();

     # Removes file.
     undef $fh;

     eval {
         $obj->write( $outFileName );
     };
     my $error = $@;
     {
        my $test = "No error writing new file from a simple table file.";
        my $got = $error;
        my $want = "";
        is( $got, $want, $test);
     }
     {
        my $test = "Output file exists and is not empty.";
        ok( -s $outFileName > 0, $test);
     }
     {
       my $test = "File written is identical to file read.";
       files_eq_or_diff( $ALT_EOL_TABLE_FILE, $outFileName, $test );
     }

     # Cleanup dir
     undef $dir;

}

# Test export by read-write-read cycle.
{
    # 1. Read file
    my $obj = $CLASS->new( $ALT_EOL_TABLE_FILE );

    # 2. Remeber original data
    my @originalRows;
    push @originalRows, $obj->getHeaderLine();
    push @originalRows, @{$obj->getDataLines()};

    # 3. Export file
    my $dir = File::Temp->newdir();
    my $fh  = File::Temp->new( DIR => $dir );
    my $outFileName = $fh->filename();

    # Deletes file.
    undef $fh;

    eval {
        $obj->export( $outFileName );
    };
    my $error = $@;
    {
       my $test = "No error writing new file from a simple table file.";
       my $got = $error;
       my $want = "";
       is( $got, $want, $test);
    }
    {
       my $test = "Output file exists and is not empty.";
       ok( -s $outFileName > 0, $test);
    }

    # 4. Read exported file.
    my $newTable = $CLASS->new( $outFileName );

    # 5. Get data from new file.
    my @newRows;
    push @newRows, $newTable->getHeaderLine();
    push @newRows, @{$newTable->getDataLines()};

    # 6. Verify same.
    {
        my $test = "Export has expected number of lines.";
        my $got = scalar @newRows;
        my $want = 5;
        is( $got, $want, $test);
    }
    {
        my $test = "Export has same rows as original.";
        is_deeply( \@originalRows, \@newRows, $test);
    }

    undef $dir;
}
