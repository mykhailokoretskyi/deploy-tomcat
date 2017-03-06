package LWP::UserAgent;

sub new {
    my ($class, %args) = @_;
    bless {}, $class;
}

sub request {
    my ($self, $req) = @_;
    HTTP::Response->new($req->header("status"));
}

1;
