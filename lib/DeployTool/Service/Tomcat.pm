package DeployTool::Service::Tomcat;

use strict;
use LWP::UserAgent;

use Data::Printer;

sub deploy {
    my ($class, %args) = @_;

    my $ua = LWP::UserAgent->new();
    my $res = $ua->put(
        "http". ($args{ssl} ? 's': '') . "://$args{user}:$args{password}\@$args{hostname}:$args{port}/manager/text/deploy?path=$args{path}&update=true",
        Content_Type => 'form-data',
        Content => [war => [$args{war}]],
    );
    Data::Printer::p($res);
}

1;
