window.addEvent('domready', function() {
	$('lookup').addEvents({
		click: function(e) {
            if ( $('username').value ){
                var req = new Request.JSON({
                    url:'/admin?username=' + $('username').value,
           	    	onRequest:function(){
        	    		$('admin_area').set('html', '');
        	    	},
                    onComplete:function(json_data){
                        if (json_data != null){
                            $each(json_data, function(value, key){
                                var li = new Element('li', {
                                    'html': key + ': <strong>' + value + '</stong>',
                                });
                                li.inject($('admin_area'));
                            });

                            var formdata = '<input type="hidden" name="ban_id" value="' + json_data['user_id'] + '" />'
                                + '<input type="submit" onclick="if (confirm(\'are you 200% *sure* this is nova?\')){this.disabled=1; return 1} return 0" value="delete"/>'

                            var form = new Element('form', {
                                method: 'post',
                                html: formdata
                            });
                            form.inject($('delete_area'));
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
