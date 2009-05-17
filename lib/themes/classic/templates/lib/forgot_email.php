<html>
<br />
Your username is: <?php echo $m_stash->username ?><br />
<br />
Please click <a href='http://<?php echo $_SERVER['HTTP_HOST'] ?>/forgot_confirm/<?php echo $m_stash->user_id ?>/<?php echo $m_stash->token ?>/'>here</a> to reset your password if you need to.<br/>
or copy and paste http://<?php echo $_SERVER['HTTP_HOST'] ?>/forgot_confirm/<?php echo $m_stash->user_id ?>/<?php echo $m_stash->token ?>/ into your browsers address bar<br />
<br />
Thanks for registering<br />
</html>