<?php
class m_edit_comment {
    function __construct($args){
        $comment_id = (int)$args[0];
        if (!$comment_id){
            die('No comment id');
        }
        $this->comment_id = $comment_id;
        
        global $m_sql;
        $this->m_sql = $m_sql;
    }
    
    /**
     * Updates the comment, assumes its been scrubbed already
     */
    function update($new_comment){
        return $this->m_sql->query("UPDATE comments SET details = ?, edited = NOW() WHERE comment_id = ? LIMIT 1", 'si', array($new_comment, $this->comment_id), 'insert');
    }
    
    /**
     * Gets the comment
     */
    function get(){
        return $this->m_sql->query("SELECT * FROM comments WHERE comment_id = ?", 'i', array($this->comment_id));
    }

    /**
     * delete the comment
     */    
    function delete(){
        return $this->m_sql->query("UPDATE comments SET deleted = 'Y', edited = NOW() WHERE comment_id = ? LIMIT 1", 'i', array($this->comment_id), 'insert');
    }
}

?>