use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME             => 'DeployTool',
    AUTHOR           => q{Mykhailo Koretskyi <radio.mkor@gmail.com>},
    VERSION_FROM     => 'lib/DeployTool.pm',
    #ABSTRACT_FROM    => 'lib/DeployTool.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
        'Test::Exception' => 0,
        'Test::DeepMock' => 0,
    },
    TEST_REQUIRES => {
        'Test::More' => 0,
        'Test::Exception' => 0,
        'Test::DeepMock' => 0,
    },
    PREREQ_PM => {
    },
    EXE_FILES => [ qw( bin/deploy-tool ) ],
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'DeployTool-*' },
);
