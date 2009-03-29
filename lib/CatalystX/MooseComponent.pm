package CatalystX::MooseComponent;
# ABSTRACT: Ensure your Catalyst component isa Moose::Object

use strict;
use warnings;
use Moose ();
use Moose::Exporter;
use Catalyst ();
use Carp qw/croak/;

Moose::Exporter->setup_import_methods( also => 'Moose' );

our $CATALYST_COMPONENT_TYPE;
{
    # Butt ugly. Something smarter can be done to get the param, I'm sure..
    my $importer = \&import;
    my $import_wrapper = sub {
        my $self = shift;
        my $param = shift || 'Component';
        croak("Unknown component '$param', must be one of /Model|View|Controller|Component")
            unless ($param =~ /^Model|View|Controller|Component$/);
        $CATALYST_COMPONENT_TYPE = $param;
        unshift(@_, $self);
        goto $importer;
    };
    {
        no warnings 'redefine';
        *import = $import_wrapper;
    }
}

our $CATALYST_FIRST_MOOSE_COMPAT_RELEASE = 5.71001;

sub init_meta {
  shift;
  my %p = @_;

  my $meta = Moose->init_meta(%p);
  my $for_class = $p{for_class};

  if (! $for_class->isa('Catalyst::Component') ) {
    $meta->superclasses('Catalyst::' . $CATALYST_COMPONENT_TYPE, $meta->superclasses);
  }
  if ($Catalyst::VERSION < $CATALYST_FIRST_MOOSE_COMPAT_RELEASE) {
    # FIXME - work with immutable components!
    my @nomoose_superclasses = grep { ! /^Moose::Object$/ } $meta->superclasses;
    $meta->superclasses( 'Moose::Object', @nomoose_superclasses );
    $meta->add_around_method_modifier(BUILDARGS => sub {
      my $next = shift;
      my ($self, $app) = (shift, shift);
      my $arguments = $self->merge_config_hashes(
        $self->config, $self->$next(@_)
      );
      $arguments->{_application} = $app;
      return $arguments;
    });
  }

  return $meta;
}

1;

=head1 SYNOPSIS

  package MyApp::Controller::Foo;

  use Moose;
  BEGIN { extends 'Catalyst::Controller' }
  use CatalystX::MooseComponent;

  # My::CatalystComponent now isa Moose::Object

=head1 DESCRIPTION

This module lets you write Catalyst components that are Moose objects without
worrying about whether Catalyst::Component is Moose-based or not (Catalyst 5.7
vs. 5.8).  It handles pulling in global application configuration and adding
C<Moose::Object> to your component's superclasses.

=method init_meta

Called automatically by C<import> to set up the proper superclasses and wrap
C<new()>.

=head1 CREDIT

Based on code from L<Catalyst::Controller::ActionRole> by Florian Ragwitz
<rafl@debian.org>.

=cut

