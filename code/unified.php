<?php
/* Last modified  

New uninified class for getting stuff out of the database
assign like so $link = new unified('link') // see $kinds_of_objects for more types


ToDo:
1. Finsh adding unfied code,
2. Adjust pictures table to match schema of link_details and blog_details (for the front page)
3. Fine tune (optimize for speed!)
4. Add options so can sort by comments/date/plus/minus etc
5. ???
6. Profit

*/

require_once("user.php");
require_once("sql.php");

class unified{
    static $kind_of_object;

    private $kinds_of_objects = array("link", "picture", "blog");
    private $rootdir = '/var/www/thisaintnews.com';
    private $rootimagedir;
    private $title_min = 5;
    private $desc_min = 5;
    private $title_max = 100;
    private $desc_max = 1000;
    private $max_picture_size = 2000000;
    private $blog_min = 20;

    public $sort_by = array('date', 'comments', 'plus', 'minus', 'views');

/*  cutoff for promoted stuff */
    private $promoted_threashold = 3;

    function __construct($kind){
        if (in_array($kind, $this->kinds_of_objects, TRUE)){
            $this->kind_of_object = $kind;
            $this->rootimagedir = $this->rootdir .'/images';
        } else {
            die("Invalid object choice!");
        }
    }

    function moveUploaded($kindofpicture){
        if ($this->kind_of_object === 'picture'){
            if ($kindofpicture === 'picture'){
                $uploaddir = $this->rootimagedir .'/pics/';
            }
            $now = time();

            while(file_exists($this->uploadFilename = $uploaddir.$now.'-'.$_FILES['pic']['name'])) {
                $now++;
            }
            if (!move_uploaded_file($_FILES['pic']['tmp_name'], $this->uploadFilename)) {
                return 'receiving directory insuffiecient permission';
            }
            return array(null, $this->uploadFilename);
        }
        return -1;
    }

    function PlusToMinusRatio($plus, $minus){
/*      creates a plus to minus ratio   */
        $x = $plus;
        $y = $minus;
        if ($x == 0 | $y == 0){return array(0 => ($x), 1 => ($y));}
        while ($y != 0) {
            $w = $x % $y;
            $x = $y;
            $y = $w;
        }
        return array(0 => ($plus / $x), 1 => ($minus / $x));
    }

    function getImageProperties($id, $filename){
        if ($this->kind_of_object === 'picture'){
            $sql = new sql();
            $query = "SELECT x, y, size FROM picture_details WHERE picture_id=$id;";
            $res = $sql->query($query, 'row');
            if (!$res['x'] || !$res['y'] || !$res['size']){
                //check size and update the db
                $res = @getimagesize($this->rootimagedir . '/pics/' .basename($filename));
                $size = (@filesize($this->rootimagedir . '/pics/' .basename($filename))) / 1024;
                $query = "UPDATE picture_details SET x={$res[0]}, y={$res[1]}, size=$size WHERE picture_id=$id;";
                $sql->query($query, 'none');
                return array($size, array($res[0], $res[1]));
            } else {
                return array($res['size'], array($res['x'], $res['y']));
            }
        } else {
            return null;
        }
    }

    function getRandom(){
        $sql = new sql();
        $query = "SELECT * FROM {$this->kind_of_object}_details ORDER BY RAND() limit 1;";
        return $sql->query($query, 'row');
    }

