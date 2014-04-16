#!/usr/env/perl
use 5.014;
use strict;
use warnings;
use Test::More;

use Bio::SeqWare::File::Table;
use File::Spec;
use File::Temp;
use Test::File::Contents;

plan tests => 8;

my $CLASS = "Bio::SeqWare::File::Table";
my $TEST_DATA_DIR = File::Spec->catdir( 't', 'data' );
my $SIMPLE_TABLE_FILE = File::Spec->catfile( "$TEST_DATA_DIR", "simple.tsv" );

# Load file as new object
{
    my $obj;
    eval {
        $obj = $CLASS->new( $SIMPLE_TABLE_FILE );
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
    my $obj = $CLASS->new( $SIMPLE_TABLE_FILE );
    {
        my $test = "Correct file name can be retrieved.";
        my $got = $obj->getFileName();
        my $want = $SIMPLE_TABLE_FILE;
        is( $got, $want, $test)
    }
}

# Object has correct header
{
    my $obj = $CLASS->new( $SIMPLE_TABLE_FILE );
    {
        my $test = "Correct header can be retrieved.";
        my $got = $obj->getHeaderLine();
        my $want = "A_Column\tB_Column\tC_Column";
        is( $got, $want, $test)
    }
}

# Object has correct data
{
    my $obj = $CLASS->new( $SIMPLE_TABLE_FILE );
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

# Write file - identical to original
{
     my $obj = $CLASS->new( $SIMPLE_TABLE_FILE );
     my $dir = File::Temp->newdir();
     my $fh  = File::Temp->new( DIR => $dir );
     my $outFileName = $fh->filename();

     # Ensure file does not exist.
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
        ok( -s $SIMPLE_TABLE_FILE > 0, $test);
     }
     {
       my $test = "File written is identical to file read.";
       files_eq_or_diff( $SIMPLE_TABLE_FILE, $outFileName, $test );
     }

     # Cleanup dir
     undef $dir;

}