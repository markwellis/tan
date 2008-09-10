<?php
	/*
	* phpBBCode
	*
	* @website   www.swaziboy.com
	* @author    Duncan Mundell
	* @updated   03/2003
	* @version   1.0a
	*/
	
	function BBCode($Text) {
		
		// Replace any html brackets with HTML Entities to prevent executing HTML or script
		// Don't use strip_tags here because it breaks [url] search by replacing & with amp
		$Text = str_replace("<", "&lt;", $Text);
		$Text = str_replace(">", "&gt;", $Text);
		
		// Convert new line chars to html <br /> tags
		$Text = nl2br($Text);
		
		// Set up the parameters for a URL search string
		$URLSearchString = " a-zA-Z0-9\:\/\-\?\&\.\=\_\~\#\'";
		
		// Perform URL Search
		$Text = preg_replace("/\[url\]([$URLSearchString]*)\[\/url\]/", '<a href="$1" target="_blank">$1</a>', $Text);
		$Text = preg_replace("(\[url\=([$URLSearchString]*)\](.+?)\[/url\])", '<a href="$1" target="_blank">$2</a>', $Text);
		
		// Check for bold text
		$Text = preg_replace("(\[b\](.+?)\[\/b])is",'<span class="bold">$1</span>',$Text);
		
		// Check for Italics text
		$Text = preg_replace("(\[i\](.+?)\[\/i\])is",'<span class="italics">$1</span>',$Text);
		
		// Check for Underline text
		$Text = preg_replace("(\[u\](.+?)\[\/u\])is",'<span class="underline">$1</span>',$Text);
		
		// Check for strike-through text
		$Text = preg_replace("(\[s\](.+?)\[\/s\])is",'<span class="strikethrough">$1</span>',$Text);
		
		// Check for colored text
		$Text = preg_replace("(\[color=(.+?)\](.+?)\[\/color\])is","<span style=\"color: $1\">$2</span>",$Text);
		
		// Images
		// [img]pathtoimage[/img]
		$Text = preg_replace("/\[img\](.+?)\[\/img\]/", '<img src="$1" alt="phpbbimage"/>', $Text);
		
		// [img=widthxheight]image source[/img]
		$Text = preg_replace("/\[img\=([0-9]*)x([0-9]*)\](.+?)\[\/img\]/", '<img src="$3" alt="phpbbimage" height="$2" width="$1" />', $Text);

        // YouTube/
// old        $Text = preg_replace("/\[youtube\](.+?)\[\/youtube\]/", '<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/$1&amp;hl=en&amp;fs=1"></param><param name="allowFullScreen" value="true"></param><embed src="http://www.youtube.com/v/$1&amp;hl=en&amp;fs=1" type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344"></embed></object>', $Text);
        $Text = preg_replace("/\[youtube\](.+?)\[\/youtube\]/", '<object type="application/x-shockwave-flash" style="width:425px; height:350px;" data="http://www.youtube.com/v/$1"><param name="movie" value="http://www.youtube.com/v/$1" /></object>', $Text);
		
		return $Text;
	}
?>
