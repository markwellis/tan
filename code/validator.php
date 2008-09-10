<?php
    class validator {
        private $NotAllowed = Array("|", "?", " ", ",");
        private $minLen = 6;

        public function validate($username, $password0, $password1, $email){
         /* returns 1 on on success!
            -6 = missing input
            -5 = passwords don't match
            -4 = invalid char in username
            -3 = username exists
            -2 = password to short
            -1 = not valid email
            -7 = email exists
             1 = success (True) */
            if ($password0 == '' || $password1 == '' || $email == '' || $username == '') { return -6; }
            if (!$this->comparePasswords($password0, $password1)) { return -5; }
            if ($this->checkIllegal($username)) { return -4; }
            if ($this->checkUser($username)) { return -3; }
            if ($this->minLen > strlen($password0)) { return -2; }
            if (!eregi("[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}", $email)) { return -1; }
            if ($this->checkEmail($email)) { return -7; }
            return 1;
        }

        private function comparePasswords($password0, $password1){
            if ($password0 != $password1){
                return false;
            } else { return true; }
        }

        private function checkUser($username){
            $sql = new sql();
            $query = "SELECT * FROM user_details WHERE username='$username';";
            $result = $sql->query($query, 'row');
            $rows = count($result);
            if ($rows < 2) { $rows = 0; }
            return $rows;
        }
        
        private function checkEmail($email){
            $sql = new sql();
            $query = "SELECT * FROM user_details WHERE email='$email';";
            $result = $sql->query($query, 'row');
            $rows = count($result);
            if ($rows < 2) { $rows = 0; }
            return $rows;
        }

        private function checkIllegal($checkStr){
            if (preg_match("/[^a-zA-Z0-9]/", $checkStr)){
                return true;
            } 
            return false;
        }
    }
?>
