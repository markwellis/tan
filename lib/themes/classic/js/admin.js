window.addEvent('domready', function() {
	$('lookup_user').addEvents({
		click: function(e) {
            if ( $('username').value ){
                var req = new Request.JSON({
                    url:'/admin?username=' + $('username').value,
           	    	onRequest:function(){
        	    		$('admin_area').set('html', '');
                        $('delete_area').set('html', '');
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
                                + '<input type="submit" onclick="if (confirm(\'are you 200% *sure* this is nova?\')){this.disabled=1; return 1;} else {return 0;}" value="delete"/>'

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


	$('lookup_link').addEvents({
		click: function(e) {
            if ( $('link_id').value ){
                var req = new Request.JSON({
                    url:'/admin?link_id=' + $('link_id').value,
           	    	onRequest:function(){
        	    		$('admin_area').set('html', '');
                        $('delete_area').set('html', '');
        	    	},
                    onComplete:function(json_data){
                        if (json_data != null){
                            $each(json_data, function(value, key){
                                var li = new Element('li', {
                                    'html': key + ': <strong>' + value + '</stong>',
                                });
                                li.inject($('admin_area'));
                            });

                            var formdata = '<input type="hidden" name="link_id" value="' + json_data['link_id'] + '" />'
                                + '<input type="submit" onclick="if (confirm(\'are you sure\')){this.disabled=1; return 1;} else {return 0;}" value="delete"/>'

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

	$('lookup_blog').addEvents({
		click: function(e) {
            if ( $('blog_id').value ){
                var req = new Request.JSON({
                    url:'/admin?blog_id=' + $('blog_id').value,
           	    	onRequest:function(){
        	    		$('admin_area').set('html', '');
                        $('delete_area').set('html', '');
        	    	},
                    onComplete:function(json_data){
                        if (json_data != null){
                            $each(json_data, function(value, key){
                                var li = new Element('li', {
                                    'html': key + ': <strong>' + value + '</stong>',
                                });
                                li.inject($('admin_area'));
                            });

                            var formdata = '<input type="hidden" name="blog_id" value="' + json_data['blog_id'] + '" />'
                                + '<input type="submit" onclick="if (confirm(\'are you sure\')){this.disabled=1; return 1;} else {return 0;}" value="delete"/>'

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

	$('lookup_pic').addEvents({
		click: function(e) {
            if ( $('pic_id').value ){
                var req = new Request.JSON({
                    url:'/admin?pic_id=' + $('pic_id').value,
           	    	onRequest:function(){
        	    		$('admin_area').set('html', '');
                        $('delete_area').set('html', '');
        	    	},
                    onComplete:function(json_data){
                        if (json_data != null){
                            $each(json_data, function(value, key){
                                var li = new Element('li', {
                                    'html': key + ': <strong>' + value + '</stong>',
                                });
                                li.inject($('admin_area'));
                            });

                            var formdata = '<input type="hidden" name="pic_id" value="' + json_data['picture_id'] + '" />'
                                + '<input type="submit" onclick="if (confirm(\'are you sure\')){this.disabled=1; return 1;} else {return 0;}" value="delete"/>'

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
