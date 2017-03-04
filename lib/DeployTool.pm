package DeployTool;

use strict;
use DeployTool::Service::Tomcat;

use Data::Printer;

use constant DEFAULT_CONFIG_HOME => $ENV{HOME} . "/.deploy-tool";
use constant DEFAULT_CONFIG_FILE => DEFAULT_CONFIG_HOME() . "/config.cfg";

sub _run_cmd {
    my ($class, $cmd, %args) = @_;

    my $config = $class->_read_config(%args);

    Data::Printer::p($config);
    $class->$cmd(%$config);
}

sub _read_config {
    my ($class, %args) = @_;
    my $config = $args{config} ? _get_config(delete $args{config}) : _get_default_config();
    return {(%$config ,%args)};
}

sub _get_config {
    my $file_name = shift;
    my $data;
    {
        local $/;
        my $FH;
        open( $FH, "<$file_name" ) or die "cannot open file $file_name\n";
        $data = <$FH>;
    }
    my $config = eval $data;
    if ($@) {
        die "Error of parsing configuration file $file_name: $@\n";
    }
    $config;
}

sub _get_default_config {
    if ( !-f DEFAULT_CONFIG_FILE) {
        mkdir DEFAULT_CONFIG_HOME();
        _create_default_config();
    }
    _get_config( DEFAULT_CONFIG_FILE() );
}

sub _create_default_config {
    my $FH;
    open $FH, ">", DEFAULT_CONFIG_FILE() or die "cannot create default configuration " . DEFAULT_CONFIG_FILE() . "\n";
    print $FH <<EOF;
{
    #put your configuration here in PERL HASH syntax
};

EOF
}

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
