window.addEvent('load', function() {
	$('comment_form').addEvents({
		submit: function(e) {
            e.stop();

            var input_comment = tinyMCE.activeEditor.getContent();
            
            if ( input_comment ){
                var req = new Request.HTML({
                    'url' : this.action + '?ajax=1',
                    'onSuccess': function(response_comment, responseElements, responseHTML) {
                        $('submit_comment').disabled = 0;
                        if ( responseHTML === 'error' ){
                            TAN.log('fail');
                        } else if ( responseHTML === 'login' ){
                            window.location = '/login/';
                        } else {
                            $('comments').adopt(response_comment);
                            tinyMCE.activeEditor.setContent('');
                        }
                        $('submit_comment').disabled = 0;
                    },
                    'onFailure': function(){
                        TAN.log('fail');
                        $('submit_comment').disabled = 0;
                    }
                }).post({
                    'comment': input_comment
                });

                $('submit_comment').disabled = 1;
            }
		}
	});

    $$('.quote_link').addEvent('click', function(e) {
        e.stop();

        var title = this.title.split('::');
        var username = title[0]; 
        var comment_id = title[1]; 
        var comment_name = 'actual_comment' + comment_id;
        var comment = $(comment_name);
        var src;

        comment.getElements('.boob_blocked').each(function(el) {
            src = el.getProperty('src');
            el.setProperty('src', el.retrieve('original_image').src);
        });

        var quote = $(comment_name).get('html');

        comment.getElements('.boob_blocked').each(function(el) {
            el.setProperty('src', src);
        });

        comment = '[quote user="' + username + '"]' + quote + '[/quote]' + "\n<br /><br />";

        tinyMCE.activeEditor.execCommand("mceInsertContent", false, comment);

    });
});
