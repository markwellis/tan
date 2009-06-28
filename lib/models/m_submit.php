<?php
if (defined('MAGIC')) {
    class m_submit {
        private $title_min = 5;
        private $desc_min = 5;
        private $title_max = 100;
        private $desc_max = 1000;
        private $blog_min = 20;

        function __construct($location, $edit = null){
            if (!$location){
                die('no location');
            }
            $this->location = $location;
            $this->edit = $edit;

            global $m_sql;
            $this->m_sql = &$m_sql;
        }
        
        function submit($data){
            if ($this->location === 'link'){
               if (isset($data[5]) && preg_match('/thisaintnews/', $data[5])){
                   return "Don't be daft.";
               }
            }
            $this->data = $data;
            $is_valid = $this->is_valid();
            if ($is_valid === null){
                if ($this->edit){
                    $id = $this->update();
                } else {
                    $id = $this->insert();
                    $m_plusminus = load_model('m_plusminus', array($this->location));
                    $m_plusminus->add_plus($data[3],$id);
                }
                return $id;
            }
            return $is_valid;
        }
        
        function insert(){
            switch ($this->location){
                case 'link':
                    $query = 'INSERT INTO link_details (title, description, category, user_id, username, url, date) VALUES (?, ?, ?, ?, ?, ?, NOW())';
                    $id = $this->m_sql->query($query, 'ssiiss', $this->data, 'insert');
                    break;
                case 'blog':
                    $query = 'INSERT INTO blog_details (title, description, category, user_id, username, details, date) VALUES (?, ?, ?, ?, ?, ?, NOW())';
                    $id = $this->m_sql->query($query, 'ssiiss', $this->data, 'insert');
                    break;
                case 'picture':
                    $query = 'INSERT INTO picture_details (title, description, category, user_id, username, filename, x, y, size, NSFW, date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())';
                    $id = $this->m_sql->query($query, 'ssiissiids', $this->data, 'insert');
                    break;
            }
            return $id;
        }
        
        function update(){
            switch ($this->location){
                case 'link':
                    $query = 'UPDATE link_details SET title = ?, description = ?, category = ? WHERE link_id = ?';
                    $this->m_sql->query($query, 'ssii', $this->data, 'insert');
                    break;
                case 'blog':
                    $query = 'UPDATE blog_details SET title = ?, description = ?, category = ?, details = ? WHERE blog_id = ?';
                    $this->m_sql->query($query, 'ssisi', $this->data, 'insert');
                    break;
                case 'picture':
                    $query = 'UPDATE picture_details SET title = ?, description = ?, category = ?, NSFW = ? WHERE picture_id = ?';
                    $this->m_sql->query($query, 'ssisi', $this->data, 'insert');
                    break;
            }
            return 0;
        }
        
        function is_valid(){
            $data = &$this->data;
            
            $error_codes = array(
                0  => 'Title cannont be blank',
                1  => 'Description cannot be blank',
                2  => "Title cannot be over {$this->title_max} characters",
                3  => "Description cannot be over {$this->desc_max} characters",
                4  => "Title must be over {$this->title_min} characters",
                5  => "Description must be over {$this->desc_min} characters",
                6  => 'Url is invalid',
                7  => 'This link has already been submitted',
                8 => "Blog must be over {$this->blog_min} characters",
            );

            if ($data[0] === '') {
                return $error_codes[0];
            }
            if (strlen($data[0]) > $this->title_max) {
                return $error_codes[2];
            }
            if (strlen($data[1]) > $this->desc_max) {
                return $error_codes[3];
            }
            if (strlen($data[0]) < $this->title_min) {
                return $error_codes[4];
            }

            switch ($this->location) {
                case 'link':
                    if ($data[1] === '') {
                        return $error_codes[1];
                    }
                    if (strlen($data[1]) < $this->desc_min) {
                        return $error_codes[5];
                    }
                    if (!$this->edit){
                        if (!preg_match('/^(http|https|ftp):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?/i', $data[5])) {
                            return $error_codes[6];
                        }
        
                        $query = "SELECT link_id FROM link_details WHERE url = ?";
                        $res = $this->m_sql->query($query, 's', array($data[5]), 'count'); 
                        if ($res){ 
                            return $error_codes[7];
                        }
                    }
                    break;
                case 'blog':
                    if (strlen($data[1]) < $this->desc_min) {
                        return $error_codes[5];
                    }
                    if ($this->edit){
                        if (strlen($data[3]) < $this->blog_min) {
                            return $error_codes[8];
                        }
                    } else {
                        if (strlen($data[5]) < $this->blog_min) {
                            return $error_codes[8];
                        }
                    }
                    break;
            } 
            return null;
        }
    }
}
?>
