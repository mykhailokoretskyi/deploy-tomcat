package MockFactory;

use strict;
use Test::DeepMock;

our @ISA = qw( Test::DeepMock );

our $CONFIG = {
    "DeployTool::Service::Tomcat" => {},
};

our $PATH_TO_MOCKS = "t/mock";

1;
