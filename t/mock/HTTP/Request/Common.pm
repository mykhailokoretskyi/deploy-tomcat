package HTTP::Request::Common;

our $AUTOLOAD;

use constant ALLOWED_METHODS => [ qw(
    PUT
    GET
)];

sub AUTOLOAD {
    my ($url, %args) = @_;
    my ($method) = grep { $AUTOLOAD =~ /::$_$/ } @{ALLOWED_METHODS()};

    die "Not allowed method is passed"
        if (!$method);

    return @_;
}


1;
