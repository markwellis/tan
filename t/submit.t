use Test::More;
use Test::Exception;

use TAN::Submit;

use File::Basename;
use Try::Tiny;

use Catalyst::Test 'TAN';

my $submit = new_ok('TAN::Submit');
my ( $res, $c ) = ctx_request('/');

#basic tests here
throws_ok{ $submit->validate_and_prepare($c) } 'Exception::Simple';
is($@, 'no params', 'no params');

throws_ok{ $submit->validate_and_prepare( $c, {} ) } 'Exception::Simple';
is($@, 'no type', 'no type');

throws_ok{ $submit->validate_and_prepare( $c, {'type' => 'invalid'} ) } 'Exception::Simple';
is($@, 'invalid type', 'invalid type');

throws_ok{ $submit->validate_and_prepare( $c ) } 'Exception::Simple';
is($@, 'no params', 'no params');

#runs the test for each module from the module dir
run_module_tests();

sub run_module_tests{
    my $this_dir = dirname($0);

#so you can pass module names to the test
# e.g.
#  perl -I ../lib submit.t link

    my @modules;
    if ( scalar(@ARGV) ){
        foreach my $arg ( @ARGV ){
            push(@modules, $submit->modules->{ $arg });
        }
    } else {
        @modules = values(%{$submit->modules});
    }

    foreach my $module ( @modules ){
        my $name = ref($module);
        my @names = split(/::/, $name);

        my $filename = lc(pop(@names));
        my $test_script_path = join('/', "${this_dir}/../lib", @names, "t/${filename}.t");
        if ( -e $test_script_path ){
            note( "running module tests for\n\t$filename" );
            unless ( my $error = do $test_script_path ) {
                die $error;
            }
        }
    }
}

done_testing;
exit;

note('picture');

{
    my $error = $submit->validate({
        'type' => 'picture',
        'title' => 'this is the title',
        'description' => 'this is the description',
    });
    is( $error, 'either upload or remote must be provided', 'no upload or url' );
}

{
    $fh = File::Temp->new();
    my $error = $submit->validate({
        'type' => 'picture',
        'description' => 'this is the description',
        'remote' => {
            'url' => 'http://thisaintnews.com/static/images/logo.png',
            'save_to' => $fh->filename,
        },
    });
    is( $error, 'title is required', 'no title' );
}

{
    $fh = File::Temp->new();
    my $error = $submit->validate({
        'type' => 'picture',
        'title' => 'this is the title',
        'remote' => {
            'url' => 'http://thisaintnews.com/static/images/logo.png',
            'save_to' => $fh->filename,
        }
    });
    is( $error, 'description is required', 'no description (url)' );
}

{
    my $error = $submit->validate({
        'type' => 'picture',
        'description' => 'this is the description',
        'title' => 'this is the title',
        'remote' => {
            'url' => 'invalid url',
        },
    });
    is( $error, 'invalid url', 'invalid url' );
}

{
    $fh = File::Temp->new();
    my $error = $submit->validate({
        'type' => 'picture',
        'title' => 'this is the title',
        'description' => 'this is the description',
        'remote' => {
            'url' => 'http://thisaintnews.com/static/images/this_file_doesnt_exist.png',
            'save_to' => $fh->filename,
        }
    });
    is( $error, 'Transfer error', '404 fetch (testing validator)' );
}

{
    $fh = File::Temp->new();
    ok( !(-s $fh->filename), 'file is empty' );

    my ($error_f, $file_info_f) = $submit->validate({
        'type' => 'picture',
        'title' => 'this is the title',
        'description' => 'this is the description',
        'remote' => {
            'url' => 'http://thisaintnews.com/static/images/logo.png',
            'save_to' => $fh->filename,
        }
    });

    is( $error_f, undef, 'image download' );
    ok( -s $fh->filename, 'file has size' );

    my ($error_u, $file_info_u) = $submit->validate({
        'type' => 'picture',
        'title' => 'this is the title',
        'upload' => $fh->filename,
        'description' => 'this is the description',
    });
    is( $error_u, undef, 'image valid' );
}

{    
    my ($error, $file_info) = $submit->validate({
        'type' => 'picture',
        'title' => 'this is the title',
        'upload' => 'invalid filename',
    });
    is( $error, 'invalid filetype', 'invalid upload' );
}

done_testing();
