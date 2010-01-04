use Test::More;
use Parse::BBCode::TAN;
use strict;
use warnings;

my $parser = Parse::BBCode::TAN->new;

# you might wonder why theres a <br /> in every bbcode snipplet
# its too make sure it doesn't start trying to be smart and encoding the entities
my @tests = (
    {
        'name' => 'quote',
        'input' => '[quote user=username]some quoted <br /> text[/quote] <br />',
        'expected' => '<div class="quote_holder"><span class="quoted_username">username wrote:</span><div class="quote">some quoted <br /> text</div></div> <br />',
    },
    {
        'name' => 'standard bbcode disabled',
        'input' => '[i]not italic[/i] [b]not bold[/b] [url=http://google.com]not a url[/url] <br />',
        'expected' => '[i]not italic[/i] [b]not bold[/b] [url=http://google.com]not a url[/url] <br />',
    },

);

foreach my $test ( @tests ){
    cmp_ok( $parser->render($test->{'input'}), 'eq', $test->{'expected'}, $test->{'name'} );
}

done_testing;
