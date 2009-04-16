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
    public $from = 'noreply@thisaintnews.com';

    public function send(){
        if (!$this->headers){
            $this->headers = "From: {$this->from}\r\n" .
                "Reply-To: webmaster@thisaintnews.com\r\n" . 
                "MIME-Version: 1.0\r\n" .
                "Content-type: text/html; charset=utf-8\n\r\n";
        }
    mail($this->to, $this->subject, $this->message, $this->headers, "-f{$this->from}");
    }
    
}

?>
