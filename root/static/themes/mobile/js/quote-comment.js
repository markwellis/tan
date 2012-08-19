function quote_comment( comment_id, username ){
    var comment = document.getElementById( '_comment:' + comment_id );
    var text_box = document.getElementById('comment');

    text_box.value += "[quote user=" + username + "]" + comment.innerHTML + "[/quote]\n\n";
}