    function isValid($data, $title, $description){
/*   Does a few checks on whats being submitted */
        $sql = new sql();
        $user = new user();
        switch ($this->kind_of_object) {
            case 'link':
                $link_error_codes = array(0 => 'Title cannont be blank',
                    1 => 'Description cannot be blank',
                    2 => "Title cannot be over {$this->title_max} characters",
                    3 => "Description cannot be over {$this->desc_max} characters",
                    4 => "Title must be over {$this->title_min} characters",
                    5 => "Description must be over {$this->desc_min} characters",
                    6 => 'Url is invalid',
                    7 => 'This link has already been submitted');
                if ($title === '') { return $link_error_codes[0]; }
                if ($description === '') { return $link_error_codes[1]; }
                if (strlen($title) > $this->title_max) { return $link_error_codes[2]; }
                if (strlen($description) > $this->desc_max) { return $link_error_codes[3]; }
                if (strlen($title) < $this->title_min) { return $link_error_codes[4]; }
                if (strlen($description) < $this->desc_min) { return $link_error_codes[5]; }
                if (!preg_match('/^(http|https|ftp):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?/i', $data)) { return $link_error_codes[6]; }

                $query = "SELECT link_id FROM link_details WHERE url='$data';";
                $res = $sql->query($query, 'array'); //could this be count? slight speed increase possible, Sat Aug 23 02:34:15 BST 2008
                if (isset($res['link_id'])){ return $this->link_error_codes[7]; }
                if (!$user->isLoggedIn()){ return "Please login"; }
                return null;
                break;
            case 'picture':
                $picture_error_codes = array(0 => 'Only image uploads are allowed',
                    1 => 'Filesize exceeded1',
                    2 => 'Filesize exceeded',
                    3 => 'File upload was only partial',
                    4 => 'No file attached',
                    5 => 'Filesize exceeded5',
                    6 => 'Form not completed');
                if ($_FILES['pic']['size'] > $this->max_picture_size){ return $picture_error_codes[2]; }
                if ($title === '') { return $picture_error_codes[6]; }
                if ($_FILES['pic']['error'] !== 0) { return $picture_error_codes[$_FILES['pic']['error']]; }
                if (!@is_uploaded_file($_FILES['pic']['tmp_name'])){ return $picture_error_codes[5]; }
                $res = @getimagesize($_FILES['pic']['tmp_name']);
                if (!$res){ return $picture_error_codes[0]; }
                if (!$user->isLoggedIn()){ return "Please login"; }
                return array(null, ($_FILES['pic']['size'] / 1024), array($res[0], $res[1]));
                break;
            case 'blog':
                $blog_error_codes = array(0 => 'Title cannont be blank',
                    1 => 'Description cannot be blank',
                    2 => "Title cannot be over {$this->title_max} characters",
                    3 => "Description cannot be over {$this->desc_max} characters",
                    4 => "Title must be over {$this->title_min} characters",
                    5 => "Description must be over {$this->desc_min} characters",
                    6 => "Blog must be over {$this->blog_min} characters");
                if ($title === '') { return $blog_error_codes[0]; }
                if ($description === '') { return $blog_error_codes[1]; }
                if (strlen($title) > $this->title_max) { return $blog_error_codes[2]; }
                if (strlen($description) > $this->desc_max) { return $blog_error_codes[3]; }
                if (strlen($title) < $this->title_min) { return $blog_error_codes[4]; }
                if (strlen($description) < $this->desc_min) { return $blog_error_codes[5]; }
                if (strlen($data) < $this->blog_min) { return $blog_error_codes[6]; }
                if (!$user->isLoggedIn()){ return "Please login"; }
                return null;
                break;
        } 
    }

    function addtoDatabase($data, $title, $description, $cat, $meta = null, $ised = 0){
/*      Adds stuff to the database
/*      $data should be the url, blog text, image filename etc
/*      returns the newly added objects id */

        $sql = new sql();
        $user = new user();
        $userid = $user->getUserId();
        $username = $user->getUserName();
        switch ($this->kind_of_object) {
            case 'link':
                $idtype = "link_id";
                $table = "link_details";
                $columns = "(link_id, title, description, user_id, username, date, promoted, url, views, category, blog_id, ised, details)";
                $values = "('', '$title',  '$description', $userid,'$username', NOW(), '', '$data', '', $cat, '', '', '')";
                break;
            case 'blog':
                $idtype = "blog_id";
                $table = "blog_details";
                $columns = "(link_id, title, description, user_id, username, date, promoted, url, views, category, blog_id, ised, details)";
                $values = "('', '$title', '$description', $userid, '$username', NOW(),'','', '', $cat,'', $ised, '$data')";
                break;
            case 'picture':
                $idtype = "picture_id";
                $table = "picture_details";
                $columns = "(picture_id, title, description, user_id, date, promoted, filename, views, category, username, x, y, size)";
                $values = "('', '$title',  '$description', $userid, NOW(), '', '$data', '', $cat, '$username', {$meta[1][0]}, {$meta[1][1]}, {$meta[0]})";
                break;
        }
        if ($idtype){ // just a test to make sure theres actually something to add to the db
            $query = "INSERT INTO $table $columns VALUES {$values};";
            $retval = $sql->query($query, 'none');
            $retval = $sql->query(null, 'id');
        } else {
            $retval = -1;
        }
        return $retval;
    }

