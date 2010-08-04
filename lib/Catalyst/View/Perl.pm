package Catalyst::View::Perl;

use Moose;

extends 'Catalyst::View';

with 'Catalyst::Component::InstancePerContext';
with 'Catalyst::View::Perl::Core';

has 'context' => (is => 'ro');
has 'namespace' =>(
    'is' => 'rw',
    'isa' => 'Str',
    'default' => 'Template',
);

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
}

sub render{
    my ( $self, $c, $template, @args ) = @_;
#redirect stdout so we can print template output 
    my ( $content, $output );

    open(SAVED_STDOUT, ">&STDOUT");
    close(STDOUT);

    open(STDOUT, '>', \$content);
    if ( $self->config->{'config'} ){
        $self->template( $self->config->{'config'} );
    }

    $self->template($template, @args);
    close(STDOUT);

    if ( $self->config->{'wrapper'} ){
        open(STDOUT, '>', \$output);

        $self->template( $self->config->{'wrapper'}, $content );

        close(STDOUT);
    } else {
        $output = $content;
    }

    open(STDOUT, ">&SAVED_STDOUT");
    close(SAVED_STDOUT);

    unless ( $c->response->content_type ) {
        $c->response->content_type('text/html; charset=utf-8');
    }

    return $output;
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

1;
