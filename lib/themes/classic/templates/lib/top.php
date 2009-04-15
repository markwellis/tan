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
            <div style="float:right;margin-top:5px;margin-right:5px;text-align:right;">
                <script type="text/javascript">
                    //<![CDATA[
                        window.addEvent('domready', function() {
                            $$('.mibbit').addEvent('click', function(e) {
                                popUpWindow("http://embed.mibbit.com/?server=irc.newnet.net&chatOutputShowTimes=true"
                              +"&channel=%23thisaintnews&settings=8a8a5ac18a22e7eecd04026233c3df93t"
                              +"&nick=<?php echo $username ?>", 720, 400);
                            e.stop();
                            });
                        });
                    //]]>
                </script>
                <a href="http://www.cafepress.com/thisaintnews" class="top_link">Shop</a> | <a href="/chat/" class="top_link mibbit">Chat</a> | <a href="http://forums.thisaintnews.com" class="top_link">Forum</a>
                <?php if ($m_stash->m_user->logged_in()){ ?>
                     | <a href='/logout/' class='top_link'>Logout</a>
                <?php } ?>
                <br/>
                
                <?php if (!$m_stash->m_user->logged_in()){ ?>
                    <a href="/login/" class="top_link">Login/Register</a> | 
                <?php } else { ?>
                    <a href="/user/' . $user->getUsername() . '/1/" class="top_link">My Comments</a> | <a href="/avatar/" class="top_link">Avatar</a> | 
                <?php } ?>
            
                <?php if($_SESSION['nsfw'] == 1){ ?>
                    <a href='/filteron/' class='top_link'>Enable NSFW filter</a>
                <?php } else { ?>
                    <a href='/filteroff/' class='top_link' onclick='return confirm("Are you sure you want to disable the NSFW work filter? The ads will switch to adult mode, and there will be content which is not suitable for work");'>Disable NSFW filter</a>
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
        <?php load_template('lib/right_ad'); ?>