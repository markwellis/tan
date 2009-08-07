<?php
/*
 * Created on 5 Apr 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */
class m_image_resize{
    
    function __construct(){
        global $m_sql;
        $this->m_sql = $m_sql;
    }
    
    function id_to_filename($id){
        $id = (int)$id;
        $query = "SELECT filename FROM picture_details WHERE picture_id = ?";
        $filename = $this->m_sql->query($query, 'i', array($id));
        return $filename[0]['filename'];
    }
    
    function resize($id, $newx){
        $newx = abs($newx);
        $allowed_sizes = array(100, 150, 160, 200, 250, 300, 400, 500, 600);
        if (in_array($newx, $allowed_sizes, 1)){
            $cacheimg = $_SERVER['DOCUMENT_ROOT']."/images/cache/resize/$id/$newx";

            if (file_exists($cacheimg)){
                $usecache = 1;
            }else {
                $basefile = $this->id_to_filename($id);
                $filename = $_SERVER['DOCUMENT_ROOT'] . '/images/pics/' . basename($basefile);
                $usecache = 0;
            }

            if ( !$usecache && $basefile && file_exists($filename) ){
                $im = new Imagick();
                $im->pingImage($filename);
                
                // I don't like this, but 1 week later its the best i can come up with.
                $im_details = $im->identifyImage(1);
                $matches = (array)null;
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
            }else {
                if (file_exists($cacheimg)){
                    $last_modified_time = filemtime($cacheimg);
                    $etag = '"'.$last_modified_time.'"';
                    $expires_time= time()+(60*60*24*365);
        
                    header("Last-Modified: ".gmdate("D, d M Y H:i:s", $last_modified_time)." GMT");
                    header("Etag: $etag");
                    header("Expires: ".gmdate("D, d M Y H:i:s", $expires_time)." GMT");
                    header('Cache-Control: maxage='.(60*60*24*365*10).', public');
                    if (@strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']) == $last_modified_time ||
                        (isset($_SERVER['HTTP_IF_NONE_MATCH']) && trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag) ) {
                            header("HTTP/1.1 304 Not Modified");
                            exit();
                    }

                    $im = new Imagick($cacheimg);
                    $thumb_image = $im->getImagesBlob();
                    $thumb_format = $im->getImageFormat();

                    $im->destroy();
                } else {
                    exit();
                }
            }
            return array($thumb_image, $thumb_format);
        } else {
                exit();
        }
    }
}
?>
