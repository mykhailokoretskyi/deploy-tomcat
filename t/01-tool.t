#!perl
use 5.006;
use strict;
use lib ("t/mock/lib/");
use warnings;
use Class::Inspector;
use Test::Deep;
use Test::More;
use Test::Output;
use Test::Exception;
use MockFactory qw( DeployTool::Service::Tomcat );

use DeployTool;

my $time = time(); #used as a value for writing configs
my $notwritable_file = ".";
my $writable_file = "t/mock/writable.cfg";
`touch $writable_file`;
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
    sub { DeployTool->_read_config(config => $time) },
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

*DeployTool::_write_config = $original_write_config;

# start
is(DeployTool->start(start => 1, status => 1), 1, "App started");

throws_ok(
    sub { DeployTool->start(start => 0, status => 0); },
    qr/FAILED/,
    "App started but not accessible"
);

# stop
is(DeployTool->stop(stop => 1, status => 0), 1, "App stopped");

throws_ok(
    sub {DeployTool->stop(stop => 1, status => 1)},
    qr/FAILED/,
    "App stopped but still accessible"
);

# deploy
is(DeployTool->deploy(deploy => 1, status => 1), 1, "Deployed and accessible");
throws_ok(
    sub {DeployTool->deploy(deploy => 1, status => 0)},
    qr/FAILED/,
    "App deployed but not accessible"
);

throws_ok(
    sub {DeployTool->deploy(deploy => 0)},
    qr/1/,
    "App failed to deploy"
);

# undeploy
stdout_like(sub { DeployTool->undeploy(undeploy => 1) }, qr/SUCCESS/, "undeployed writes OK");
stdout_like(sub { DeployTool->undeploy(undeploy => 0) }, qr/FAILED/, "undeployed writes FAILED");

# status
stdout_like( sub { DeployTool->status(status => 1) }, qr/\nRUNNING/, "App is running");
stdout_like( sub { DeployTool->status(status => 0) }, qr/NOT RUNNING/, "App is not running");

# _run_cmd

lives_ok(
    sub { DeployTool->_run_cmd("status", hostname => "localhost", path => "/app") },
    "Run cmd passing config check"
);

lives_ok(
    sub { DeployTool->_run_cmd("status", hostname => "localhost", path => "/app", status => 1) },
    "Run cmd passing additional params"
);

throws_ok(
    sub { DeployTool->_run_cmd("status", hostname => "localhost", status => 1) },
    qr/^HELP/,
    "Dies when fails config check"
);

done_testing();
unlink $writable_file;
