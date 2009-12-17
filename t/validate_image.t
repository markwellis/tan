use strict;
use warnings;

use Test::More;
use Data::Validate::Image;
use Cwd 'abs_path';

#run main
main();

# load test data
sub load_data{
    my $cwd = abs_path();
    my @images = <${cwd}/validate_image_data/images/*>;
    my @fakes = <${cwd}/validate_image_data/fakes/*>;

    my $filelist = {
        'images' => \@images,
        'fakes' => \@fakes,
    };
    return $filelist;
}

#test real images
sub test_image{
    my ($validator, $image) = @_;

    my $image_type = $validator->is_image($image);
    isnt($image_type, 0, "${image} is ${image_type}");
}

#test false images
sub test_fake{
    my ($validator, $fake) = @_;

    my $image_type = $validator->is_image($fake);
    is($image_type, 0, "${fake} image_type is 0");
}

#entry point
sub main{
    my $filelist = load_data();
    my $validator = new_ok('Data::Validate::Image');

    foreach my $image ( @{$filelist->{'images'}} ){
        test_image($validator, $image);
    }

    foreach my $fake ( @{$filelist->{'fakes'}} ){
        test_fake($validator, $fake);
    }

    done_testing();
}
