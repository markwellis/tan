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
                    },
                    'onFailure': function(){
                        TAN.log('fail');
                        $('submit_comment').disabled = 1;
                    }
                }).get({
                    'comment': input_comment
                });

                $('submit_comment').disabled = 1;
            }
		}
	});
});
