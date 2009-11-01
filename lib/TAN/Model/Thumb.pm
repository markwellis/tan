package TAN::Model::Thumb;

use strict;
use warnings;
use parent 'Catalyst::Model';
use Image::Magick;

sub resize(){
    my ( $self, $filename, $cacheimg, $newx) = @_;

    $newx = abs($newx);
    
    if ($newx == 100 || $newx == 150 || $newx == 160 || $newx == 200 || $newx == 250 || $newx == 300 || $newx == 400 || $newx == 500 || $newx == 600){

        if ( -e $filename ){
            my $im = Image::Magick->new();

            $im->Read($filename) || Catalyst::Exception->throw("Failed to read image ${filename}");

            my $magick = $im->Get('magick');
            $im->Set('magick' => 'jpeg') if ( ($magick ne 'jpeg') && ($magick ne 'png') );
            $im->Thumbnail("${newx}x${newx}");
            $im->Write($cacheimg);
            return $im->ImageToBlob();
        }
    }
}

=head1 NAME


        preg_match('/Scene: \d+ of (\d+)/', $im_details['rawOutput'], &$matches);
        $scenes = isset($matches[1]) ? (int)$matches[1] : 0;
        $thumb_format = strtolower(preg_replace('/(\w+).*/', '$1', $im_details['format']));
                
        @mkdir(dirname($cacheimg));

        if (($im_details['geometry']['width'] > $newx) || ($thumb_format === 'gif' && $scenes)){
            if ($thumb_format === 'gif'){
                // gif
                $sample = (string)null;
                $o_newx = (int)$newx;

                if ($im_details['geometry']['width'] > $newx){
                    $newx = $newx * ($im_details['geometry']['width'] / $im_details['geometry']['height']);
                    $newx = ($newx > $o_newx) ? $o_newx : $newx;
    
                    $newy = $newx * ($im_details['geometry']['height'] / $im_details['geometry']['width']);
                            
                    $sample = "-sample {$newx}x{$newy}";
                }
                $scene_limit = (int)($o_newx / 10);
                        
                $extra = ($scenes > $scene_limit) ? "[0-{$scene_limit}]" : (string)null; 
                $res = exec("convert {$filename}{$extra} -coalesce {$sample} -layers Optimize {$cacheimg}");

                $im->destroy();
                if (file_exists($cacheimg)){
                    $im->readImage($cacheimg);
                } else {
                    error_log($res);
                }
                $thumb_image = $im->getImagesBlob();
            } else {
                // regular
                $im->readImage($filename);
                $thumb_format = 'jpeg';
                $im->setImageFormat($thumb_format); 
                $im->thumbnailImage($newx, $newx, true);
                $im->writeImage($cacheimg);
                $thumb_image = $im->getImageBlob();
            }
        } else {
            $im->readImage($filename);
                
            $thumb_format = ($thumb_format === 'gif') ? 'gif' : 'jpeg';
            $im->setImageFormat($thumb_format); 
            $thumb_image = $im->getImageBlob();
        }

        $im->destroy();
        
    }
    return array($thumb_image, $thumb_format);

TAN::Model::Thumb - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
