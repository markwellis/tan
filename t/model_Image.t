use strict;
use warnings;
use Test::More tests => 24;
use Test::Fatal;

use FindBin qw/$Bin/;
use Path::Tiny;

use TAN;
my $model = TAN->model('Image');

my $test_images_dir = "$Bin/model_Image";

use File::Temp;
local $File::Temp::KEEP_ALL = 1 if $ENV{KEEP};

my $i = 0;
sub tempfile($) {
    ++$i;
    Path::Tiny->tempfile( "model_Image-$i-$_[0].XXXXX" );
}

{
    my $filename = tempfile 'thumbnail_image';
    my $source_image = $test_images_dir . "/image.gif";

    $model->thumbnail( $source_image, $filename, 200 );

    is( $filename->digest('SHA-512'), '457124b3176274598f71f9aa41dadf8f076172b4295f6a5c14660a1d9e3e32b9ec548a0b6341a2fe9c7a7b5320c9f5d9fc3d287a9ed26cecc83d388c6ea7ace4', "thumbnail: image" );
}

{
    my $filename = tempfile 'thumbnail_short_gif';
    my $source_image = $test_images_dir . "/animated.gif";

    $model->thumbnail( $source_image, $filename, 160 );

    is( $filename->digest('SHA-512'), 'a4e149620f01bf78431ea9395fd4c2288b7280c9fd24afe4e1817880d0f294818de4eee574cf95e9a3569bd79dbbd0dfe83e10fd6113ab44223238d774591007', "thumbnail: animation shortened" );
}

{
    my $filename = tempfile 'thumbnail_unshort_gif';
    my $source_image = $test_images_dir . "/animated.gif";

    $model->thumbnail( $source_image, $filename, 200 );

    is( $filename->digest('SHA-512'), '4e66cfb4c758752aa659b3ecd01dea2790066689a7ce6d87b388535f32436f9414946637b6d758f5c307303282ef37ae5bb775f9a3efefb46aae9cdb2d7bd699', "thumbnail: animation unshortened" );
}

{
    my $filename = tempfile 'thumbnail_copy_image';
    my $source_image = $test_images_dir . "/image.gif";

    $model->thumbnail( $source_image, $filename, 600 );

    is( $filename->digest('SHA-512'), '3ab150069441ef8e9bf8f91be6dc5e9a243d517d316b769e42ead431c1a5d3106bec69f0e40068d1724fba2be8310609ddfadba916a594dbff9c8d6c14080f13', "thumbnail: copied image as thumbnail would have been bigger" );
}

{
    my $filename = tempfile 'thumbnail_copy_animated_gif';
    my $source_image = $test_images_dir . "/animated200.gif";

    $model->thumbnail( $source_image, $filename, 600 );

    is( $filename->digest('SHA-512'), '111a18bf06360a5cf1c99455b5b4b4ee6f4c31f51ddcb602792aff97c1e728bf20429b7f5c613c3e27e407fad6ce4ce38faa4ec422bf8580f5c521cd3d25ddb8', "thumbnail: copied animated image as thumbnail would have been bigger" );
}

{
    my $source_image = $test_images_dir . "/image.gif";
    my $output = tempfile 'thumbnail_mkpath';

    $model->thumbnail( $source_image, $output, 200 );

    ok( $output->exists, "thumbnail: mkpath worked" );
}

{
    my $filename = tempfile 'errors';
    my $source_image = $test_images_dir . "/not a file";

    like(
        exception {
            $model->thumbnail( $source_image, $filename, 200 );
        },
        qr/file not found/,
        'thumbnail: file not found exception'
    );

    $source_image = $test_images_dir . "/image.gif";
    like(
        exception {
            $model->thumbnail( $source_image, $filename, 123 );
        },
        qr/invalid thumbnail size/,
        'thumbnail: invalid thumbnail size exception'
    );

    $source_image = $test_images_dir . "/not_image";
    like(
        exception { $model->thumbnail( $source_image, $filename, 200 ) },
        qr/open image failed/,
        'thumbnail: not an image exception'
    );
}

{
    my $filename = tempfile 'error_permission_denined';

    $model->create_blank( $filename );

    is( $filename->digest('SHA-512'), '68fd3db10efa1b40a1a45d8f8e97b77e2558f7573acc3c81f19b5eae390c9e2947ad2464acc4c24dd77d691ed78ebc1cb3a7e47aa36b84188e62a5bdcb04c3ac', "create_blank: test" );

    like(
        exception {
            $model->create_blank( '/this/path/isnt/real' );
        },
        qr/Permission denied/,
        'create_blank: invalid path exception'
    );
}

{
    my $tempfile = tempfile 'crop';
    my $source_image = $test_images_dir . "/image.gif";

    #this should be an eye
    $model->crop( $source_image, $tempfile, 70, 181, 96, 83 );
    is( $tempfile->digest('SHA-512'), 'd92a97beaa96257f4fe28393de82b9c40d1d1a325581057bfc9ac5404d0bcef6df3f1e2e086a4b975485ba1158ceb89fee87e2adcf02b9a04c84181813ee7e43', "crop: image" );
}

{
    my $tempfile = tempfile 'thumbnail_jpeg';
    my $source_image = $test_images_dir . "/drunk-gorilla-punch.jpg";

    $model->thumbnail( $source_image, $tempfile, 200 );
    is( $tempfile->digest('SHA-512'), '2877701649e5efb81735bb8452acf66cea3495dfd062bf529ee5697819ed1cf2caad2d7dd72eb503d75dfaaf58a6b38e0b40a4008ca1dc9c89fdf377ac713376', "thumbnail: jpg" );
}

