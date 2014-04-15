#!/usr/env/perl
use 5.014;
use strict;
use warnings;
use Test::More;

use Bio::SeqWare::File::Table;
use File::Spec;

plan tests => 5;

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
