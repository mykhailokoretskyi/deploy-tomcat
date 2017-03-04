package DeployTool;

use strict;
use DeployTool::Service::Tomcat;

sub deploy {
    my ($class, %args) = @_;

    DeployTool::Service::Tomcat->deploy(
        (%args)
    );

    $class->status(%args);
}

sub status {
    my ($class, %args) = @_;

}

1;
