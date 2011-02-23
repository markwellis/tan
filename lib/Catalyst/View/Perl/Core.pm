package Catalyst::View::Perl::Core;
use Moose::Role;
use namespace::autoclean;

use HTML::TreeBuilder;
use HTML::FormatText;
use HTML::Entities;
use XML::Entities;

=head2 html

B<@args = ($text)>

=over

html encodes $text

=back

=cut
sub html{
    my ( $self, $text ) = @_;

    return encode_entities($text);
}

=head2 xml

B<@args = ($text)>

=over

xml encodes $text

=back

=cut
sub xml{
    my ( $self, $text ) = @_;

    return XML::Entities::numify('all', $self->html($text));
}

=head2 strip_tags

B<@args = ($text)>

=over

strips the html tags out of a passed in string

=back

=cut
sub strip_tags{
    my ( $self, $text ) = @_;
    
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($text);
    $tree->eof;

    if ($tree) {
        $text = $tree->as_text();
        $tree = $tree->delete;
    }

    return $text;
}

=head2 nl2br_reg

B<@args = ($text)>

=over

converts \n's to <br />'s

=back

=cut
my $nl2br_reg = qr/\n|\r\n/;
sub nl2br{
    my ( $self, $text ) = @_;
    chomp($text);

    $text =~ s#$nl2br_reg#<br />#gm;

    return $text;
}

=head2 trim

B<@args = ($text)>

=over

trims a string

=back

=cut
my $ltrim = qr/^\s+/;
my $rtrim = qr/\s+$/;
sub trim{
    my ( $self, $string ) = @_;

    $string =~ s/$ltrim//;
    $string =~ s/$rtrim//;

    return $string
}

1;
