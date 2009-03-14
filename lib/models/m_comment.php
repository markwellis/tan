<?php
/*
 * Created on 11 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package m_edit
 */

class m_comment {
    
    private $comments_table = 'comments';
    
    function __construct($comment_id){
        if (!$comment_id){
            die('No comment id');
        }
        $this->comment_id = (int)$comment_id;
        
        global $sql;
        $this->sql = $sql;
    }
    
    /**
     * Updates the comment, assumes its been scrubbed already
     */
    function update($new_comment){
        $query = "UPDATE {$this->comments_table} SET details = '{$new_comment}' WHERE comment_id = {$this->comment_id} LIMIT 1";
        $this->sql->query ($query, 'none');
    }
    
    /**
     * Gets the comment
     */
    function get (){
        $query= "SELECT * FROM {$this->comments_table} WHERE comment_id={$this->comment_id}";
        return $this->sql->query($query, 'row');
    }
}

?>