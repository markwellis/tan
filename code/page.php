<?php
require_once("user.php");
require_once("{$_SERVER['DOCUMENT_ROOT']}/lib/models/m_stash.php");

if (defined('MAGIC')) {
	class page{
	     
	    static $output;   
	
	    function __construct(){
            global $user;
            if (!$user){
                $user = &new user();
            }
            global $sql;
            if (!$sql){
                $sql = &new sql();
            }
            $this->sql = &$sql;
            $this->user = &$user;
            $this->m_stash = &new m_stash();
	    }
	
    function createMenu($tab, $type){
        $current_menu = array($tab => 'style="display:block;"');
        $current_tab = array($tab => ' tab_selected');
        $current_option = array($tab => array($type => 'class="navmenu_option_selected"' ));

        ob_start();
        ?>
            <script type="text/javascript">//<![CDATA[
                var last_tab;
                var last_menu;
                
                window.addEvent('domready', function(){
                    $$('.tab').addEvent('click', function(e) {
                        e.stop();
                        if (this.hasClass('tab_selected')){
                            return false;
                        }
                        this.addClass('tab_selected');
                        if (last_tab){
                            last_tab.removeClass('tab_selected');
                        }
                        if (last_menu){
                            $(last_menu).style.display='none';
                        }
                        $(this.title + '_menu').style.display='block';
                        
                        last_tab = this;
                        last_menu = this.title + '_menu';
                    });

                    $('<?php echo $tab ?>_menu').style.display='block';
                    last_menu = '<?php echo $tab ?>_menu';
                    last_tab = $('<?php echo $tab ?>_tab');
                });
            //]]>
            </script>
            <div id="navmenu_holder">
                <span class='tab <?php echo $current_tab['link'] ?>' title='link' id='link_tab'>Links</span><span class='tab <?php echo $current_tab['blog'] ?>' title='blog' id='blog_tab'>Blogs</span><span class='tab <?php echo $current_tab['picture'] ?>' title='picture' id='picture_tab'>Pictures</span>
                    <div id="navmenu_contents">
                    <div id='link_menu' <?php echo $current_menu['link'] ?>>
                        <ul>
                            <li class='navmenu_option'><a href='/submit/link/' <?php echo $current_option['link'][2] ?>>Submit</a></li>
                            <li class='navmenu_option'><a href='/random/link/'>Random</a></li>
                            <li class='navmenu_option'><a href='/link/0/1/' <?php echo $current_option['link'][0] ?>>Promoted</a></li>
                            <li class='navmenu_option'><a href='/link/1/1/' <?php echo $current_option['link'][1] ?>>Upcoming</a></li>
                        </ul>
                    </div>
                    <div id='blog_menu' <?php echo $current_menu['blog'] ?>>
                        <ul>
                            <li class='navmenu_option'><a href='/submit/blog/' <?php echo $current_option['blog'][2] ?>>Submit</a></li>
                            <li class='navmenu_option'><a href='/random/blog/'>Random</a></li>
                            <li class='navmenu_option'><a href='/blog/0/1/' <?php echo $current_option['blog'][0] ?>>Promoted</a></li>
                            <li class='navmenu_option'><a href='/blog/1/1/' <?php echo $current_option['blog'][1] ?>>Upcoming</a></li>
                        </ul>
                    </div>
                    <div id='picture_menu' <?php echo $current_menu['picture'] ?>>
                        <ul>
                            <li class='navmenu_option'><a href='/submit/picture/' <?php echo $current_option['picture'][2] ?>>Submit</a></li>
                            <li class='navmenu_option'><a href='/random/picture/'>Random</a></li>
                            <li class='navmenu_option'><a href='/picture/0/1/' <?php echo $current_option['picture'][0] ?>>Promoted</a></li>
                            <li class='navmenu_option'><a href='/picture/1/1/' <?php echo $current_option['picture'][1] ?>>Upcoming</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        <?php
        $menu = ob_get_contents();
        ob_clean();
        return $menu;
    }
    
# it CANNOT stay
        
        function get_recent_comments(){
            $memcache = new Memcache;
            $memcache_key = "recent_comments";
            @$memcache->connect('127.0.0.1', 11211);
            $cached = @$memcache->get($memcache_key);
                
            if (!$cached){
                $sql = &$this->sql;
                $query = "SELECT details, comment_id, username, UNIX_TIMESTAMP(date) as date, blog_id, link_id, picture_id FROM comments WHERE deleted='N' ORDER BY date DESC LIMIT 20";
                $recent_comments = $sql->query($query, 'array');
                $tmp = '<div style="overflow:hidden;"><span>Recent Comments</span><ul style="list-style:none;margin:0px;padding:0px;" class="" >';
                foreach ($recent_comments as $comment){
                    if ($comment['blog_id']) {
                        $comment_type = 'blog';
                        $object = $comment_type;
                        $comment_id = $comment['blog_id'];
                    } elseif ($comment['link_id']) {
                        $comment_type = 'link';
                        $object = $comment_type;
                        $comment_id = $comment['link_id'];
                    } elseif ($comment['picture_id']){
                        $comment_type = 'pic';
                        $object = 'picture';
                        $comment_id = $comment['picture_id'];
                    }
                    $comment_length = strlen($comment['details']);
                    $comment['ndetails'] = preg_replace("/\[quote\ user=[\"'](.+?)[\"']\](.*?)\[\/quote\]/miUs", '', $comment['details']);
                    $comment['ndetails'] = strip_tags(html_entity_decode($comment['ndetails'], ENT_QUOTES, 'UTF-8'));
                    $comment['short'] = htmlentities(mb_substr($comment['ndetails'], 0, 50, 'UTF-8'),ENT_QUOTES,'UTF-8');
                    $comment['long'] = htmlentities(mb_substr($comment['ndetails'], 0, 400, 'UTF-8'),ENT_QUOTES,'UTF-8');
                    $comment['date'] = date( 'H:i:s', $comment['date']);
                    if ( $comment['short'] !== $comment['details'] ){
                           $comment['short'] .= '...';
                    }
                    if ( $comment['long'] !== $comment['details'] ) {
                        $comment['long'] .= '...';
                    }
                    
                    $tip_title = "{$comment['username']}@{$comment['date']}::".strip_tags($comment['long']);
                    $tmp .= "<li><a style='margin:0px;padding:3px;' class='top_selection recent_comments' title='{$tip_title}' href='/view{$comment_type}/{$comment_id}/#comment{$comment['comment_id']}'>{$comment['short']}</a></li>";
                }
                $tmp .= '</ul></div>';
    
                ob_start();
                ?>
                <script type="text/javascript">//<![CDATA[
                    window.addEvent('domready', function() {  
                       
                        
                        //store titles and text  
                        $$('a.recent_comments').each(function(element,index) {  
                            var content = element.get('title').split('::');  
                            element.store('tip:title', content[0]);  
                            element.store('tip:text', content[1]);  
                        });  
    
                        //create the tooltips  
                        var tips = new Tips('.recent_comments',{  
                            'className': 'recent_comments',  
                            'hideDelay': 50,  
                            'showDelay': 50
                        });
                    });  
                //]]>
                </script>
                <?php
                $tmp .= ob_get_contents();
                ob_end_clean();
    
                @$memcache->set($memcache_key, $tmp, false, 20);
                return $tmp;
            }
            return $cached;
        }
        
# end        

	    private function createHead($title, $script, $description){
            $description = htmlentities(strip_tags($description),ENT_QUOTES,'UTF-8');
	        ob_start();
    		print  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" '
    			.'"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
				.'<html xmlns="http://www.w3.org/1999/xhtml">'
	            .'<head> '
	            ."<title>$title</title> "
	            ."<meta name='Description' content='$description'/> "
	            .'<meta name="keywords" content="news community comments english lulz lol social lulzhq fun jokes '
	            .'videos pictures share sharing lol lolz funny humour humur"/> '
	            .'<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/> '
	            .'<link rel="stylesheet" type="text/css" title="default" href="/css/default.css?2=25" /> '
	            .'<link rel="shortcut icon" href="/favicon.ico" /> '
	            .$script
	            .'</head> ';
                
			ob_end_flush();
	    }
	    
	    private function createBody($where, $type, $sortby = null){
	        $user = &$this->user;
            $ad_code = $this->get_right_ad();
            $this->output .= '<body>'
                .'<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/mootools/1.2.1/mootools-yui-compressed.js"></script>'
                .'<script type="text/javascript" src="/sys/script/mootools-1.2-more.js"></script>'
	            .'<script type="text/javascript" src="/sys/js/clientside.js?t=3"></script>'
	            .'<div id="main">'
	            .'<div id="top">'
				.'<div style="float:right;margin-top:5px;margin-right:5px;text-align:right;">';
                ob_start();
                ?>
                <script type="text/javascript">//<![CDATA[
                
                window.addEvent('domready', function() {
                    $$('.mibbit').addEvent('click', function(e) {
                        popUpWindow("https://widget.mibbit.com/?server=irc.thisaintnews.com%3A%2B6697&chatOutputShowTimes=true"
                  	  +"&channel=%23thisaintnews&settings=8a8a5ac18a22e7eecd04026233c3df93&autoConnect=true"
                	  +"&nick=<?= $user->getUsername() ?>", 720, 400);
                	e.stop();
                    });
                });
                //]]>
                </script>
                <?php
                $this->output .= ob_get_contents();
                ob_clean();
            $this->output .= '<a href="http://www.cafepress.com/thisaintnews" class="menulink">Shop</a> |'
                .'<a href="/chat/" class="menulink mibbit">Chat</a>';
    
            if ($user->isLoggedIn()){
                $this->output .= " | <a href='/logout/' class='menulink'>Logout</a>";
            }
            $this->output .= '<br/>';
	        if (!$user->isLoggedIn()){
	            $this->output .= '<a href="/login/" class="menulink">Login/Register</a> | ';
	        } else {
                $this->output .= '<a href="/user/' . $user->getUsername() . '/1/" class="menulink">My Comments</a> | <a href="/avatar/" class="menulink">Avatar</a> | ';
            }
	
	        if($_SESSION['nsfw']== 1){
	            $this->output .="<a href='/filteron/' class='menulink'>Enable NSFW filter</a>";
	        } else {
	            $this->output .="<a href='/filteroff/' class='menulink' onclick='return confirm(\"Are you sure you want to disable the NSFW work filter? There will be content which is not suitable for work\");'>Disable NSFW filter</a>";
	        }

	        $this->output .= '<br /><div style="float:right">
                <form action="http://www.google.com/cse" id="cse-search-box">
                  <div>
                    <input type="hidden" name="cx" value="017135894524023845720:-eqs9gh9cxm" />
                    <input type="hidden" name="ie" value="UTF-8" />
                    <input type="text" name="q" size="31" />
                    <input type="submit" name="sa" value="Search" />
                  </div>
                </form>
                </div>
                
                </div><div class="logoimg"/><a href="/" class="logo"></a></div>';
	        $this->output .= "</div><div id='middle'>";
            $messages = $this->m_stash->flash('message');
            if ($messages){
                foreach ($messages as $message){
                    $this->output .= "<span class='message'>{$message}</span>";
                }
            }
            $this->output .= "<div id='those_damn_dirty_evil_ads'>{$ad_code}</div> ";
	    }

        function get_right_ad(){
                ob_start();

                include(dirname(__FILE__) . '/../lib/themes/classic/templates/lib/ads/right.php');
                
                $code = ob_get_contents();
                ob_clean();
                return $code;
        }
        
        function get_left_ad(){
                ob_start();

                include(dirname(__FILE__) . '/../lib/themes/classic/templates/lib/ads/left.php');
                
                $code = ob_get_contents();
                ob_clean();
                return $code;
        }
        
        function get_bottom_ad(){
                ob_start();

                include(dirname(__FILE__) . '/../lib/themes/classic/templates/lib/ads/bottom.php');
                
                $code = ob_get_contents();
                ob_clean();
                return $code;
        }
	
	    private function closePage($footer, $where, $type, $sortby = null){
            if ($sortby){
                $sortby = "Sort by: {$sortby}";
            }
	        $this->output .= '<div id="main_menu"> '
	        	. $this->createMenu($where, $type) ."{$sortby}".$this->get_recent_comments();
            $this->output .= $this->get_left_ad();
            $this->output .= "</div> "
				.'<div id="bottom"> '
	            .'<a href="http://validator.w3.org/check?uri=referer"> '
	           .'<img src="/sys/images/valid-xhtml10.png" '
	            .'style="height:31px;width:88px;margin-top:20px;float:right;" '
	            .'alt="Valid XHTML 1.0 Transitional" /></a><br/><br/> '
		    .'<a rel="external nofollow" href="http://www.blogged.com/directory/society/news-media">'
		    .'<img src="/sys/images/blogged.gif" alt="News &amp; Media Blog Directory" title="News &amp; Media Blog Directory" /></a>'
	            ."<span style='display:block;margin-bottom:10px;'>"
	            ."$footer , All User-generated content is licensed under a " 
				.'<a href="http://creativecommons.org/">Creative Commons Public Domain license</a></span> '
	            .'</div>';
            $this->output .= $this->get_bottom_ad();
            $this->output .= '</div>'
	            .'<script src="http://www.google-analytics.com/ga.js" type="text/javascript"></script> '
	            ."<script type='text/javascript'>//<![CDATA[ \n"
	            .'var pageTracker = _gat._getTracker("UA-5148406-3"); '
	            .'pageTracker._initData(); '
	            ."pageTracker._trackPageview(); \n"
	            ."//]]>\n</script> "
	            .'</body></html>';
	    }
	
	    public function createPage($title,$header, $middle, $footer, $where, $type = -1, $sortby = null, $description = null){
	        if ($_SESSION['filteroff']== 0) {
	        //     $middle = $this->sfw($middle); 
	         //    $title = $this->sfw($title); 
	        }
	        if (!$description) {
	            $description = "We&#039;re the newest social news site. Ran by the community, for the community, no corporations involved.";
	        }
	        $this->createHead($title, $header, $description);
	        $this->createBody($where, $type, $sortby);
	        $this->output .= $middle;
	        $this->closePage($footer, $where, $type, $sortby);
	        return $this->output;
	    }
	
	    public function minify($code, $js=0){
	        if ($js){
	            $code = preg_replace(array("/(^[\/]{2}[^\n]*)|([\n]{1,}[\/]{2}[^\n]*)/"), ' ', $code);
	        }
	        return preg_replace(array("/\r/", "/\t/", "/\n/", "/\s+\ /"), ' ', $code);
	    }
	
	    public function compress($data){
	        if(strstr($_SERVER['HTTP_ACCEPT_ENCODING'],'gzip')){
	            ob_start();
	            echo $data;
	            $data=gzencode(ob_get_contents(),7);
	            ob_end_clean();
	            header('Content-Encoding: gzip');
	        }
	        return $data;
	    }
	    
	    public function sfw($content){
	        $search = array('/(f)[u](ck)/i', '/(sh)[i](t)/i', '/(c)[o](ck)/i', '/(b)[o](llocks)/i', '/(c)[u](nt)/i', '/(n)[i](gger)/i', '/(p)[a](ki)/i', '/(b)[a](stard)/i', '/(f)[a](g)/i', '/(f)[a](ggot)/i', '/(p)[i](ss)/i');
	        return preg_replace($search, '$1*$2', $content);
	    }
	}

} else {
	header('Location: /error404/');
	exit;
}
?>
