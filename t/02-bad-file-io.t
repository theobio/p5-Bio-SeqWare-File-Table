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
my $ERR = ${CLASS}->ERR();

# Check errors generated on bad filename when loading file.
{
    # No parameters
    {
        my $obj;
        eval {
            $obj = $CLASS->new();
        };
        my $error = $@;
        {
            my $test = 'Missing $filename error without parameters?';
            my $got = $error;
            my $want = sprintf( $ERR->{'param.undefined'}, "\$fileName", "new",  );
            like( $got, qr/^\Q$want\E/, $test);
        }
    }

    # $fileName errors
    {
        my $obj;
        my $fileName = "n0SUchfil3Nam3Ih0pe";
        {
            my $test = 'Ensure bad filename is really bad';
            my $found = (-f $fileName);
            ok( ! $found, $test);
        }

        eval {
            $obj = $CLASS->new( $fileName );
        };
        my $error = $@;
        {
            my $test = 'Error if $fileName not found?';
            my $got = $error;
            my $want = sprintf( $ERR->{'io.noSuchFile'}, $fileName );
            like( $got, qr/^\Q$want\E/, $test);
        }
    }

}

