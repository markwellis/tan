<?php
/*
 * Created on 5 Apr 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */
class image_resize{
    
    function __construct(){
        global $sql;
        $this->sql = $sql;
    }
    
    function id_to_filename($id){
        $id = (int)$id;
        $query = "SELECT filename FROM picture_details WHERE picture_id=$id;";
        $filename = $this->sql->query($query, 'row');
        return $filename['filename'];
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
                $im = &new Imagick();
                $im->readImage($filename);

                $thumb_format = trim($im->getImageFormat());
                if ($thumb_format != 'GIF' &&$thumb_format != 'PNG' ){
                    $im->setImageFormat('jpeg'); 
                }
                
                foreach ($im as $frame) { 
                    $im->thumbnailImage($newx,$newx,true);
                    
                }

                $thumb_image = $im->getImagesBlob();
                $thumb_format = $im->getImageFormat();

                @mkdir(dirname($cacheimg));

                $im->writeImages($cacheimg, 1);
                $im->clear();
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

                    $im = &new Imagick();
                    $im->readImage($cacheimg);
                    $thumb_image = $im->getImagesBlob();
                    $thumb_format = $im->getImageFormat();

                    $im->clear();
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
