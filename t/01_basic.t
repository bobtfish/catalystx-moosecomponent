use strict;
use warnings;
use Test::More tests => 1;
use Catalyst ();
BEGIN { $Catalyst::VERSION = 5.70 };

{
  package MyApp::Component;
  use CatalystX::MooseComponent;
}

my $meta = Moose::Util::find_meta('MyApp::Component');
is_deeply(
  [ $meta->superclasses ],
  [ 'Moose::Object', 'Catalyst::Component' ],
);

