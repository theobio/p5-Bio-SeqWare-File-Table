#!/usr/env/perl
use 5.014;
use strict;
use warnings;
use Test::More;
use Data::Dumper;

use Bio::SeqWare::File::Table;
use File::Spec;
use Carp;
use IO::File;           # Only for getting a valid $! value.
use Test::MockModule;   # Fake methods for "used" package modules.

plan tests => 5;

my $CLASS = "Bio::SeqWare::File::Table";
my $TEST_DATA_DIR = File::Spec->catdir( 't', 'data' );
my $SIMPLE_TABLE_FILE = File::Spec->catfile( "$TEST_DATA_DIR", "simple.tsv" );
my $ERR = ${CLASS}->ERR();

# Set up bad filenames.
my $MISSING_FILENAME = "n0SUchfil3Nam3Ih0pe";
{
    my $test = 'Ensure bad filename is really bad';
    my $found = (-f $MISSING_FILENAME);
    ok( ! $found, $test);
}

# Check errors generated on bad filename when loading file.
# (Essentially this is checking getInFH)
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
            my $want = sprintf( $ERR->{'param.undefined'}, "\$fileName", "Bio::SeqWare::File::Table::new",  );
            like( $got, qr/^\Q$want\E/m, $test);
        }
    }

    # $fileName errors
    {
        my $obj;

        eval {
            $obj = $CLASS->new( $MISSING_FILENAME );
        };
        my $error = $@;
        {
            my $test = 'Error if $fileName not found?';
            my $got = $error;
            my $want = sprintf( $ERR->{'io.noSuchFile'}, $MISSING_FILENAME );
            like( $got, qr/^\Q$want\E/, $test);
        }
    }

}


# Check errors generated on bad filename when writing file.
# (Essentially this is checking getOutFH)
{
    # No parameters
    {
        my $obj = $CLASS->new( $SIMPLE_TABLE_FILE );
        eval {
            $obj->write();
        };
        my $error = $@;
        {
            my $test = 'Missing $filename error without parameters?';
            my $got = $error;
            my $want = sprintf( $ERR->{'param.undefined'}, "\$fileName", "Bio::SeqWare::File::Table::write",  );
            like( $got, qr/^\Q$want\E/, $test);
        }
    }

    # $fileName errors
    {
        my $obj = $CLASS->new( $SIMPLE_TABLE_FILE );
        eval {
            $obj->write( $SIMPLE_TABLE_FILE );
        };
        my $error = $@;
        {
            my $test = 'Error with write() when $filename pre-exists?';
            my $got = $error;
            my $want = sprintf( $ERR->{'io.open.file.create'}, $SIMPLE_TABLE_FILE );
            like( $got, qr/^\Q$want\E/, $test);
        }
    }
}