    function getComments($id){
        $sql = new sql();
        switch ($this->kind_of_object){
            case 'link':
                $condtions = "WHERE link_id=$id ORDER BY date";
                break;
            case 'blog':
                $condtions = "WHERE blog_id=$id ORDER BY date";
                break;
            case 'picture':
                $condtions = "WHERE picture_id=$id ORDER BY date";
                break;
        }
        $query = "SELECT *, (SELECT join_date FROM user_details WHERE user_details.user_id=t2.user_id) AS join_date, 
            (SELECT COUNT(*) FROM comments AS t1 WHERE t1.user_id=t2.user_id) AS total_comments FROM comments AS t2 $condtions;";
        return $sql->query($query, 'array');
    }

    function leaveComment($id, $comment){
        $sql = new sql();
        $user = new user();
        $userid = $user->getUserId();
        $username = $user->getUserName();
        $picture_id = '';
        $blog_id = '';
        $link_id = '';
        switch ($this->kind_of_object){
            case 'link':
                $link_id = $id;
                break;
            case 'blog':
                $blog_id = $id;
                break;
            case 'picture':
                $picture_id = $id;
                break;
        }
        $query = "INSERT INTO comments (comment_id, username, user_id, date, details, picture_id, blog_id, link_id) 
            VALUES ('', '$username', $userid, NOW(), '$comment', $picture_id, $blog_id, $link_id);";
        return $sql->query($query, 'none');
    }

