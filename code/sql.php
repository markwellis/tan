<?php
require_once('/var/www/thisaintnews.com/config/thisaintnews/config.php');
class sql {
    static $mysqlLink = Null;

    function __construct(){
        $this->mysqlLink = mysql_connect(config::$dbServer,config::$dbUser,config::$dbPassword);
        @mysql_select_db(config::$dbName, $this->mysqlLink) or die( "Unable to select database");
    }
    
    public function query($query, $type){
        if ($type === 'id'){
            return mysql_insert_id($this->mysqlLink);
        }
        $result = mysql_query($query, $this->mysqlLink);
        switch ($type){
            case 'none':
                return $result;
                break;
            case 'row':
                return mysql_fetch_array($result, MYSQL_ASSOC);
                break;
            case 'count':
                return @mysql_num_rows($result);
                break;
            case 'array':
                $larray = array();
                while($row = @mysql_fetch_array($result, MYSQL_ASSOC)){
                    $larray[]= $row;
                }
                return $larray; 
                break;
            case 'array1':
                $larray = array();
                while($row = mysql_fetch_array($result, MYSQL_ASSOC)){
                    $larray[]= $row[0];
                }
                return $larray;
                break;
        }
        return -1;
    }

    function __destruct(){
        @mysql_close($this->mysqlLink);
    }

}
?>
