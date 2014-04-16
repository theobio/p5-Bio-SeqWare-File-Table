use 5.014;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Bio::SeqWare::File::Table',
    license             => 'gpl',
    dist_author         => q{Stuart R. Jefferys <srjefferys (at) gmail (dot) com>},
    dist_version_from   => 'lib/Bio/SeqWare/File/Table.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
        'Test::MockObject' => 0,
    },
    requires => {
        'perl'=> '5.014',
    },
    add_to_cleanup     => [ 'p5-Bio-SeqWare-File-Table-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
