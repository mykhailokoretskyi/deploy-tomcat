package DeployTool::Service::Tomcat;

our $AUTOLOAD;

use constant ALLOWED_METHODS => [ qw(
    deploy
    undeploy
    start
    stop
    status
)];

sub AUTOLOAD {
    my ($class, %args) = @_;
    my ($method) = grep { $AUTOLOAD =~ /::$_$/ } @{ALLOWED_METHODS()};

    die "Not allowed method is passed"
        if (!$method);

    return $args{$method};
}

1;
