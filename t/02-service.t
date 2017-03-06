#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Output;
use Test::Exception;
use HTTP::Response;
use HTTP::Headers;
use HTTP::Request;

use lib ("t/mock/lib/");
use MockFactory qw(
    LWP::UserAgent
    HTTP::Request::Common
);

BEGIN {
    use_ok( 'DeployTool::Service::Tomcat' );
}

###########################
# PREDEFINED OBJECTS
###########################
my $headers = HTTP::Headers->new();
my $successful_response = HTTP::Response->new(200, "OK", $headers, "OK - something\n");
my $failed_response = HTTP::Response->new(200, "Ok", $headers, "FAIL - reason\n");

# _is_successful
is(DeployTool::Service::Tomcat->_is_successful($successful_response), 1, "successful request");
stderr_is(
    sub { is(DeployTool::Service::Tomcat->_is_successful($failed_response), 0, "successful request"); },
    "FAIL - reason\n",
    "writes reason to stderr",
);

# _get_base_url

my $args = [
    {
        hostname => "some",
        port => 1234,
        result_url => "http://some:1234",
    },
    {
        hostname => "some",
        port => 1234,
        ssl => 1,
        result_url => "https://some:1234",
    },
    {
        hostname => "some",
        port => 1234,
        ssl => 1,
        auth => 1,
        user => "user",
        password => "pass",
        result_url => "https://user:pass\@some:1234",
    }
];

foreach my $set (@$args) {
    is(DeployTool::Service::Tomcat->_get_base_url(%$set), $set->{result_url}, "Verification of base url");
}

# _handle_http_errors

my $response_500 = HTTP::Response->new(500);

lives_ok(
    sub { DeployTool::Service::Tomcat->_handle_http_errors($successful_response) },
    "2xx responses don`t die",
);
throws_ok(
    sub { DeployTool::Service::Tomcat->_handle_http_errors($response_500) },
    qr/Got bad response from Tomcat:/,
    "non 2xx responses die",
);

# _send_request

my $request = HTTP::Request->new();
$request->header( status => 500 );

is(DeployTool::Service::Tomcat->_send_request($request, 1)->code(), 500, "sends request skipping errors");
throws_ok(
    sub { DeployTool::Service::Tomcat->_send_request($request) },
    qr/Got bad response from Tomcat:/,
    "sends request and dies if not skip errors"
);

#####################
#  API
#####################
my $arguments;
*DeployTool::Service::Tomcat::_send_request = sub {
    cmp_deeply(\@_, $arguments, "API args verification");
    return $successful_response;
};

my %config = (
    user => "user",
    password => "pass",
    hostname => "localhost",
    port => 1234,
    path => "/app",
    war => "app.war",
);

# deploy
$arguments = [
    'DeployTool::Service::Tomcat',
    'http://user:pass@localhost:1234/manager/text/deploy?path=/app&update=false',
    'Content_Type',
    'form-data',
    'Content',
    [
        'war',
        [
            'app.war'
        ]
    ]
];
DeployTool::Service::Tomcat->deploy(%config);
$arguments = [
    'DeployTool::Service::Tomcat',
    'http://user:pass@localhost:1234/manager/text/deploy?path=/app&update=true',
    'Content_Type',
    'form-data',
    'Content',
    [
        'war',
        [
            'app.war'
        ]
    ]
];
DeployTool::Service::Tomcat->deploy(%config, update => 1);

# start

$arguments = [
    'DeployTool::Service::Tomcat',
    'http://user:pass@localhost/manager/text/start?path=/app'
];
DeployTool::Service::Tomcat->start(%config, port => 0);

# stop
$arguments = [
    'DeployTool::Service::Tomcat',
    'http://user:pass@localhost:1234/manager/text/stop?path=/app'
];
DeployTool::Service::Tomcat->stop(%config);

# undeploy
$arguments = [
    'DeployTool::Service::Tomcat',
    'http://user:pass@localhost:1234/manager/text/undeploy?path=/app'
];
DeployTool::Service::Tomcat->undeploy(%config);

# status
$arguments = [
    'DeployTool::Service::Tomcat',
    'http://localhost:1234/app/',
    1
];
DeployTool::Service::Tomcat->status(%config);

done_testing;
