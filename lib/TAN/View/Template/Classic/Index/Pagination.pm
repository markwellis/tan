package TAN::View::Template::Classic::Index::Pagination;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $pager ) = @_;

    my $order = $c->stash->{'order'};

    if ( !$pager ){
    #no pager
        return;
    }

    my $page_order;
    if ( ($order ne 'created') && ($order ne 'promoted') ){
        $page_order = $order;
    }

    my %params = (
        %{$c->req->params},
    );
    if ( $page_order ){
        $params{'order'} = $page_order;
    }

    my $total_pages = sprintf("%d", ($pager->total_entries / $pager->entries_per_page) + 1 );
    my $show_this_many = 5;
    my $current_page = $pager->current_page;

    my $lower = $current_page - $show_this_many;
    my $max = $current_page + $show_this_many;

    if ( $lower <= 1 ){
        $lower = 1;
        $max = $max + $show_this_many;
    }

    if ( $max >= $total_pages ){
        $lower = $total_pages - (2 * $show_this_many);
        if ( $lower <= 1 ){
            $lower = 1;
        }

        $max = $total_pages;
    }

    my $output = qq\<div class="@{[ ($c->stash->{'location'} eq 'picture') ? 'clear ' : '' ]}TAN-news-pagination">\;
    if ( $lower != 1 ){
        $output .= qq\
        <a class="TAN-news-page-number" href="@{[ $c->view->url("/@{[ $c->req->path ]}", %params, 'page' => 1) ]}">1</a>
        <span class="TAN-news-page-number">...</span>\;
    }

    foreach my $page ( $lower..$max ){
        $output .= qq\
        <a class="TAN-news-page-number@{[ ($page == $current_page) ? ' TAN-news-page-number-selected' : '' ]}" href="@{[ $c->view->url("/@{[ $c->req->path ]}", %params, 'page' => $page) ]}">
            ${page}
        </a>\;
    }

    if ( $max != $total_pages) {
        $output .= qq\
        <span class="TAN-news-page-number">...</span>
        <a class="TAN-news-page-number" href="@{[ $c->view->url("/@{[ $c->req->path ]}", %params, 'page' => $total_pages) ]}">${total_pages}</a>\;
    }
    $output .= '</div>';

    return $output;
}

1;
