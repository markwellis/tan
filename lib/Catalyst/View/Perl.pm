package Catalyst::View::Perl;

use Moose;
use IO::Capture::Stdout;

extends 'Catalyst::View';

with 'Catalyst::Component::InstancePerContext';
with 'Catalyst::View::Perl::Core';

has 'context' => (is => 'ro');
has 'namespace' =>(
    'is' => 'rw',
    'isa' => 'Str',
    'default' => 'Template',
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

    my $capture =  IO::Capture::Stdout->new;
    $capture->start;

    if ( $self->config->{'config'} ){
        $self->template( $self->config->{'config'} );
    }

    $self->template($template, @args);
    $capture->stop;

    my @content = $capture->read;
    my @output;

    if ( $self->config->{'wrapper'} ){
        $capture->start;

        $self->template( $self->config->{'wrapper'}, join('', @content) );

        $capture->stop;
        @output = $capture->read;
    } else {
        @output = @content;
    }

    return join('', @output);
}

sub template{
    my ( $self, $template, @args ) = @_;

    my $c = $self->context;
    my $view = $c->view("@{[ $self->namespace ]}::${template}");

    if ( !$view ){
        Catalyst::Exception->throw( "Template '${template}' not found" );
    }

    $c->stats->profile('begin' => " -> ${template}");
    $view->process($c, @args);
    $c->stats->profile('end' => " -> ${template}");
}

__PACKAGE__->meta->make_immutable;

1;
