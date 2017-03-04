package DeployTool::Service::Tomcat;

use strict;
use LWP::UserAgent;
use HTTP::Request::Common;
use DeployTool::Constants;

use Data::Printer;

sub deploy {
    my ($class, %args) = @_;

    my $update = $args{update} ? "true" : "false";

    my $res = $class->_send_request(
        HTTP::Request::Common::PUT(
            $class->_get_base_url(%args, auth => 1) . "/manager/text/deploy?path=$args{path}&update=$update",
            Content_Type => 'form-data',
            Content => [war => [$args{war}]],
        )
    );

    $class->_is_successful($res);
}

sub status {
    my ($class, %args) = @_;

    my $res = $class->_send_request(
        HTTP::Request::Common::GET($class->_get_base_url(%args) . "$args{path}/"),
        1,
    );

    return $res->code() == 404 ? 0 : 1;
}

sub start {
    my ($class, %args) = @_;

    my $res = $class->_send_request(
        HTTP::Request::Common::GET(
            $class->_get_base_url(%args, auth => 1) . "/manager/text/start?path=$args{path}"
        ),
    );

    $class->_is_successful($res);
}

sub stop {
    my ($class, %args) = @_;

    my $res = $class->_send_request(
        HTTP::Request::Common::GET(
            $class->_get_base_url(%args, auth => 1) . "/manager/text/stop?path=$args{path}"
        ),
    );

    $class->_is_successful($res);
}

sub undeploy {
    my ($class, %args) = @_;

    my $res = $class->_send_request(
        HTTP::Request::Common::GET(
            $class->_get_base_url(%args, auth => 1) . "/manager/text/undeploy?path=$args{path}",
        ),
    );

    $class->_is_successful($res);
}

sub _send_request {
    my ($class, $req, $skip_errors) = @_;

    my $ua = LWP::UserAgent->new();
    my $res = $ua->request($req);

    $class->_handle_http_errors($res)
        unless $skip_errors;

    $res;
}

sub _handle_http_errors {
    my ($class, $res) = @_;
    if (!$res->is_success()) {
        die "Got bad response from Tomcat: " . $res->code() . "\n";
    }
}

sub _get_base_url {
    my ($class, %args) = @_;
    return "http". ($args{ssl} ? 's': '') . "://" .
        ($args{auth} ? "$args{user}:$args{password}\@" : "") .
        "$args{hostname}:$args{port}";
}

sub _is_successful {
    my ($class, $res) = @_;

    $res->content() =~ /^(\w+)\s/;
    if ($1 ne DeployTool::Constants::TOMCAT_DEPLOYMENT_OK()){
        print STDERR $res->content();
        return 0;
    }
    1;
}

1;
