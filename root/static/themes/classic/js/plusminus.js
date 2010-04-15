window.addEvent('domready', function() {
	$$('.addPlus', '.addMinus').addEvents({
		click: function(e) {
            e.stop();
            var update_me = this.getParent().getElement('.plusminus_holder');
            
            var add_class_to = this;
            var selected_class = 'selected';

            if ( this.hasClass('addPlus') ){
                selected_class = 'p' + selected_class;
            } else {
                selected_class = 'm' + selected_class;
            }

            var plus_minus_jsonreq = new Request.JSON({
                'url': this.href,
                'noCache': true,
                'onSuccess': function(value){
                    if ( !$defined(value.login) ){
                        update_me.set('html', value.count);
                        add_class_to.toggleClass( selected_class );
                    } else {
                        TAN.login();
                    }
                },
            }).get({
                'json': 1
            });
		}
	});
});
