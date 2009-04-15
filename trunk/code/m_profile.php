<?php
/*
 * Created on 8 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package m_profile
 */


class m_profile{
    function __construct($user_id){
        $this->user_id = (int)$user_id;
    }
    
    /**
     * gets the things the user has plus'd
     */
    function get_plus($page){
        global $sql;
        $limit = $page * OBJECT_LIMIT;
        --$page;
        $query = "SELECT SQL_CALC_FOUND_ROWS *, plus.date AS _date FROM plus STRAIGHT_JOIN {$this->location}_details "
            ."ON (plus.{$this->location}_id = {$this->location}_details.{$this->location}_id) "
            ."WHERE plus.user_id = {$this->user_id} ORDER BY _date DESC LIMIT {$page}, {$limit}";
        $plus_items = $sql->query($query, 'array');
        $query = "SELECT FOUND_ROWS() as total_rows";
        $tmp = $sql->query($query, 'row');
        $plus_items['total_rows'] = $tmp['total_rows'];
        return $plus_items;
    }
    
    /**
     * gets the things the user has minus'd
     */
    function get_minus($page){
        global $sql;
        $limit = $page * OBJECT_LIMIT;
        --$page;
        $query = "SELECT SQL_CALC_FOUND_ROWS *, minus.date AS _date FROM minus STRAIGHT_JOIN {$this->location}_details "
            ."ON (minus.{$this->location}_id = {$this->location}_details.{$this->location}_id) "
            ."WHERE minus.user_id = {$this->user_id} ORDER BY _date DESC LIMIT {$page}, {$limit}";
        $minus_items = $sql->query($query, 'array');
        $query = "SELECT FOUND_ROWS() as total_rows";
        $tmp = $sql->query($query, 'row');
        $minus_items['total_rows'] = $tmp['total_rows'];
        return $minus_items;
    }
    
    /**
     * gets the things the user has commented on
     */
    function get_comments($page){
        global $sql;
        global $user;
        $uid = $user->getUserId();
        if ($page === 1){
            $page = 0;
        }
        $page = $page * OBJECT_LIMIT;
        $limit = OBJECT_LIMIT;
        $query = "SELECT SQL_CALC_FOUND_ROWS *, UNIX_TIMESTAMP(date) AS date FROM comments WHERE user_id = {$this->user_id} ORDER BY date DESC LIMIT {$page}, {$limit}";
//        $query = "SELECT SQL_CALC_FOUND_ROWS * FROM comments WHERE user_id = {$this->user_id} ORDER BY date DESC LIMIT {$page}, {$limit}";
        $comments = $sql->query($query, 'array');
        $query = "SELECT FOUND_ROWS() as total_rows";
        $tmp = $sql->query($query, 'row');
        $comments['total_rows'] = (int)($tmp['total_rows'] / 27);
        return $comments;
    }
    
    /**
     * gets the things the user has sumbitted
     */
    function get_submitted($page){
        global $sql;
        $limit = $page * OBJECT_LIMIT;
        --$page;
        $query = "SELECT SQL_CALC_FOUND_ROWS *, date AS _date FROM {$this->location}_details "
            ."WHERE user_id = {$this->user_id} ORDER BY _date DESC LIMIT {$page}, {$limit}";
        $minus_items = $sql->query($query, 'array');
        $query = "SELECT FOUND_ROWS() as total_rows";
        $tmp = $sql->query($query, 'row');
        $minus_items['total_rows'] = $tmp['total_rows'];
        return $minus_items;
    }
}

?>