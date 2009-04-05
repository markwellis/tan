<?php
/*
 * Created on 19 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package m_mail
 */


class m_mail{
    public $to;
    public $message;
    public $subject;
    public $headers;
    public $from;

    public function send(){
        if (!$this->headers){
            $this->headers = "From: {$this->from}\r\n" .
                "Reply-To: webmaster@example.com\r\n";
        }
    mail($this->to, $this->subject, $this->message, $this->headers);
    }
    
}

?>