    function addPlusMinus($id, $plus){
        $sql = new sql();
        $user = new user();
        $picture_id = ''; 
        $blog_id = ''; 
        $link_id = '';
        if ($plus === 1) {
            $table = 'plus';
        } elseif ($plus === 0) {
            $table = 'minus';
        }
        if ($table){
            switch ($this->kind_of_object){
                case 'link':
                    $link_id=$id;
                    $dtable = 'link_details';
                    $conditions = "link_id=$id";
                    break;
                case 'blog':
                    $blog_id=$id;
                    $dtable = 'blog_details';
                    $conditions = "blog_id=$id";
                    break;
                case 'picture':
                    $picture_id=$id;
                    $dtable = 'picture_details';
                    $conditions = "picture_id=$id";
                    break;
            }
            $query = "SELECT {$table}_id FROM $table WHERE user_id={$user->getUserId()} AND $conditions;";
            $count = $sql->query($query, 'count');
            if (!$count){
                $query = "INSERT INTO $table ({$table}_id, username, user_id, date, picture_id, blog_id, link_id) 
                    VALUES ('', '{$user->getUsername()}'', {$user->getUserId()}, NOW(), $picture_id, $blog_id, $link_id);";
                $res = $sql->query($query, 'none');
                if ($table === 'plus'){
                $count = $this->getPlus($id);
                    if ($count == $this->promoted_threashold){
                        $sql1 = new sql();
                        $query = "UPDATE $dtable SET promoted=NOW() WHERE $conditions;";
                        $sql1->query($query, 'none');
                    }
                }
                return $res;
            } else {
                $query = "DELETE FROM $table WHERE user_id={$user->getUserId()} AND $conditions;";
                $res = $sql->query($query, 'none');
                if ($table === 'plus'){
                $count = $this->getPlus($id);
                    if ($count == $this->promoted_threashold -1){
                        $sql1 = new sql();
                        $query = "UPDATE $dtable SET promoted='' WHERE $conditions;";
                        $sql1->query($query, 'none');
                    }
                }
                return $res;
            }
        }
    }

    function getPlusMinus($id, $plus){
        $sql = new sql();
        if ($plus === 1) {
            $table = 'plus';
        } elseif ($plus === 0) {
            $table = 'minus';
        }
        if ($table) {
            switch ($this->kind_of_object){
                case 'link':
                    $conditions = "link_id=$id";
                    break;
                case 'blog':
                    $conditions = "blog_id=$id";
                    break;
                case 'picture':
                    $conditions = "picture_id=$id";
                    break;
            }
            $query = "SELECT {$table}_id FROM $table WHERE $conditions;";
            $count = $sql->query($query, 'count');
            return $count;
        }
    }

    function getAllObjects($table){
        $sql = new sql();
        $query = "SELECT * FROM $table;";
        return $sql->query($query, 'array');
    }

    function getPageObjects($page, $below, $order, $username = null, $specific = null){
/* Old code, but has union select, will be needed later on for all!
            $query = "select * from link_details where (SELECT count(*) from plus where plus.link_id = link_details.link_id) >= ".$this->threashold." 
            union select * from blog_details where (SELECT count(*) from plus where plus.blog_id = blog_details.blog_id) >= ".$this->threashold." 
            order by date desc limit $page, $limit;"; */
        $sql = new sql();
        $page = ($page * 27) -27;
        $limit = 27;

        if ($below === 0 && $order==='date'){
            $order = 'promoted';
        }

        switch ($this->kind_of_object){
            case 'link':
                $table = 'link_details';
                $id ='link_id';
                $extraSql ="(SELECT filename FROM picture_details WHERE picture_details.picture_id = {$table}.category) AS catimg,";
                break;
            case 'blog':
                $table = 'blog_details';
                $id ='blog_id';
                $extraSql ="(SELECT filename FROM picture_details WHERE picture_details.picture_id = {$table}.category) AS catimg,";
                break;
            case 'picture':
                $table = 'picture_details';
                $id ='picture_id';
                $extraSql ='';
                break;
        }
        if ($username === null){
            if ($below === 0) {
                $oper = '>=';
                if ($order !== 'promoted'){
                    $order .= ' DESC, promoted ';
                }
            } elseif ($below === 1){
                $oper = '<';
                if ($order !== 'date'){
                    $order .= ' DESC, date ';
                }
            }
            $conditions = "HAVING plus $oper {$this->promoted_threashold}";
        } else {
            $conditions = "WHERE username = '$username'";
        }
        require_once('code/user.php');
        $user = new user();
        $uid = $user->getUserId();
        if (!$uid){ $uid = -1; }
        if ($specific){
            $conditions = "WHERE {$table}.{$id} = $specific";
            $page = 0;
            $limit = 1;
            $order = 'date';
            $query = "UPDATE {$table} SET views=({$table}.views) + 1 WHERE {$table}.{$id} = $specific";
            $sql->query($query, 'none');
        }
        $query = "SELECT *,(SELECT COUNT(*) FROM plus WHERE plus.$id = {$table}.{$id}) AS plus,
            (SELECT COUNT(*) FROM minus WHERE minus.$id = {$table}.{$id}) AS minus,
            (SELECT COUNT(*) FROM comments WHERE comments.{$id} = {$table}.{$id}) AS comments,
            (SELECT COUNT(*) FROM plus WHERE plus.{$id} = {$table}.{$id} and plus.user_id=$uid) AS meplus,
            $extraSql
            (SELECT COUNT(*) FROM minus WHERE minus.{$id} = {$table}.{$id} and minus.user_id=$uid) AS meminus
            FROM $table $conditions ORDER BY $order DESC LIMIT $page, $limit;";
        return $sql->query($query, 'array');
    }

    function getPlusMinusCount($below, $plus){
        $sql = new sql();
        switch ($this->kind_of_object){
            case 'link':
                $table = 'link_details';
                $id ='link_id';
                break;
            case 'blog':
                $table = 'blog_details';
                $id ='blog_id';
                break;
            case 'picture':
                $table = 'picture_details';
                $id ='picture_id';
                break;
        }
        if ($below === 0) {
            $oper = '>=';
        } elseif ($below === 1){
            $oper = '<';
        }
        if ($plus === 1) {
            $ptable = 'plus';
        } elseif ($plus === 0) {
            $ptable = 'minus';
        }
        if ($oper) {
            $query = "SELECT COUNT($id) AS count FROM $table WHERE (SELECT COUNT($id) FROM $ptable WHERE plus.{$id} = {$table}.{$id}) $oper {$this->promoted_threashold};";
            $res = $sql->query($query, 'row');
            return $res['count'];
        } else { return 0; }
    }

    function CreateObjectHTML($objectDetails, $type, $article = 0){
        switch($this->kind_of_object){
            case 'link':
                $objectid = & $objectDetails['link_id'];
                $kind = 'link';
                break;
            case 'blog':
                $objectid = & $objectDetails['blog_id'];
                $kind = 'blog';
                break;
            case 'picture':
                $ispic = true;
                break;
        }
        
        if (!$ispic){
            $plusminusbox .= $this->CreatePlusMinusHTML($objectDetails[$kind.'_id'], $objectDetails['plus'],
            $objectDetails['minus'], $objectDetails['meplus'], $objectDetails['meminus'], null);

            $output .= "<div class='news'><img src='/thumb/{$objectDetails['category']}/100/' alt='{$objectDetails['category']}' class='newsImg'/>
                $plusminusbox</div>";
            if ($article === 0){
                $output .= "<h1 style='display:inline;font-weight:normal;'>
                    <a class='title' href='/view{$kind}/{$objectid}/".$this->urlTitle($objectDetails['title'])."/'
                >".stripslashes($objectDetails['title'])."</a></h1><br/>";
            } else {
                $output .= "<h1 style='display:inline;font-weight:normal;'><a class='title' href='".stripslashes($objectDetails['url'])."'
                >".stripslashes($objectDetails['title'])."</a></h1><br/>";
            }

            if (file_exists("sys/users/avatar/{$objectDetails['user_id']}.jpg")){
                $output .= "<img class='avatar' src='/sys/users/avatar/{$objectDetails['user_id']}.jpg'
                    alt='{$objectDetails['username']}' />";
            } else { 
                $output .= "<img class='avatar' src='/sys/images/_user.png' alt='{$objectDetails['username']}' />"; 
            }

            $output .= "Posted by <a class='user' href='/users/{$objectDetails['username']}/plus/1/'>{$objectDetails['username']}</a>";

            if ($type == 0) {
                $output .= " promoted on {$objectDetails['promoted']}";
            } elseif ($type == 1) {
                $output .= " on {$objectDetails['date']}";
            }
            $ratio = $this->PlusToMinusRatio($objectDetails['plus'], $objectDetails['minus']);
            $output .= "<br /><a href='/view{$kind}/{$objectDetails[$kind.'_id']}/". $this->urlTitle($objectDetails['title'])."/#comments'>
                <img src='/sys/images/comment.png' style='height:15px;width:15px' alt=' ' /> {$objectDetails['comments']}</a> | {$objectDetails['views']} views";

            if ($ratio) {
                $output .= " | Ratio " . $ratio[0] . ":" . $ratio[1];
            }

            $output .= "<br /><p>".nl2br(stripslashes($objectDetails['description']))."</p></div>";
            if ($article && $kind === 'link'){
                $output .= "<a style='margin-right:70px;float:right;font-size:1.5em;' href='".stripslashes($objectDetails['url'])."'>View Link</a><br/><br/>";
            } elseif ($article && $kind === 'blog'){
                $output .= $objectDetails['details'];
            }
            $output .= "<hr />";
        } else {
///////////////////
//****Picture****//
///////////////////
            if ($article){
                $style = 'margin-top:50px;margin-right:25px;';
                $divholder = "<div id='picHolder'>";
            } else {
                $divholder = "<div style='text-align:left;width:230px;'>";
                $style = 'float:right;margin-top:60px;margin-right:15px;';
            }
            $plusminusbox .= $this->CreatePlusMinusHTML($objectDetails['picture_id'], $objectDetails['plus'],
                $objectDetails['minus'], $objectDetails['meplus'], $objectDetails['meminus'], $style);

            $output .= "{$divholder}<a class='Pictitle'
                href='/images/pics/".basename($objectDetails['filename']). "'>".stripslashes($objectDetails['title']).'</a><br />';
            if (file_exists("sys/users/avatar/{$objectDetails['user_id']}.jpg")){
                $output .= "\n<img class='avatar' style='margin-left:5px;'
                    src='/sys/users/avatar/{$objectDetails['user_id']}.jpg' alt='".stripslashes($objectDetails['username'])."' />";
            } else {
                $output .= "\n<img class='avatar' style='margin-left:5px;' src='/sys/images/_user.png'
                    alt='{$objectDetails['username']}' />";
            }
            $output .= "<a class='user' href='/users/{$objectDetails['username']}/plus/1/'>{$objectDetails['username']}</a><br />
                <a href='/viewpic/{$objectDetails['picture_id']}/".user::cleanTitle($objectDetails['title']) ."/#comments'>
                <img src='/sys/images/comment.png' alt=' ' />  {$objectDetails['comments']}</a>
                | {$objectDetails['views']} views";
            $ratio = $this->PlusToMinusRatio($objectDetails['plus'], $objectDetails['minus']);
            if ($article){
                if ($ratio) {
                    $output .= " | Ratio " . $ratio[0] . ":" . $ratio[1];
                }
                $meta = $this->getImageProperties($objectDetails['picture_id'], $objectDetails['filename']);
                if ($meta[0] > 1024){
                    $size = number_format(($meta[0] / 1024), 2) . 'MB';
                } else {
                    $size = number_format($meta[0], 2) . 'KB';
                }
                $output .=" | {$meta[1][0]}x{$meta[1][1]} | {$size}{$plusminusbox}</div><div class='thumbPlace'><a href='/images/pics/".stripslashes(htmlentities(basename($objectDetails['filename']),ENT_QUOTES,'UTF-8'))."'>
                    <img class='picThumb' src='/thumb/{$objectDetails['picture_id']}/400/'
                    alt='".stripslashes($objectDetails['title'])."'/></a>
                    </div>{$objectDetails['description']}</div>";
            } else {
                $output .= "</div><a href='/viewpic/{$objectDetails['picture_id']}/". user::cleanTitle($objectDetails['title']) ."/'>
                    <img class='thumbPic' src='/thumb/{$objectDetails['picture_id']}/160/'
                    alt='{$objectDetails['title']}'/></a></div>$plusminusbox";
            }
        }
        return $output;
    }

    function urlTitle($text){
        return preg_replace("/[^a-zA-Z0-9_]/", "", str_replace(' ','_', html_entity_decode(trim($text),ENT_QUOTES,'UTF-8')));
    }

    function CreateCommentHTML($comments, $id){
        switch($this->kind_of_object){
            case 'link':
                $type = 'link';
                break;
            case 'blog':
                $type = 'blog';
                break;
            case 'picture':
                $type = 'picture';
                break;
        }
        require_once('user.php');
        $user = new user();

        $output .= "<h2 id='comments'>Comments</h2>";
        foreach($comments as $comment){    
            $output .= "<div style='margin-left:5px;'>";
            if (file_exists("sys/users/avatar/{$comment['user_id']}.jpg")){
                $output .= "<img class='avatar' style='height:30px;width:30px;margin-left:10px;'
                    src='/sys/users/avatar/{$comment['user_id']}.jpg' alt='{$comment['username']}' />";
            } else {
                $output .= "\n<img class='avatar' style='height:30px;width:30px;margin-left:10px;'
                    src='/sys/images/_user.png' alt='{$comment['username']}' />";
            }
            $output .= "<div style='font-size:.8em;'>{$comment['username']} ,on {$comment['date']}<br />
                Total Comments: {$comment['total_comments']}, Joined on: {$comment['join_date']}</div>
                <div class='comment'>";
            $output .= stripslashes($comment['details']) . "<br/>
                <span style='display:block;float:right;'>Edit Comment</span>
                </div>
                </div><br /><hr style='width:700px'/>";
        }
        if ($user->isLoggedIn()){
            $output .= "<h2 id='lcomments'>Leave your comments</h2>
                    <form style='margin-left:15px;' action='/comment' method='post'>
                    <input name='id' type='hidden' value='$id' />
                    <input name='type' type='hidden' value='$type' />";
            include_once("sys/js/fckeditor/fckeditor.php") ;
            $oFCKeditor = new FCKeditor('comment');
            $oFCKeditor->BasePath = '/sys/js/fckeditor/' ;
            $oFCKeditor->Value = '' ;
            $oFCKeditor->ToolbarSet = 'lulz';
            $oFCKeditor->Width = 750;
            $oFCKeditor->Config['EnterMode'] = 'br';
            $output .= $oFCKeditor->CreateHTML() ;
            $output .= "<input type='submit' value='Comment' />
                    </form>";
        } else {
            $output .= "<br />Please <a href='/login'>login</a> to leave comments";
        }
        return $output;
    }

    function error404(){
        header("HTTP/1.1 404 Not Found");
        header("Status: 404 Not Found");
        return "<h1>Error 404 : File not found</h1>";
    }

    function CreateSortBoxHTML($type, $page, $sort){
        switch($this->kind_of_object){
            case 'link':
                $where = 'link';
                break;
            case 'blog':
                $where = 'blog';
                break;
            case 'picture':
                $where = 'picture';
                break;
        }
        $sort_by = &$this->sort_by;
        $link_array = array();

        for($i=0, $max=count($sort_by);$i<$max;++$i){
            if ($i === $sort){
                $link_array[] = 'sselected';
            } else {
                $link_array[] = '';
            }
        }

        $output = "<span style='float:right;'>Sort by
            <a href='/$where/$type/$page/0/' class='sortby {$link_array[0]}'>Date</a>
            <a href='/$where/$type/$page/1/' class='sortby {$link_array[1]}'>Comments</a>
            <a href='/$where/$type/$page/2/' class='sortby {$link_array[2]}'>Plus's</a>
            <a href='/$where/$type/$page/3/' class='sortby {$link_array[3]}'>Minus's</a>
            <a href='/$where/$type/$page/4/' class='sortby {$link_array[4]}'>Views</a></span><br/><br/>";
        return $output;
    }

    function CreatePageBoxHTML($pageCount, $page, $type, $sort = null){
        switch($this->kind_of_object){
            case 'link':
                $where = 'link';
                break;
            case 'blog':
                $where = 'blog';
                break;
            case 'picture':
                $where = 'picture';
                break;
        }
        $output .= "<div id='pageNoHolder' style='margin-left:auto;margin-right:auto;margin-bottom:25px;width:".($pageCount * 40) ."px;'>";

        for ($i=1;$i<=$pageCount;++$i){
            $output .= "<a class='pageNumber";
            if ($i === $page){
                $output .= " thisPage";
            }
            if ($sort === null){
                $output .= " ' href='/$where/$type/$i/'>$i</a>";
            } else {
                $output .= " ' href='/$where/$type/$i/$sort/'>$i</a>";
            }
        }
        $output .=  "</div>";
        return $output;
    }

    function CreatePlusMinusHTML($objectid, $plus, $minus, $meplus, $meminus, $style){
        switch($this->kind_of_object){
            case 'link':
                $type = 'link';
                break;
            case 'blog':
                $type = 'blog';
                break;
            case 'picture':
                $type = 'picture';
                break;
        }
        $output = "<div class='plusminus' style='$style'>
            <div class='plus' id='plus{$objectid}'>{$plus}
            <a class='addPlus ";
        if ($meplus){
            $output .= "pselected ";
        }
        $output .= "' href='#' onclick=\"javascript:addPlus({$objectid}, '$type',
            'plus{$objectid}');return false;\">+</a></div>
            <div class='minus' id='minus{$objectid}'
            >{$minus}<a class='addMinus ";
        if ($meminus){
           $output .= " mselected ";
        }
        $output .= "' href='#' onclick=\"javascript:addMinus({$objectid}, '$type',
            'minus{$objectid}');return false;\">-</a></div>";
        return $output;
    }

// end of class!
}

?>
