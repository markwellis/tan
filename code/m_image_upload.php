<?php
/*
 * Created on 3 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */

class m_image_upload {
    function __construct($image, $filename){
        if (!$image){
            die("no image");
        }
        if (!$filename){
            die("no filename");
        }
        
        $this->image = $image;
        $this->uploaded_filename = $filename;
    }
    
    function upload() {
        $is_image = $this->_is_an_image();
        
        if($is_image === true) {
            return $this->move_uploaded();
        }
        return $is_image;
    }
    
    /**
     * validates the image
     */    
    function _is_an_image(){
        /**
         * Return codes
         * 1: Success
         * -1: Filesize exceeded
         * -2: Upload error
         * -3: Not an image
         * -4: Not a jpg
         */
        if ($this->image['error'] !== 0) {
            return -2;
        }

        if ($this->image['size'] > MAX_UPLOADED_PICTURE_SIZE ){
            return -1;
        }

        if (!@is_uploaded_file($this->image['tmp_name'])){
            return -1;
        }

        if($this->image['type'] !== "image/jpeg"){
            return -4;
        }

        // if we cant get the image resolution, its not an image.
        $res = @getimagesize($this->image['tmp_name']);
        if (!$res){
            return -3;
        }
        return true;
    }

    /**
     * Moves the image to the correct location
     */
    function move_uploaded(){
        if (!move_uploaded_file($this->image['tmp_name'], $this->uploaded_filename)) {
            return null;
        }
        return $this->uploaded_file;
    }    
}

?>