<?php
require_once("user.php");

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
	    }
	
	    function createMenu($where, $type){
    	    $selclass = ' mainselected';
            $subclass = ' subselected';
            
    	    $linkmenu = null;
     	    $picturemenu = null;
    	    $blogmenu = null;
    
            if ($where == 'link'){
                $menu = & $linkmenu;
                $lselected = & $selclass;
                if ($type === 0){$plink = & $subclass;}
                if ($type === 1){$ulink = & $subclass;}
                $lnav = " lnav";
            }
            if ($where == 'picture'){
                $menu = & $picturemenu;
                $pselected = & $selclass;
                if ($type === 0){$ppic = & $subclass;}
                if ($type === 1){$upic = & $subclass;}
                $pnav = " pnav";
            }
            if ($where == 'blog'){
                $menu = & $blogmenu;
                $bselected = & $selclass;
                if ($type === 0){$pblog = & $subclass;}
                if ($type === 1){$ublog = & $subclass;}
                $bnav = " bnav";
            }
            if ($where == 'submit'){
                if ($type === 0){
                    $lselected = & $selclass;
                    $menu = & $linkmenu;
                    $lsub = & $subclass;
                }
                if ($type === 1){
                    $pselected = & $selclass;
                    $menu = & $picturemenu;
                    $psub = & $subclass;
                }
                if ($type === 2){
                    $bselected = & $selclass;            
                    $menu = & $blogmenu;
                    $bsub = & $subclass;
                }
            }

//        $allmenu = "<a href='/random/all/' class='nav anav'>Random</a>
//            <a href='/all/0/1/' class='nav anav'>Promoted</a> 
//            <a href='/all/1/1/' class='nav anav'>Upcoming</a>";

            $blogmenu = "<a href='/submit/blog/' class='nav bnav $bsub'>Submit</a><br/>
                <a href='/random/blog/' class='nav bnav'>Random</a><br/>
                <a href='/blog/0/1/' class='nav  bnav $pblog'>Promoted</a><br/>
                <a href='/blog/1/1/' class='nav bnav $ublog'>Upcoming</a>";
    
            $picturemenu = "<a href='/submit/picture/' class='nav pnav $psub'>Submit</a><br/>"
                ."<a href='/random/picture/' class='nav pnav'>Random</a><br/>"
                ."<a href='/picture/0/1/' class='nav pnav $ppic'>Promoted</a><br/>"
                ."<a href='/picture/1/1/' class='nav pnav $upic'>Upcoming</a>";
    //            ."<a href='http://nsfw.thisaintnews.com/picture/0/1/' class='nav pnav'>NSFW</a>";
    
            $linkmenu = "<a href='/submit/link/' class='nav lnav $lsub'>Submit</a><br/>
                <a href='/random/link/' class='nav lnav'>Random</a><br/>
                <a href='/link/0/1/' class='nav lnav $plink'>Promoted</a><br/> 
                <a href='/link/1/1/' class='nav lnav $ulink'>Upcoming</a>";
    
            $mainmenu = //"<div style='display:none' id='allmenu'>$allmenu</div>
                "<div style='display:none' id='blogmenu'>$blogmenu</div>
                <div style='display:none' id='picturemenu'>$picturemenu</div>
                <div style='display:none' id='linkmenu'>$linkmenu</div>
                <div style='float:right;text-align:right;'>";
    //            <a href='#' onclick=\"changeMenu('all')\" id='alllink' class='nav anav $aselected'>All</a>
    
            $mainmenu .= "<a href='#' onclick=\"changeMenu('link');return false;\" id='linklink' class='nav lnav $lselected'>Links</a>"
                . "<a href='#' onclick=\"changeMenu('blog');return false;\" id='bloglink' class='nav bnav $bselected'>Blogs</a>"
                . "<a href='#' onclick=\"changeMenu('picture');return false;\" id='picturelink' class='nav pnav $pselected'>Pictures</a>"
                . "<span id='menuholder' class='$lnav $pnav $bnav'>$menu</span></div>";
    
            return $mainmenu;
    	}
    
# it CANNOT stay
        
        function get_recent_comments(){
            $memcache = new Memcache;
            $memcache_key = "recent_comments";
            @$memcache->connect('127.0.0.1', 11211);
            $cached = @$memcache->get($memcache_key);
                
            if (!$cached){
                $sql = &$this->sql;
                $query = "SELECT details, comment_id, username, UNIX_TIMESTAMP(date) as date, blog_id, link_id, picture_id FROM comments ORDER BY date DESC LIMIT 20";
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
                    $comment['details'] = preg_replace("/\[quote\ user=[\"'](.+?)[\"']\](.*?)\[\/quote\]/miUs", '', $comment['details']);
                    $comment['details'] = htmlentities(strip_tags($comment['details']), ENT_QUOTES,'UTF-8');
                    $comment['short'] = substr($comment['details'], 0, 50);
                    $comment['long'] = substr($comment['details'], 0, 400);
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
                            className: 'recent_comments',  
                            hideDelay: 50,  
                            showDelay: 50,
                        });
                    });  
                //]]></script>
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
	            .'<link rel="stylesheet" type="text/css" title="default" href="/css/default.css?2=11" /> '
	            .'<link rel="shortcut icon" href="/favicon.ico" /> '
	            .$script
	            .'</head> ';
                
			ob_end_flush();
	    }
	    
	    private function createBody($where, $type, $sortby = null){
	        $user = &$this->user;
            $ad_code = $this->get_ad_code($where);
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
        popUpWindow("http://embed.mibbit.com/?server=irc.newnet.net&chatOutputShowTimes=true"
  	  +"&channel=%23thisaintnews&settings=8a8a5ac18a22e7eecd04026233c3df93t"
	  +"&nick=<?= $user->getUsername() ?>", 720, 400);
	e.stop();
    });
});
//]]></script>
<?php
$this->output .= ob_get_contents();
ob_clean();
            $this->output .= '<a href="http://www.cafepress.com/thisaintnews" class="menulink">Shop</a> |'
                .'<a href="/chat/" class="menulink mibbit">Chat</a> | '
                .'<a href="http://forums.thisaintnews.com" class="menulink">Forum</a>';
    
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
	            $this->output .="<a href='/filteroff/' class='menulink'>Disable NSFW filter</a>";
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

