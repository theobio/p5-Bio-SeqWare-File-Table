#!/usr/env/perl
use 5.014;
use strict;
use warnings;
use Test::More;

use Bio::SeqWare::File::Table;
use File::Spec;

plan tests => 2;

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