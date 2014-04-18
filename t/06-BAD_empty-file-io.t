#!/usr/env/perl
use 5.014;
use strict;
use warnings;
use Test::More;

use Bio::SeqWare::File::Table;
use File::Spec;
use Carp;

plan tests => 2;

my $CLASS = "Bio::SeqWare::File::Table";
my $TEST_DATA_DIR = File::Spec->catdir( 't', 'data' );
my $ERR = ${CLASS}->ERR();
my $EMPTY_TABLE_FILE = File::Spec->catfile( "$TEST_DATA_DIR", "BAD_empty.tsv" );
{
    my $test = 'Ensure empty filename is really empty';
    my $isEmpty = -s $EMPTY_TABLE_FILE == 0;
    ok( $isEmpty, $test);
}

# Handle empty file
{
    my $obj;
    eval {
        $obj = $CLASS->new($EMPTY_TABLE_FILE);
    };
    my $error = $@;
    {
        my $test = 'Error if input file is empty?';
        my $got = $error;
        my $want = sprintf( $ERR->{'in.file.empty'}, "$EMPTY_TABLE_FILE" );
        like( $got, qr/^\Q$want\E/m, $test);
    }

}