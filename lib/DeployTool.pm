package DeployTool;

use strict;
use DeployTool::Service::Tomcat;

sub deploy {
    my ($class, %args) = @_;

    print "Starting Tomcat deployment... ";

    my $response = DeployTool::Service::Tomcat->deploy(
        (%args)
    );

    unless ($response) {
        print "FAILED\n";
        die 1;
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
