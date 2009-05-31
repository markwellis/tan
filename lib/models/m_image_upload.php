<?php
/*
 * Created on 3 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */

class m_image_upload {
    public $types;
    
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
            $this->uploaded_filename = "{$this->uploaded_filename}." . $this->get_image_extension();
            return $this->move_uploaded();
        }
        return $is_image;
    }
    
    /**
     * validates the image
     */    
    private function _is_an_image(){
        if ($this->image['error'] !== 0) {
            return 'Upload error';
        }

        if ($this->image['size'] > MAX_UPLOADED_PICTURE_SIZE ){
            return 'Filesize exceeded';
        }

        if (!@is_uploaded_file($this->image['tmp_name'])){
            return 'Filesize exceeded';
        }
        if ($this->types){
            if (!in_array($this->image['type'], $this->types, true)){
                return 'Incorrect Image Format';
            }
        }

        // if we cant get the image resolution, its not an image.
        $res = @getimagesize($this->image['tmp_name']);
        if (!$res){
            return 'Not an image';
        }
        $this->meta = array($res[0], $res[1], $this->image['size'] / 1024);
        return true;
    }

    /**
     * Moves the image to the correct location
     */
    private function move_uploaded(){
        if (!move_uploaded_file($this->image['tmp_name'], $this->uploaded_filename)) {
            return 'Error Uploading';
        }
        return true;
    }

    private function get_image_extension(){
        $image_types = array( 
            null,
            'gif',
            'jpg',
            'png',
            'swf',
            'psd',
            'bmp',
            'tiff',
            'tiff',
            'jpc',
            'jp2',
            'jpx',
            'jb2',
            'swc',
            'iff',
            'wbmp',
            'xbm',
         );
         return $image_types[exif_imagetype($this->image['tmp_name'])];
    }

}

?>