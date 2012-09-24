use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN { use_ok 'TAN::Model::Image' }

use Config::Any;
use File::Basename;
use File::Temp;
use File::Path qw/rmtree/;
use Digest::SHA qw/sha512_hex/;

my $config_file = dirname( __FILE__ ) . "/../tan.json";
my $config = Config::Any->load_files( {
    'files' => [ $config_file ],
    'flatten_to_hash' => 1,
    'use_ext' => 1,
} );
$config = $config->{ $config_file }->{'Model::Image'};

my $model = new_ok( 'TAN::Model::Image' => [ $config ] );

my $test_images_dir = dirname( __FILE__ ) . "/model_Image";

{
    my $filename = mktemp('/tmp/model_Imagetmp.XXXXX');
    my $source_image = $test_images_dir . "/image.gif";

    $model->thumbnail( $source_image, $filename, 200 );
    open( my $temp_file, "<", $filename );
    is( sha512_hex( <$temp_file> ), 'a9b1da6f178df75e72c0e8cc8dad1486be87a10327c0e27d2e178ed2a2e1199dd1cf5eabc32448259ac3229d833a1da703039d7d829bea3957f355188febca35', "thumbnail: image" );
    close( $temp_file );
    unlink( $filename );
}

{
    my $filename = mktemp('/tmp/model_Imagetmp.XXXXX');
    my $source_image = $test_images_dir . "/animated.gif";

    $model->thumbnail( $source_image, $filename, 160 );
    open( my $temp_file, "<", $filename );
    is( sha512_hex( <$temp_file> ), '1a5c57c04dd2971fb6e7e782cbcb4afa1a8a3e3a54c126e73a99760faeff555d9df05ab4a3e3cf1cdde0a271a414458a94081e09ffc7ad4cca7a7e8d4d6fadd1', "thumbnail: animation shortened" );
    close( $temp_file );
    unlink( $filename );
}

{
    my $filename = mktemp('/tmp/model_Imagetmp.XXXXX');
    my $source_image = $test_images_dir . "/animated.gif";

    $model->thumbnail( $source_image, $filename, 200 );
    open( my $temp_file, "<", $filename );
    is( sha512_hex( <$temp_file> ), '3fb321f5d99b8ab58f5c9453c37add0629da35aea1421e8c694f642267f2fef81c982fc1a6c2bf4d19f4fcb2bec9665c8aa146c0ba50151820ec247caeb4aa80', "thumbnail: animation unshortened" );
    close( $temp_file );
    unlink( $filename );
}

{
    my $filename = mktemp('/tmp/model_Imagetmp.XXXXX');
    my $source_image = $test_images_dir . "/image.gif";

    $model->thumbnail( $source_image, $filename, 600 );
    open( my $temp_file, "<", $filename );
    is( sha512_hex( <$temp_file> ), '3ab150069441ef8e9bf8f91be6dc5e9a243d517d316b769e42ead431c1a5d3106bec69f0e40068d1724fba2be8310609ddfadba916a594dbff9c8d6c14080f13', "thumbnail: copied image as thumbnail would have been bigger" );
    close( $temp_file );
    unlink( $filename );
}

{
    my $filename = mktemp('/tmp/model_Imagetmp.XXXXX');
    my $source_image = $test_images_dir . "/animated200.gif";

    $model->thumbnail( $source_image, $filename, 600 );
    open( my $temp_file, "<", $filename );
    is( sha512_hex( <$temp_file> ), '111a18bf06360a5cf1c99455b5b4b4ee6f4c31f51ddcb602792aff97c1e728bf20429b7f5c613c3e27e407fad6ce4ce38faa4ec422bf8580f5c521cd3d25ddb8', "thumbnail: copied animated image as thumbnail would have been bigger" );
    close( $temp_file );
    unlink( $filename );
}

{
    my $source_image = $test_images_dir . "/image.gif";
    my $output = $test_images_dir . "/foo/out.gif";
    rmtree( dirname( $output ) );

    $model->thumbnail( $source_image, $output, 200 );

    ok( -e $output, "thumbnail: mkpath worked" );
    rmtree( dirname( $output ) );
}

{
    my $filename = mktemp('/tmp/model_Imagetmp.XXXXX');
    my $source_image = $test_images_dir . "/not a file";

    throws_ok{
        $model->thumbnail( $source_image, $filename, 200 );
    } qr/^file not found$/, 'thumbnail: file not found exception';
    
    $source_image = $test_images_dir . "/image.gif";
    throws_ok{
        $model->thumbnail( $source_image, $filename, 123 );
    } qr/^invalid thumbnail size$/, 'thumbnail: invalid thumbnail size exception';
    
    $source_image = $test_images_dir . "/not_image";
    throws_ok{
        $model->thumbnail( $source_image, $filename, 200 );
    } qr/^not an image$/, 'thumbnail: not an image exception';
}

{
    my $filename = mktemp('/tmp/model_Imagetmp.XXXXX');

    $model->create_blank( $filename );
    open( my $temp_file, "<", $filename );
    is( sha512_hex( <$temp_file> ), '49b8daf1f5ba868bc8c6b224c787a75025ca36513ef8633d1d8f34e48ee0b578f466fcc104a7bed553404ddc5f9faff3fef5f894b31cd57f32245e550fad656a', "create_blank: test" );
    close( $temp_file );
    unlink( $filename );
    
    throws_ok{
        $model->create_blank( '/this/path/isnt/real' );
    } qr/^error creating blank image$/, 'create_blank: invalid path exception';
    
}

{
    my $temp_file = File::Temp->new;
    my $source_image = $test_images_dir . "/image.gif";

    $model->crop( $source_image, $temp_file->filename, 70, 181, 96, 83 );
    is( sha512_hex( <$temp_file> ), 'db738707ff771ab0ad0ea8dc790d0690541e28dc226a34b7f130aba23ec566bbc9ef096657175b9717140a58a22541de091e6f2aa8ef43921038351c65ef10da', "crop: image" );
}

{
    #flock

    my $filename = mktemp('/tmp/model_Imagetmp.XXXXX');
    my $source_image = $test_images_dir . "/animated.gif";
    my $pid = fork;

    if ( $pid ){ 
        $model->thumbnail( $source_image, $filename, 160 );
        open( my $temp_file, "<", $filename );
        is( sha512_hex( <$temp_file> ), '1a5c57c04dd2971fb6e7e782cbcb4afa1a8a3e3a54c126e73a99760faeff555d9df05ab4a3e3cf1cdde0a271a414458a94081e09ffc7ad4cca7a7e8d4d6fadd1', "thumbnail: flock test: parent create thumb" );
        close( $temp_file );
        unlink( $filename );
    } else {
        is( $model->thumbnail( $source_image, $filename, 160 ), 1, "thumbnail: flock test: child wait for parent to create thumb");

        exit(0);
    }
}

done_testing;
