use strict;
use warnings;
use Test::More tests => 6;
use Test::MockObject;
use Catalyst;
use Scalar::Util qw/refaddr/;
BEGIN { $Catalyst::VERSION = 5.70 };

{
    package MyApp::Component;
    use CatalystX::MooseComponent 'Controller';

    __PACKAGE__->config(foo => 'bar');

    has foo => ( is => 'ro' );
    has bar => ( is => 'ro' );
    has baz => ( is => 'ro', default => 'quux' );
}

my $meta = Moose::Util::find_meta('MyApp::Component');
is_deeply(
  [ $meta->superclasses ],
  [ 'Moose::Object', 'Catalyst::Controller' ],
);

my $app = Test::MockObject->new;
{
    my $comp = MyApp::Component->new($app, { bar => 'foo' });
    isa_ok $comp, 'Catalyst::Controller';
    is $comp->foo, 'bar';
    is $comp->bar, 'foo';
    is $comp->baz, 'quux';
    is refaddr($comp->_application), refaddr($app);
}

