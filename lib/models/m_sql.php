<?php
if (defined('MAGIC')) {
    class m_sql {
        function __construct(){
            $this->mysqli = new mysqli(SQL_SERVER, SQL_USER, SQL_PASSW0RD, SQL_DB);
            $this->query_count = 0;
            if (mysqli_connect_errno()) {
               error(sprintf("Can't connect to MySQL Server. Errorcode: %s\n", mysqli_connect_error()));
               exit();
            } 
        }
        
        /**
         * takes 3 args
         * query, format, array of params
         */
        public function query($query, $format, $args, $type = null){
            if (DEBUG_SQL){
                $time = microtime();
                $time = explode(" ", $time);
                $time = $time[1] + $time[0];
                $start = $time;
            }
            $this->query_count = ++$this->query_count;
            if (func_num_args() < 3){
                return 0;
            }

            if (!is_array($args) ){
                $args = array($args);
            }

            $stmt = $this->mysqli->stmt_init();
            if ( $stmt->prepare($query) ) {
                if ($format && $args ){
                    call_user_func_array(array($stmt, 'bind_param'), array_merge (array($format), $args));
                } 
                
                $stmt->execute();
                $stmt->store_result();

                if ($type === 'count'){
                    $result = $stmt->num_rows;
                } elseif ($type === 'insert'){
                    $result = $this->mysqli->insert_id;
                } else {
                    $meta = $stmt->result_metadata();
                    $row = null;
    
                    if ($meta){
                        while ( $field = $meta->fetch_field() ){
                            $params[] = &$row[$field->name];
                        }
                        call_user_func_array(array($stmt, 'bind_result'), $params);
        
                        while ($stmt->fetch()) {
                            foreach($row as $key => $val) {
                                $c[$key] = $val;
                            }
                            $result[] = $c;
                        }
                        $meta->free();
                    }
                }
                $stmt->close();
                if (DEBUG_SQL){
                    $time = microtime();
                    $time = explode(" ", $time);
                    $time = $time[1] + $time[0];
                    $totaltime = number_format(($time - $start), 4);
                    $args = implode(', ', $args);
                    debug("\n{$totaltime} : {$query} : {$format} : " . print_r($args, 1) . "\n");
                }

                return $result;
            } else {
                $error = $this->mysqli->error;
                error($error);
            }
        }
        
        function _clone_db_for_test(){
            if ($this->is_cloned) {
                return null;
            }
            
            $result = $this->query('SHOW TABLES', null, array(null));
            
            $count = $this->query('SHOW TABLES', null, array(null), 'count');

            $i = 0;
            foreach ($result as $t_array){
                $table = &$t_array['Tables_in_thisaintnews'];
                $query = "CREATE TEMPORARY TABLE {$table}_t LIKE {$table};";
                $this->query($query, null, array(null), 'insert');
                $query = "ALTER TABLE {$table}_t RENAME {$table};";
                $this->query($query, null, array(null), 'insert');
                ++$i;
            }

            if ( ($i === $count) && ($count > 0) ) {
                $this->is_cloned = True;
                return true;
            }
            return false;
        }

        function __destruct(){
            @$this->mysqli->close();
        }
    
    }
} else {
    header('Location: /error404/');
    exit;
}
?>
