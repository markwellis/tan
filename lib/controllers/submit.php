<?php
require_once('../header.php');

$location = isset($_GET['location']) ? $_GET['location'] : '';
$edit = isset($_GET['edit']) ? (int)$_GET['edit'] : null;

if ($location !== 'blog' && $location !== 'link' && $location !== 'picture'){
    $m_stash->add_message('That was random');
    header('location: /');
    exit();
}

if (!$m_user->logged_in()){
    $m_stash->add_message('Please login');
    header('location: /login/');
    exit();
}

if ($edit){
    /* 
     * load object data
     * check user_id
     */
     $m_object = load_model('m_object',array($location));
     $m_stash->details = $m_object->get($edit);
     if (!$m_stash->details || (($m_user->user_id() !== $m_stash->details['user_id']) && !$m_user->admin())){
        $m_stash->add_message('Sorry');
        $ref = $_SERVER["HTTP_REFERER"] ? $_SERVER["HTTP_REFERER"] : '/';
        header("location: {$ref}");
        exit();
     }
     
     /* TODO:
      * add tag stuff, thumb browser thingy
      */
      
      $m_tag = load_model('m_tag',array($location));
      $m_stash->details['tags'] = $m_tag->get_tags($edit);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST'){
    if ( check_referer() ){
        $desc_field = 'description';
        if ($location === 'picture'){
            $desc_field = 'pdescription';
        }

        $data = array(
            0 => trim(ucwords(strip_tags(htmlentities(trim($_POST['title']),ENT_QUOTES,'UTF-8')))), //title
            1 => trim(strip_tags(htmlentities($_POST[$desc_field],ENT_QUOTES,'UTF-8'))),            //description
            2 => isset($_POST['cat']) ? (int)$_POST['cat'] : 0,                                      //category
            3 => $m_user->user_id(),                                                                //userid
            4 => $m_user->username(),                                                               //username
        );

        $m_submit = load_model('m_submit', array($location, $edit));
        $m_submit->edit = $edit;
        switch ($location){
            case 'link':
                if ($edit){
                    $data[3] = $edit;
                    unset($data[4]);
                } else {
                    $data[5] = strip_tags(htmlentities($_POST["url"],ENT_QUOTES,'UTF-8'));
                }
                $message = $m_submit->submit($data);
                break;
            case 'blog':
                require_once ($_SERVER['DOCUMENT_ROOT'] . '/lib/3rdparty/htmlpurifier/loader.php');
                $purifier = &new purifier();
                
                if ($edit){
                    $data[3] = $purifier->purify($_POST['blogmain']);
                    $data[4] = $edit;
                } else {
                    $data[5] = $purifier->purify($_POST['blogmain']);
                }
                
                $message = $m_submit->submit($data);
                break;
            case 'picture':
                if ($edit){
                    $data[3] = $_POST['nsfw'] ? 'Y' : 'N';
                    $data[4] = $edit;

                    $message = $m_submit->submit($data);
                } else {
                    $newname = strtolower(preg_replace("/[^a-zA-Z0-9\.]/", "_", $data[0]));
                    $newname = time() . "-{$newname}";
    
                    if ($_FILES['pic']['size']){
                        $m_image_upload = load_model('m_image_upload', array($_FILES['pic'], IMAGE_UPLOAD_PATH . "/{$newname}"));
                    } elseif ($_POST['pic_url']) {
                        $m_image_upload = load_model('m_remote_image_upload', array($_POST['pic_url'], IMAGE_UPLOAD_PATH . "/{$newname}"));
                    } else {
                        $m_stash->add_message('No Image');
                        header("location: /submit/{$location}/");
                        exit();
                    }

                    $message = $m_image_upload->upload();
                    if ($m_image_upload->meta && $message === true){
                        $data[5] = $m_image_upload->uploaded_filename;
                        $data[6] = $m_image_upload->meta[0];
                        $data[7] = $m_image_upload->meta[1];
                        $data[8] = $m_image_upload->meta[2];
                        $data[9] = $_POST['nsfw'] ? 'Y' : 'N';

                        $message = $m_submit->submit($data);
                    }
                }
                break;
        }
        if (is_int($message)){
            if (!$edit){
                $m_tag = load_model('m_tag', array($location));
                $m_tag->tag($_POST['tags'], $message, $data[3], $data[4]);
            }

            $message = 'Submission Complete';
        }
        $m_stash->add_message($message);
        $location = isset($edit) ? "/view{$location}/{$edit}/" . url_title($data[0]) . '/' : "/{$location}/1/1/";
        header("location: {$location}");
        exit();
    }
}

$m_stash->location = $location;
array_push($m_stash->js_includes, $m_stash->theme_settings['js_path'] . '/submit.js');

ob_start();
load_template("submit_{$location}");
$output_page = ob_get_contents();
ob_clean();

load_template('lib/open_page');
echo $output_page;
load_template('lib/close_page');
?>
