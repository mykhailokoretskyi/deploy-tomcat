#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
plan tests => 3;
BEGIN {
    use_ok( 'DeployTool' );
    use_ok( 'DeployTool::Constants' );
    use_ok( 'DeployTool::Service::Tomcat' );
}
