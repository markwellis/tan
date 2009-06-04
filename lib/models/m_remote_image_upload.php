<?php
if (defined('MAGIC')) {
    class m_remote_image_upload {
        var $image;
        private $ch;

        function __construct($remote_image, $filename){
            if (!$remote_image){
                die("no image");
            }
            $this->remote_image = $remote_image;
            $this->uploaded_filename = $filename;

            $this->ch = curl_init($remote_image);
            $curl_options = array(
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_HEADER         => false,
                CURLOPT_FOLLOWLOCATION => true,
                CURLOPT_ENCODING       => "utf-8",
                CURLOPT_USERAGENT      => $_SERVER['HTTP_USER_AGENT'],
                CURLOPT_AUTOREFERER    => true,
                CURLOPT_CONNECTTIMEOUT => 5,
                CURLOPT_TIMEOUT        => 5,
                CURLOPT_MAXREDIRS      => 5,
                CURLOPT_FAILONERROR    => true,
                CURLOPT_REFERER        => $remote_image,
            );
            
            curl_setopt_array($this->ch, $curl_options);
        }
        
        public function upload(){
            if (preg_match('/thisaintnews/', $this->remote_image)){
            	return "Don't be daft.";
            }
            $this->get_head();
            return $this->validate_and_save();
        }
        
        private function validate_and_save(){
            if ($this->image['download_content_length'] > MAX_UPLOADED_PICTURE_SIZE){
                return 'Filesize exceeded';
            }

            $this->fetch();

            if ($this->image['error']){
                return $this->image['error'];
            }

            // save the image, then check its a real image
            $this->save();

            $res = @getimagesize($this->image['filename']);
            if (!$res){
                unlink($this->image['filename']);
                return 'Not an image';
            }
            
            $this->meta = array($res[0], $res[1], $this->image['download_content_length'] / 1024);
            return true;
        }
        
        private function save(){
            $this->image['filename'] = $this->uploaded_filename;

            $fh = fopen($this->image['filename'], 'wb');
            fwrite($fh, $this->image_data);
            fclose($fh);

            $this->image['filename'] = "{$this->image['filename']}." . $this->get_image_extension();
            rename($this->uploaded_filename, $this->image['filename']);
            $this->uploaded_filename = $this->image['filename'];
        }
        
        private function get_head(){
            curl_setopt($this->ch, CURLOPT_NOBODY, true);

            $head = curl_exec($this->ch);
            $this->image = curl_getinfo($this->ch);
            $this->image['error'] = curl_error($this->ch);
            $this->image['error_no'] = curl_errno($this->ch);
        }
        
        private function fetch(){
            curl_setopt($this->ch, CURLOPT_HTTPGET, true);

            $content = curl_exec($this->ch);
            $this->image = curl_getinfo($this->ch);
            $this->image['error'] = curl_error($this->ch);
            $this->image['error_no'] = curl_errno($this->ch);
            $this->image_data = $content;

            curl_close($this->ch);
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
             return $image_types[exif_imagetype($this->uploaded_filename)];
        }
    }
}
?>
