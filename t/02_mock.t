use strict;
use warnings;
use Test::More tests => 6;
use Test::MockObject;
use Catalyst;
BEGIN { $Catalyst::VERSION = 5.70 };

package MyApp::Component;
use Moose;
use CatalystX::MooseComponent;

__PACKAGE__->config(foo => 'bar');

has foo => ( is => 'ro' );
has bar => ( is => 'ro' );
has baz => ( is => 'ro', default => 'quux' );

package main;
my $app = Test::MockObject->new;
{
    my $comp = MyApp::Component->new($app, { bar => 'foo' });
    ok $comp;
    is $comp->foo, 'bar';
    is $comp->bar, 'foo';
    is $comp->baz, 'quux';
}
{
    my $comp = MyApp::Component->new($app, { foo => 'quux', bar => 'quux' });
    is $comp->foo, 'quux';
    is $comp->bar, 'quux';
}

