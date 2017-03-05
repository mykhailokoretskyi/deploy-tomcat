#!perl
use 5.006;
use strict;
use warnings;
use Class::Inspector;
use Test::Deep;
use Test::More;
use Test::Exception;

use DeployTool;

my $time = time(); #used as a value for writing configs
my $notwritable_file = "t/mock/notwritable.cfg";
my $writable_file = "t/mock/writable.cfg";
my $commands = Class::Inspector->methods( 'DeployTool', 'full', 'public' );
cmp_deeply(
    [
        'DeployTool::config',
        'DeployTool::deploy',
        'DeployTool::help',
        'DeployTool::start',
        'DeployTool::status',
        'DeployTool::stop',
        'DeployTool::undeploy'
    ],
    $commands,
    "Commands verification"
);

# help
throws_ok(
    sub { DeployTool->help(); },
    qr/^HELP/,
    "Help throws"
);

# _write_config
throws_ok(
    sub { DeployTool->_write_config($notwritable_file, {config => "failed"}) },
    qr/cannot open file for writing:/,
    "_write_config throws cannot open file for writing"
);

lives_ok( sub { DeployTool->_write_config($writable_file, {time => $time}) }, "writes config" );

# _read_config
throws_ok(
    sub { DeployTool->_read_config(config => $notwritable_file) },
    qr/^cannot open file/,
    "_read_config throws if cannot open file"
);

my $config = DeployTool->_read_config(
    config => $writable_file
);

my $config_cmp = {
    time => $time,
    config_data => {
        time => $time,
    },
    config => $writable_file,
};

cmp_deeply($config, $config_cmp, "_read_config gets config");

#########################
### Commands
#########################

# config
my $original_write_config = \&DeployTool::_write_config;
my $current_file;
my $test = "test";

*DeployTool::_write_config = sub {
    my ($class, $file, $config) = @_;
    is($file, $current_file, "Config is written in correct file");
    is($config->{test}, $test, "Config has test value");
    is(exists $config->{config}, '', "config key is removed from config");
    is(exists $config->{config_data}, '', "config_data key is removed from config");
};
$current_file = "some.txt";
DeployTool->config(
    config => $current_file,
    test => $test,
);

$current_file = DeployTool::_DEFAULT_CONFIG_FILE();
DeployTool->config(test => $test);

done_testing();
