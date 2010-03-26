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
                            TAN.login("Your comment has been saved. "
                                + "You need to login or register before it's posted");
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

        comment = '[quote user=' + username + ']' + quote + '[/quote]' + "\n<br /><br />";

        tinyMCE.activeEditor.execCommand("mceInsertContent", false, comment);

    });

    $$('.comment_edit').addEvent('click', function(e){
        e.stop();
        var comment_holder = this.getParent().getParent().getParent().getParent();
        var comment_id = comment_holder.id.replace(/\D+/g, '');

        var req = new Request.HTML({
            'url' : this.href + '?ajax=1',
            'evalScripts': false,
            'noCache': true,
            'onSuccess': function(responseTree, responseElements, responseHTML, responseJavaScript) {
                comment_holder.empty();
                comment_holder.adopt( responseTree );
                tinyMCE.execCommand('mceAddControl', false, 'edit_comment_' + comment_id);

                comment_holder.getElement('form').addEvent('submit', function(e){
                    e.stop();

    // this is all bollix, it needs to be a request.HTML
    // also, it doesnt work in the slightest for delete
                    this.set('send', {
                        'url': this.action + '?ajax=1',
                        'onComplete': function(response) { 
                            var comment = new Element(response);
                            comment.replace(comment_holder);
                            if ( response !== '_deleted_comment' ){
                                comment_holder.set('html', response);
                            }
                        }
                    });
                    this.send();
                });
            }
        }).get();
    });
});
