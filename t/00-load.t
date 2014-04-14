#!perl -T
use 5.014;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Bio::SeqWare::File::Table' ) || print "Bail out!\n";
}

diag( "Testing Bio::SeqWare::File::Table $Bio::SeqWare::File::Table::VERSION, Perl $], $^X" );
