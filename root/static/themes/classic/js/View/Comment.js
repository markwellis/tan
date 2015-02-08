window.addEvent('domready', function() {
    document.id('comment_form').addEvents({
        submit: function(e) {
            e.stop();

            var input_comment = tinyMCE.get('comment').getContent();
            
            if ( input_comment ){
                var req = new Request.HTML({
                    'url' : this.action,
                    "evalScripts": true,
                    'noCache': true,
                    'onSuccess': function(responseTree, responseElements, responseHTML, responseJavaScript) {
                        document.id('submit_comment').disabled = 0;
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
                        document.id('submit_comment').disabled = 0;
                    },
                    'onFailure': function(){
                        TAN.alert('fail');
                        document.id('submit_comment').disabled = 0;
                    }
                }).post({
                    'comment': input_comment,
                    'ajax': 1
                });

                document.id('submit_comment').disabled = 1;
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
    var comment = link.getParent().getParent().getParent().getElement('.TAN-comment-quoteable');
    
    comment = '[quote user=' + username + ']' + comment.get('html') + '[/quote]';

    tinyMCE.get('comment').execCommand("mceInsertContent", false, comment);
}

function edit_link(link){
    // LOL
    var comment_holder = link.getParent().getParent().getParent();

    var comment_id = comment_holder.id.replace(/\D+/g, '');
    var req = new Request.HTML({
        'url' : link.href,
        'noCache': true,
        'onSuccess': function(responseTree) {
            comment_holder.empty();
            comment_holder.adopt( responseTree );
            tinyMCE.execCommand('mceAddControl', false, 'edit_comment_' + comment_id);

            //submit edit comment
            comment_holder.getElement('#edit' + comment_id).addEvent('click', function(e){
                e.stop();

                var data = {};
                if ( comment_holder.getElement('#_edit-reason') != undefined ){
                    data['_edit-reason'] = prompt('reason for edit?').trim();
                    if ( !data['_edit-reason'] ){
                        return false;
                    }
                }

                var editor_id = 'edit_comment_' + comment_id;
                //js is tarded and cant use varible as a object key coz it accepts barewords keys :/
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

            var post_params = {
                'ajax': 1
            };
            post_params[ 'delete' + comment_id ] = 'Delete'; 

            //delete comment
            comment_holder.getElement('#delete' + comment_id).addEvent('click', function(e){
                e.stop();
                if ( !confirm('Are you sure you want to delete comment?') ){
                    return false;
                }

                if ( comment_holder.getElement('#_edit-reason') != undefined ){
                    post_params['_edit-reason'] = prompt('reason for edit?').trim();
                    if ( !post_params['_edit-reason'] ){
                        return false;
                    }
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
                }).post( post_params );
            });
        },
        'onFailure': function(xhr){
            TAN.alert( xhr.responseText );
        }
    }).get({
        'ajax': 1    
    });
}
