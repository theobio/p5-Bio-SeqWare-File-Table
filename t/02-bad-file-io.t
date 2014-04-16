#!/usr/env/perl
use 5.014;
use strict;
use warnings;
use Test::More;

use Bio::SeqWare::File::Table;
use File::Spec;
use Carp;
use Test::MockModule;   # Fake methods for "used" package modules.

plan tests => 6;

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
            like( $got, qr/^\Q$want\E/m, $test);
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

# Use mock object to fake errors reading from file.
{
    my $ioFile = Test::MockModule->new('IO::File');
    my $errorString = "Error but no IO error.";
    $ioFile->mock(
        new => sub {
           $! = undef;
           croak( $errorString );
        }
    );
    eval {
        my $obj = $CLASS->new( $SIMPLE_TABLE_FILE );
    };
    my $error = $@;
    {
        my $test = 'Error reading without IO error';
        my $got = $error;
        my $want = sprintf( $ERR->{'io.open.file.read'}, "$SIMPLE_TABLE_FILE", $errorString );
        like( $got, qr/^\Q$want\E/, $test);
    }
}

# Check errors generated on bad filename when writing file.
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
            my $want = sprintf( $ERR->{'param.undefined'}, "\$outFileName", "write",  );
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
