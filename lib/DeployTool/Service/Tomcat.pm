package DeployTool::Service::Tomcat;

use strict;
use LWP::UserAgent;
use DeployTool::Constants;

use Data::Printer;

sub deploy {
    my ($class, %args) = @_;

    my $update = $args{update} ? "true" : "false";

    my $ua = LWP::UserAgent->new();
    my $res = $ua->put(
        "http". ($args{ssl} ? 's': '') . "://$args{user}:$args{password}\@$args{hostname}:$args{port}/manager/text/deploy?path=$args{path}&update=$update",
        Content_Type => 'form-data',
        Content => [war => [$args{war}]],
    );

    my $code = $res->code();
    if (!$res->is_success()) {
        die "Got bad response from Tomcat: $code\n";
    }

    $res->content();
}

sub status {
    my ($class, %args) = @_;

    my $ua = LWP::UserAgent->new();
    my $res = $ua->get(
        "http". ($args{ssl} ? 's': '') . "://$args{hostname}:$args{port}$args{path}/",
    );

    return $res->code() == 404 ? 0 : 1;
}

sub start {
    my ($class, %args) = @_;
    my $ua = LWP::UserAgent->new();
    my $res = $ua->get(
        "http". ($args{ssl} ? 's': '') . "://$args{user}:$args{password}\@$args{hostname}:$args{port}/manager/text/start?path=$args{path}",
    );

    my $code = $res->code();
    if (!$res->is_success()) {
        die "Got bad response from Tomcat: $code\n";
    }

    $res->content() =~ /^(\w+)\s/;
    if ($1 ne DeployTool::Constants::TOMCAT_DEPLOYMENT_OK()){
        print STDERR $res->content();
        return 0;
    }

    1;
}

sub stop {
    my ($class, %args) = @_;
    my $ua = LWP::UserAgent->new();
    my $res = $ua->get(
        "http". ($args{ssl} ? 's': '') . "://$args{user}:$args{password}\@$args{hostname}:$args{port}/manager/text/stop?path=$args{path}",
    );

    my $code = $res->code();
    if (!$res->is_success()) {
        die "Got bad response from Tomcat: $code\n";
    }

    $res->content() =~ /^(\w+)\s/;
    if ($1 ne DeployTool::Constants::TOMCAT_DEPLOYMENT_OK()){
        print STDERR $res->content();
        return 0;
    }

    1;
}

sub undeploy {
    my ($class, %args) = @_;
    my $ua = LWP::UserAgent->new();
    my $res = $ua->get(
        "http". ($args{ssl} ? 's': '') . "://$args{user}:$args{password}\@$args{hostname}:$args{port}/manager/text/undeploy?path=$args{path}",
    );

    my $code = $res->code();
    if (!$res->is_success()) {
        die "Got bad response from Tomcat: $code\n";
    }

    $res->content() =~ /^(\w+)\s/;
    if ($1 ne DeployTool::Constants::TOMCAT_DEPLOYMENT_OK()){
        print STDERR $res->content();
        return 0;
    }

    1;
}

1;
