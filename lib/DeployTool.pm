package DeployTool;

use 5.006;

use strict;
use DeployTool::Service::Tomcat;
use Data::Dumper;
$Data::Dumper::Terse = 1;

use constant DEFAULT_CONFIG_HOME => $ENV{HOME} . "/.deploy-tool";
use constant DEFAULT_CONFIG_FILE => DEFAULT_CONFIG_HOME() . "/config.cfg";

our $VERSION = "0.0.1";

my %validation_profile = (
    deploy => [ qw( hostname path war user password ) ],
    undeploy => [ qw( hostname path user password ) ],
    stop => [ qw( hostname path user password ) ],
    start => [ qw( hostname path user password ) ],
    config => [ qw(  ) ],
    help => [ qw(  ) ],
    status => [ qw( hostname path ) ],
);

sub _run_cmd {
    my ($class, $cmd, %args) = @_;

    my $config = $class->_read_config(%args);
    unless ( $class->_is_valid_config_for_cmd($cmd, $config) ) {
        $class->help();
    }
    $class->$cmd(%$config);
}

sub _read_config {
    my ($class, %args) = @_;
    my $config = $args{config} ? $class->_get_config($args{config}) : $class->_get_default_config();
    return {(%$config ,%args, config_data => $config)};
}

sub _get_config {
    my ($class, $file_name) = @_;
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
    my $class = shift;
    if ( !-f DEFAULT_CONFIG_FILE) {
        mkdir DEFAULT_CONFIG_HOME()
            unless -d DEFAULT_CONFIG_HOME();

        $class->_write_config(DEFAULT_CONFIG_FILE(), {});
    }
    $class->_get_config( DEFAULT_CONFIG_FILE() );
}

sub _write_config {
    my ($class, $file_name, $data) = @_;

    my $FH;
    open $FH, ">", $file_name or die "cannot open file for writing: $file_name\n";
    print $FH Data::Dumper::Dumper($data);
    close $FH;
}

sub _is_valid_config_for_cmd {
    my ($class, $cmd, $cnf) = @_;

    return 0
        if ( grep { !exists $cnf->{$_} } @{$validation_profile{$cmd}} );

    1;
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

sub config {
    my ($class, %args) = @_;
    my $config_data = delete $args{config_data};
    my $config_file = delete $args{config};

    map { $config_data->{$_} = $args{$_}; } keys %args;
    $class->_write_config(
        $config_file || DEFAULT_CONFIG_FILE(),
        $config_data,
    );
}

sub help {
    die "HELP";
}

1;
