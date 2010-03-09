window.addEvent('domready', function() {
	$$('.lookup').addEvents({
		click: function(e) {
            var kind = this.id.substr(7);
            if ( $(kind + '_id').value ){
                var req = new Request.JSON({
                    url:'/admin?' + kind + '_id=' + $(kind + '_id').value,
           	    	onRequest:function(){
        	    		$('admin_area').set('html', '');
                        $('delete_area').set('html', '');
        	    	},
                    onComplete:function(json_data){
// why is there no comments?
                        if (json_data != null){
                            $each(json_data, function(value, key){
                                var li = new Element('li', {
                                    'html': key + ': <strong>' + value + '</stong>',
                                });
                                li.inject($('admin_area'));
                            });

                            var formdata = '<input type="hidden" name="' + kind + '_id" value="' 
                                + json_data[kind + '_id'] + '" />'
                                + '<label for="reason">delete reason</label>'
                                + '<input name="reason" id="reason" type="text" /><br />'
                            if ( kind === 'user' ){
                                formdata += '<label for="delete_commetns">delete comments? :/</label>'
                                    +'<input type="checkbox" id="delete_comments" name="delete_comments" value="1" /><br />';
                            }
                            formdata += '<input type="submit" id="delete_button" value="delete"/>';

                            var form = new Element('form', {
                                method: 'post',
                                html: formdata
                            });
                            form.inject($('delete_area'));

                            $('delete_button').addEvents({
                                'click': function(e){
                                    if ( $('reason').value < 3 ){
                                        alert('please enter a reason');
                                        e.stop();
                                        return false;
                                    }

                                    if ( !confirm('are you sure?') ){
                                        e.stop();
                                        return false;
                                    }

                                    this.disabled=1;
                                }
                            });
                        } else {
                            var li = new Element('li', {
                                'html': 'fuck all found',
                            });
                            li.inject($('admin_area'));
                        }
                    },
                    noCache: true
                }).send();
            }
		}
	});
});
