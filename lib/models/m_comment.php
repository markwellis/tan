<?php
/*
 * Created on 11 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package m_edit
 */

class m_comment {
    function __construct($comment_id){
        if (!$comment_id){
            die('No comment id');
        }
        $this->comment_id = (int)$comment_id;
        
        global $m_sql;
        $this->m_sql = $m_sql;
    }
    
    /**
     * Updates the comment, assumes its been scrubbed already
     */
    function update($new_comment){
        $query = "UPDATE comments SET details = ?, edited = NOW() WHERE comment_id = ? LIMIT 1";
        return $this->m_sql->query($query, 'si', array($new_comment, $this->comment_id), 'insert');
    }
    
    /**
     * Gets the comment
     */
    function get(){
        $query= "SELECT * FROM comments WHERE comment_id = ?";
        return $this->m_sql->query($query, 'i', array($this->comment_id));
    }

    /**
     * delete the comment
     */    
    function delete(){
        $query = "UPDATE comments SET deleted = 'Y', edited = NOW() WHERE comment_id = ? LIMIT 1";
        return $this->m_sql->query($query, 'i', array($this->comment_id), 'insert');
    }
}

?>