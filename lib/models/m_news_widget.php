<?php
/*
 * Created on 18 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package m_registration
 */

class m_news_widget{
    function __construct(){
        global $m_sql;
        $this->m_sql = &$m_sql;
    }

    public function recent(){
        global $m_cache;
        $recent = $m_cache->get('news_widget_recent');
        if (!$recent){
            $query = "SELECT link_id AS id, 'link' AS type, title, description, UNIX_TIMESTAMP(promoted) AS promoted FROM link_details "
                ."UNION SELECT picture_id AS id, 'pic' AS type, title, description, UNIX_TIMESTAMP(promoted) AS promoted FROM picture_details "
                ."UNION SELECT blog_id AS id, 'blog' AS type, title, description, UNIX_TIMESTAMP(promoted) AS promoted FROM blog_details "
                ."ORDER BY promoted DESC LIMIT 10";
            
            $recent = $this->m_sql->query($query, null, null);
            $m_cache->set('news_widget_recent', $recent, 15 * ONE_MIN);
        }
        return $recent;
    }
}
?>
