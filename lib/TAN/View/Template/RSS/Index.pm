package TAN::View::Template::RSS::Index;

use base 'Catalyst::View::Perl::Template';
use DateTime::Format::Mail;

sub process{
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'index'}->{'objects'}->[0];
    $c->stash->{'build_date'} = DateTime::Format::Mail->format_datetime( $object->_promoted || $object->_created );

    my $output = '';
    foreach my $object ( @{$c->stash->{'index'}->{'objects'}} ){
        $output .= $c->view->template('Lib::Object', $object);
    }

    return $output;
}

1;
