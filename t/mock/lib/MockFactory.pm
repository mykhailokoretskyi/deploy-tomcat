package MockFactory;

use strict;
use Test::DeepMock;

our @ISA = qw( Test::DeepMock );

our $CONFIG = {
    "DeployTool::Service::Tomcat" => {},
    "LWP::UserAgent" => {},
    "HTTP::Request::Common" => {}
};

our $PATH_TO_MOCKS = "t/mock";

1;
