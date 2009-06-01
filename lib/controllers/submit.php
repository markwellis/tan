<?php
require_once('../header.php');

$location = $_GET['type'];

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

if ($_SERVER['REQUEST_METHOD'] === 'POST'){
    if ( check_referer() ){
        $desc_field = 'description';
        if ($location === 'picture'){
            $desc_field = 'pdescription';
        }

        $data = array(
            0 => trim(ucwords(strip_tags(htmlentities(trim($_POST['title']),ENT_QUOTES,'UTF-8')))), //title
            1 => trim(strip_tags(htmlentities($_POST[$desc_field],ENT_QUOTES,'UTF-8'))),          //description
            2 => (int)$_POST['cat'],                                                                //category
            3 => $m_user->user_id(),                                                                //userid
            4 => $m_user->username(),                                                               //username
        );

        $m_submit = load_model('m_submit', array($location));
        switch ($location){
            case 'link':
                $data[5] = strip_tags(htmlentities($_POST["url"],ENT_QUOTES,'UTF-8'));
                $message = $m_submit->submit($data);
                break;
            case 'blog':
                require_once ($_SERVER['DOCUMENT_ROOT'] . '/lib/3rdparty/htmlpurifier/loader.php');
                $purifier = &new purifier();
                $data[5] = $purifier->purify($_POST['blogmain']);
                
                $message = $m_submit->submit($data);
                break;
            case 'picture':
                $newname = strtolower(preg_replace("/[^a-zA-Z0-9\.]/", "_", $data[0]));
                $newname = time() . "-{$newname}";

                if ($_FILES['pic']['size']){
                    $m_image_upload = load_model('m_image_upload', array($_FILES['pic'], IMAGE_UPLOAD_PATH . "/{$newname}"));
                } else {
                    $m_image_upload = load_model('m_remote_image_upload', array($_POST['pic_url'], IMAGE_UPLOAD_PATH . "/{$newname}"));
                }

                $message = $m_image_upload->upload();
                if ($m_image_upload->meta && $message === true){
                    $data[5] = $m_image_upload->uploaded_filename;
                    $data[6] = $m_image_upload->meta[0];
                    $data[7] = $m_image_upload->meta[1];
                    $data[8] = $m_image_upload->meta[2];
                    if ($_POST['nsfw'] === 'on'){
                        $data[9] = 'Y';
                    } else {
                        $data[9] = 'N';
                    }
                    $message = $m_submit->submit($data);
                }
                break;
        }
        if (is_int($message)){
            $m_tag = load_model('m_tag', array($location));
            $m_tag->tag($_POST['tags'], $message, $data[3], $data[4]);

            $message = 'Submission Complete';
        }
        $m_stash->add_message($message);
        header("location: /{$location}/1/1/");
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
