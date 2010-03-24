<?php
    $username = $m_stash->m_user->username();
    if (!$username) {
        $username = 'n00b';
    }
?>
<body>
    <?php load_template('lib/js_includes'); ?>
    <div id="main">
        <div id="top">
            <div style="float:right;margin-top:5px;margin-right:5px;text-align:right;width:380px;">
<form action="https://www.paypal.com/cgi-bin/webscr" method="post" style="float:right;margin-left:5px;">
<input type="hidden" name="cmd" value="_xclick">
<input type="hidden" name="business" value="donate@thisaintnews.com">
<input type="hidden" name="item_name" value="TAN Donation">
<input type="hidden" name="currency_code" value="GBP">
<input type="hidden" name="tax" value="0">
<input type="image" src="https://www.paypal.com/images/x-click-but04.gif" 
       border="0"
name="submit" alt="SEND ME MONIES!1!!">
</form>
                <script type="text/javascript">
                    //<![CDATA[
                        window.addEvent('domready', function() {
                            $$('.mibbit').addEvent('click', function(e) {
                                popUpWindow("https://widget.mibbit.com/?server=irc.thisaintnews.com%3A%2B6697&chatOutputShowTimes=true&autoConnect=true"
                              +"&channel=%23thisaintnews&settings=8a8a5ac18a22e7eecd04026233c3df93"
                              +"&nick=<?php echo $username ?>", 720, 400);
                            e.stop();
                            });
                        });
                    //]]>
                </script>
                <?php if ( $m_stash->m_user->admin() ){ ?>
                    <a href="/admin" class="top_link">Admin</a> |
                <?php } ?>
 
                <a href="http://stats.thisaintnews.com" class="top_link">Stats</a> | <a href="/chat/" class="top_link mibbit">Chat</a>
                <?php if ($m_stash->m_user->logged_in()){ ?>
                     | <a href='/logout/' class='top_link'>Logout</a>
                <?php } ?>
                <br/>
                
                <?php if (!$m_stash->m_user->logged_in()){ ?>
                    <a href="/login/" class="top_link">Login/Register</a> | 
                <?php } else { ?>
                    <a href="/user/<?php echo $m_stash->m_user->username() ?>/1/" class="top_link">My Comments</a> | <a href="/avatar/" class="top_link">Avatar</a> | 
                <?php } ?>
            
                <?php if(isset($_SESSION['nsfw'])){ ?>
                    <a href='/filteron/' class='top_link'>Enable NSFW filter</a>
                <?php } else { ?>
                    <a href='/filteroff/' class='top_link' onclick='return confirm("Are you sure you want to disable the NSFW work filter? There will be content which is not suitable for work");'>Disable NSFW filter</a>
                <?php } ?>
                <br />
                <div style="float:right">
                    <form action="http://www.google.com/cse" id="cse-search-box">
                        <div>
                            <input type="hidden" name="cx" value="017135894524023845720:-eqs9gh9cxm" />
                            <input type="hidden" name="ie" value="UTF-8" />
                            <input type="text" name="q" size="31" />
                            <input type="submit" name="sa" value="Search" />
                        </div>
                    </form>
                </div>
            </div>
            <div class="logoimg"/><a href="/" class="logo"></a></div>
        </div>
        <div id='middle'>
        <?php load_template('lib/ads/right'); ?>
