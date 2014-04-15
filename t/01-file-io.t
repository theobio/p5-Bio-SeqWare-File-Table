#!/usr/env/perl
use 5.014;
use strict;
use warnings;
use Test::More;

use Bio::SeqWare::File::Table;
use File::Spec;

plan tests => 3;

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

# Object has correct data