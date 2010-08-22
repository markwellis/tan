window.addEvent('domready', function() {
	$('comment_form').addEvents({
		submit: function(e) {
            e.stop();

            var input_comment = tinyMCE.get('comment').getContent();
            
            if ( input_comment ){
                var req = new Request.HTML({
                    'url' : this.action,
                    'noCache': true,
                    'onSuccess': function(responseTree, responseElements, responseHTML, responseJavaScript) {
                        $('submit_comment').disabled = 0;
                        if ( responseHTML == 'error' ){
                            TAN.alert('fail');
                        } else if ( responseHTML == 'login' ){
                            TAN.login("Your comment has been saved. "
                                + "You need to login or register before it's posted");
                            tinyMCE.get('comment').setContent('');
                        } else {
                            // can't use responseTree coz its not an element, its a Tree!
                            // but we can use responseElements[0] coz everything is inside a div! :D
                            responseElements[0].getElements('.quote_link').addEvent('click', function(e) {
                                e.stop();
                                quote_link(this);
                            });

                            responseElements[0].getElements('.comment_edit').addEvent('click', function(e) {
                                e.stop();
                                edit_link(this);
                            });

                            $$('.TAN-comment_wrapper').adopt(responseTree);
                            tinyMCE.get('comment').setContent('');
                        }
                        $('submit_comment').disabled = 0;
                    },
                    'onFailure': function(){
                        TAN.alert('fail');
                        $('submit_comment').disabled = 0;
                    }
                }).post({
                    'comment': input_comment,
                    'ajax': 1
                });

                $('submit_comment').disabled = 1;
            }
		}
	});

    $$('.quote_link').addEvent('click', function(e) {
        e.stop();
        quote_link(this);
    });

    $$('.comment_edit').addEvent('click', function(e){
        e.stop();
        edit_link(this);
    });
});

function quote_link(link){
    var title = link.title.split('::');
    var username = title[0]; 
    var comment_id = title[1]; 
    var comment = link.getParent().getParent().getParent().getParent().getParent().getElement('.TAN-comment_inner');
    var src;

    comment.getElements('.boob_blocked').each(function(el) {
        src = el.getProperty('src');
        el.setProperty('src', el.retrieve('original_image').src);
    });

    var quote = comment.get('html');

    comment.getElements('.boob_blocked').each(function(el) {
        el.setProperty('src', src);
    });

    comment = '[quote user=' + username + ']' + quote + '[/quote]' + "\n<br /><br />";

    tinyMCE.get('comment').execCommand("mceInsertContent", false, comment);
}

function edit_link(link){
    // LOL
    var comment_holder = link.getParent().getParent().getParent().getParent().getParent();
    var comment_id = comment_holder.id.replace(/\D+/g, '');
    var req = new Request.HTML({
        'url' : link.href,
        'evalScripts': false,
        'noCache': true,
        'onSuccess': function(responseTree) {
            comment_holder.empty();
            comment_holder.adopt( responseTree );
            tinyMCE.execCommand('mceAddControl', false, 'edit_comment_' + comment_id);

            //submit edit comment
            comment_holder.getElement('#edit' + comment_id).addEvent('click', function(e){
                e.stop();
                var editor_id = 'edit_comment_' + comment_id;
                //js is tarded and cant use varible as a object key coz it accepts barewords keys :/
                var data = {};
                data['ajax'] = 1;
                data[editor_id] = tinyMCE.get(editor_id).getContent();
                tinyMCE.execCommand('mceRemoveControl', false, editor_id);
                var edit_comment_submit = new Request.HTML({
                    'url': this.getParent().getParent().action,
                    'noCache': true,
                    'onSuccess': function(responseTree, responseElements, responseHTML, responseJavaScript){
                        // can't use responseTree coz its not an element, its a Tree!
                        // but we can use responseElements[0] coz everything is inside a div! :D
                        responseElements[0].getElements('.quote_link').addEvent('click', function(e) {
                            e.stop();
                            quote_link(this);
                        });

                        responseElements[0].getElements('.comment_edit').addEvent('click', function(e) {
                            e.stop();
                            edit_link(this);
                        });
                        responseElements[0].inject(comment_holder, 'after');
                        comment_holder.dispose();
                    },
                    'onFailure': function(xhr){
                        TAN.alert( xhr.responseText );
                    }
                }).post(data);
            });

            //delete comment
            comment_holder.getElement('#delete' + comment_id).addEvent('click', function(e){
                e.stop();
                if ( !confirm('Are you sure you want to delete link comment?') ){
                    return false;
                }
                var edit_comment_submit = new Request.HTML({
                    'url': this.getParent().getParent().action,
                    'noCache': true,
                    'onSuccess': function(responseTree, responseElements, responseHTML, responseJavaScript) {
                        TAN.alert( responseHTML );
                        comment_holder.dispose();
                    },
                    'onFailure': function(xhr){
                        TAN.alert( xhr.responseText );
                    }
                }).post({
                    'ajax': 1,
                    'delete': 1
                });
            });
        },
        'onFailure': function(xhr){
            TAN.alert( xhr.responseText );
        }
    }).get({
        'ajax': 1    
    });
}