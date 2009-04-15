<?php
if (defined('MAGIC')) {
	require_once('/var/www/thisaintnews.com/config/thisaintnews/config.php');
	class sql {
	
	    function __construct(){
	        $this->mysqlLink = &mysql_connect(config::$dbServer,config::$dbUser,config::$dbPassword);
	        @mysql_select_db(config::$dbName, $this->mysqlLink) or die( "Unable to select database");
	    }
	    
	    public function query($query, $type){
	        if ($type === 'id'){
	            return mysql_insert_id($this->mysqlLink);
	        }

			$debug = false;
            
            if ($debug){
                $time = microtime();
                $time = explode(" ", $time);
                $time = $time[1] + $time[0];
                $start = $time;
            }

	        $result = mysql_query($query, $this->mysqlLink);
	        switch ($type){
	            case 'none':
	                return $result;
	                break;
	            case 'row':
	                $row = mysql_fetch_array($result, MYSQL_ASSOC);
                    if ($debug){
                        $time = microtime();
                        $time = explode(" ", $time);
                        $time = $time[1] + $time[0];
                        $totaltime = number_format(($time - $start), 4);
                        error_log("\n{$totaltime} : {$query}\n");
                    }
                    return $row;
	                break;
	            case 'count':
	                $count = @mysql_num_rows($result);
                    if ($debug){
                        $time = microtime();
                        $time = explode(" ", $time);
                        $time = $time[1] + $time[0];
                        $totaltime = number_format(($time - $start), 4);
                        error_log("\n{$totaltime} : {$query}\n");
                    }
                    return $count;
	                break;
	            case 'array':
	                $larray = array();
	                while($row = @mysql_fetch_array($result, MYSQL_ASSOC)){
	                    $larray[]= $row;
	                }
                    if ($debug){
                        $time = microtime();
                        $time = explode(" ", $time);
                        $time = $time[1] + $time[0];
                        $totaltime = number_format(($time - $start), 4);
                        error_log("\n{$totaltime} : {$query}\n");
                    }
	                return $larray; 
	                break;
	            case 'array1':
	                $larray = array();
	                while($row = mysql_fetch_array($result, MYSQL_ASSOC)){
	                    $larray[]= $row[0];
	                }
                    if ($debug){
                        $time = microtime();
                        $time = explode(" ", $time);
                        $time = $time[1] + $time[0];
                        $totaltime = number_format(($time - $start), 4);
                        error_log("\n{$totaltime} : {$query}\n");
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
} else {
	header('Location: /error404/');
	exit;
}
?>