{
    my $tempfile = tempfile 'thumbnail_sonic_160';
    my $source_image = $test_images_dir . "/sonic.gif";

    $model->thumbnail( $source_image, $tempfile, 160 );
    is( $tempfile->digest('SHA-512'), 'de7f3986da155d183d39ef35f6767bb69edcf4df3a5ef5fd695aa42204fba852789f33a1388daa940a2b53376da7999683ab4089e1f5a6f89f541b1118249210', "thumbnail: sonic 160" );
}

{
    my $tempfile = tempfile 'thumbnail_sonic_200';
    my $source_image = $test_images_dir . "/sonic.gif";

    $model->thumbnail( $source_image, $tempfile, 200 );
    is( $tempfile->digest('SHA-512'), 'be475a733099b97b7f02b0e83d727e753ff9e975e55529274e5f45cb9b9f9c3009f9de12b33074af52d453dca6886110a7df6d8882fbd41ee3e30744605573bd', "thumbnail: sonic_200" );
}

{
    my $tempfile = tempfile 'thumbnail_png';
    my $source_image = $test_images_dir . "/awesome.png";

    $model->thumbnail( $source_image, $tempfile, 160 );
    is( $tempfile->digest('SHA-512'), 'f43e498a0d4d5ae0f9264baafe358e7f33a1afc39a8822c10d3bdfa7fb06f438403fbc4519586c3a075c6cc9bf60c68f8511a1752b4b322438b8490a4a0b2233', "thumbnail: png" );
}

{
    my $tempfile = tempfile 'crop_animated_sonic';
    my $source_image = $test_images_dir . "/sonic.gif";

    $model->crop( $source_image, $tempfile, 5, 70, 80, 86 );
    is( $tempfile->digest('SHA-512'), 'd798f0c348cd5e429b500a7dae2b6b8581dc26c91527b290ba1906b218546e12664a62b86f2d700cc371a3849c66013506b4ea773ee4eda265d84bcede0a79ce', "crop: sonic" );
}

{
    my $tempfile = tempfile 'crop_animated_gif';
    my $source_image = $test_images_dir . "/animated.gif";

    $model->crop( $source_image, $tempfile, 168, 262, 200, 200 );
    is( $tempfile->digest('SHA-512'), '2e6279e2862c4bdd6d08d1a7514569e2377f46f2a505d17070200f31675e3297245b2c0540b2ea1143c0aa3c09cd94876deec3f3c7989647f3b362d9e1ce2310', "crop: animated" );
}

{
    my $tempfile = tempfile 'crop_animated_squares_gif';
    my $source_image = $test_images_dir . "/squares.gif";

    $model->crop( $source_image, $tempfile, 250, 250, 100, 100 );
    is( $tempfile->digest('SHA-512'), '59f79111029799c869070f3857958e96af2211dfa0c000b1ee586b3bcab5ce357bae8a0c9e209c75bd03d40782a9f11ac03af7cf68b68abe8b2e8acbb3834c86', "crop: squares animated" );
}

{
    my $tempfile = tempfile 'crop_animated_squares_2_gif';
    my $source_image = $test_images_dir . "/squares_2.gif";

    $model->crop( $source_image, $tempfile, 250, 250, 100, 100 );
    is( $tempfile->digest('SHA-512'), '77a61a6b61400431e02f8be63c5ba238e51d1102dfd7655dc71f147006f96f5392c2fdfd44ccce6248949c5fd3fad5da60ed380f1ae05a17a4dad2376f052461', "crop: squares_2 animated" );
}

{
    my $tempfile = tempfile 'crop_animated_squares_3_gif';
    my $source_image = $test_images_dir . "/squares_3.gif";

    $model->crop( $source_image, $tempfile, 150, 150, 100, 100 );
    is( $tempfile->digest('SHA-512'), 'e7c17f3f4b646c81a448206e078861044f95ab4eaf1bef0533f5013c83fbc25de1512b1a27741192d5b769f81d1b394272c8b0499fccc9212c7e06173fb9e11a', "crop: squares_3 animated" );
}

{
    my $tempfile = tempfile 'crop_animated_squares_4_gif';
    my $source_image = $test_images_dir . "/squares_4.gif";

    $model->crop( $source_image, $tempfile, 3, 3, 6, 6 );
    is( $tempfile->digest('SHA-512'), '6aa10caf00805a9361afe4e323974d6be6c7ce20f0efbcf2619f0f82052d56e54e8a733b81b9283dad09e400889c76b788eabadc6b6dd62b398ef6cfac8bc220', "crop: squares_4 animated" );
}

{
    my $filename = tempfile 'thumbnail_txt_jpeg_ext';
    my $source_image = $test_images_dir . "/image.fake.jpg";

    like(
        exception {
            $model->thumbnail( $source_image, $filename, 200 );
        },
        qr/open image failed/,
        'thumbnail: txt_jpeg_ext'
    );
}

{
    my $filename = tempfile 'thumbnail_txt_magic_jpeg';
    my $source_image = $test_images_dir . "/magic_jpg_php.jpg";

    like(
        exception {
            $model->thumbnail( $source_image, $filename, 200 );
        },
        qr/open image failed/,
        'thumbnail: txt_jpeg_ext'
    );
}