<script type="text/javascript" src="http://www.google.com/coop/cse/brand?form=cse-search-box&amp;lang=en"></script></div>
</div><div class="logoimg"/><a href="/" class="logo"></a></div>';
	        $this->output .= "</div><div id='middle'>"
                ."<div id='those_damn_dirty_evil_ads'>{$ad_code}</div> ";
	    }

function get_ad_code($where){
    if ($_SESSION['nsfw'] && $where === 'picture'){
        ob_start();
        ?>
<!-- Begin: Black Label Ads, Generated: 2009-03-29 9:54:20  -->
<script type="text/javascript">//<![CDATA[
var AdBrite_Title_Color = '0000FF';
var AdBrite_Text_Color = '000000';
var AdBrite_Background_Color = '808080';
var AdBrite_Border_Color = 'CCCCCC';
var AdBrite_URL_Color = '008000';
try{var AdBrite_Iframe=window.top!=window.self?2:1;var AdBrite_Referrer=document.referrer==''?document.location:document.referrer;AdBrite_Referrer=encodeURIComponent(AdBrite_Referrer);}catch(e){var AdBrite_Iframe='';var AdBrite_Referrer='';}
//]]></script>
<script type="text/javascript">//<![CDATA[
document.write(String.fromCharCode(60,83,67,82,73,80,84));document.write(' src="http://ads.adbrite.com/mb/text_group.php?sid=1104667&zs=3132305f363030&ifr='+AdBrite_Iframe+'&ref='+AdBrite_Referrer+'" type="text/javascript">');document.write(String.fromCharCode(60,47,83,67,82,73,80,84,62));
//]]></script>
<div><a target="_top" href="http://www.adbrite.com/mb/commerce/purchase_form.php?opid=1104667&afsid=55544" style="font-weight:bold;font-family:Arial;font-size:13px;">Your Ad Here</a></div>
<!-- End: Black Label Ads -->      
        <?php
        $code = ob_get_contents();
        ob_clean();
        return $code;
    } else {
        ob_start();
        ?>
<!-- Begin: AdBrite, Generated: 2009-03-29 9:52:20  -->
<script type="text/javascript">//<![CDATA[
var AdBrite_Title_Color = '0000FF';
var AdBrite_Text_Color = '000000';
var AdBrite_Background_Color = '808080';
var AdBrite_Border_Color = 'CCCCCC';
var AdBrite_URL_Color = '008000';
try{var AdBrite_Iframe=window.top!=window.self?2:1;var AdBrite_Referrer=document.referrer==''?document.location:document.referrer;AdBrite_Referrer=encodeURIComponent(AdBrite_Referrer);}catch(e){var AdBrite_Iframe='';var AdBrite_Referrer='';}
//]]></script>
<script type="text/javascript">//<![CDATA[
document.write(String.fromCharCode(60,83,67,82,73,80,84));document.write(' src="http://ads.adbrite.com/mb/text_group.php?sid=1104661&zs=3132305f363030&ifr='+AdBrite_Iframe+'&ref='+AdBrite_Referrer+'" type="text/javascript">');document.write(String.fromCharCode(60,47,83,67,82,73,80,84,62));
//]]></script>
<div><a href="http://www.adbrite.com/mb/commerce/purchase_form.php?opid=1104661&afsid=1" style="font-weight:bold;font-family:Arial;font-size:13px;">Your Ad Here</a></div>
<!-- End: AdBrite -->
        <?php
        $code = ob_get_contents();
        ob_clean();
        return $code;
    }
}
	
	    private function closePage($footer, $where, $type, $sortby = null){
            if ($sortby){
                $sortby = "Sort by: {$sortby}";
            }
	        $this->output .= '<div id="main_menu"><div id="menu_holder"> '
	        	. $this->createMenu($where, $type) ."</div>{$sortby}".$this->get_recent_comments()."</div> "
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
	            .'</div></div>'
	            .'<script src="/sys/script/ga.js" type="text/javascript"></script> '
	            .'<script type="text/javascript">//<![CDATA[ '
	            .'var pageTracker = _gat._getTracker("UA-5148406-3"); '
	            .'pageTracker._initData(); '
	            .'pageTracker._trackPageview(); '
	            .'//]]></script> '
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
