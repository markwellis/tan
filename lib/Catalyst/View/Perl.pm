package Catalyst::View::Perl;

use Moose;

extends 'Catalyst::View';

with 'Catalyst::Component::InstancePerContext';
with 'Catalyst::View::Perl::Core';

has 'context' => (is => 'ro');
has 'namespace' =>(
    'is' => 'rw',
    'isa' => 'Str',
    'default' => undef,
);

no Moose;

sub build_per_context_instance {
    my ($self, $c, @args) = @_;
    return $self->new({ context => $c, %$self, @args });
}

sub process{
    my ( $self, $c ) = @_;

    if ( !$c->stash->{'template'} ){
        Catalyst::Exception->throw( "No Template specified" );
    }

    $c->response->body( $self->render($c, $c->stash->{'template'}) );

    unless ( $c->response->content_type ) {
        $c->response->content_type('text/html; charset=utf-8');
    }
}

sub render{
    my ( $self, $c, $template, @args ) = @_;
#redirect stdout so we can print template output 

    my ( $content, $output );

    if ( $self->config->{'config'} ){
        $content = $self->template( $self->config->{'config'} );
    }

    $content = $self->template($template, @args);
    if ( $self->config->{'wrapper'} ){
        $output = $self->template( $self->config->{'wrapper'}, $content );
    }

    return $output || $content;
}

sub template{
    my ( $self, $template_name, @args ) = @_;

    my $c = $self->context;

    if ( !$self->namespace ){
        if ( $c->stash->{'template_namespace'} ){
            $self->namespace( $c->stash->{'template_namespace'} );
        } else {
            Catalyst::Exception->throw( "Template namespace not set" );
        }
    }

    my $template = $c->view("@{[ $self->namespace ]}::${template_name}");

    if ( !$template ){
        Catalyst::Exception->throw( "Template '${template_name}' not found" );
    }

    $c->stats->profile('begin' => " -> ${template_name}");
    my $output = $template->process($c, @args);
    $c->stats->profile('end' => " -> ${template_name}");
    return $output;
}

__PACKAGE__->meta->make_immutable;

1;
