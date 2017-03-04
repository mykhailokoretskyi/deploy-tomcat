package DeployTool;

use strict;
use DeployTool::Service::Tomcat;
use DeployTool::Constants;

sub deploy {
    my ($class, %args) = @_;

    print "Starting Tomcat deployment... ";

    my $response = DeployTool::Service::Tomcat->deploy(
        (%args)
    );

    if ($response =~ /^(\w+)\s/) {
        if ($1 ne DeployTool::Constants::TOMCAT_DEPLOYMENT_OK()) {
            die "Tomcat failed deployment with: $response\n";
        }
    } else {
        die "Cannot parse response from Tomcat server. Got: $response\n";
    }

    print "OK\n";

    print "Verifying the app... ";
    my $is_running = DeployTool::Service::Tomcat->status(%args);
    $is_running ? print "OK\n" : die "FAILED: app is not accessible\n";
}

sub status {
    my ($class, %args) = @_;

    print "Verifying the app... ";
    print( (DeployTool::Service::Tomcat->status(%args) ? "" : "NOT ") . "RUNNING\n" );
}

sub start {
    my ($class, %args) = @_;
    print "Starting the app... ";
    print( (DeployTool::Service::Tomcat->start(%args) ? "OK" : "FAILED") . "\n" );

    print "Verifying the app... ";
    my $is_running = DeployTool::Service::Tomcat->status(%args);
    $is_running ? print "OK\n" : die "FAILED: app is not accessible\n";
}

sub stop {
    my ($class, %args) = @_;
    print "Stopping the app... ";
    print( (DeployTool::Service::Tomcat->stop(%args) ? "OK" : "FAILED") . "\n" );

    print "Verifying the app... ";
    my $is_running = DeployTool::Service::Tomcat->status(%args);
    $is_running ? die "FAILED: app is still accessible\n" : print "OK\n";
}

sub undeploy {
    my ($class, %args) = @_;
    print "Undeploying the app... ";
    print((DeployTool::Service::Tomcat->undeploy(%args) ? "OK" : "FAILED") . "\n");
}

1;
