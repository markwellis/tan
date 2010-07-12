window.addEvent('domready', function() {
	$$('.TAN-plusminus div a').addEvent('click', function(e) {
        e.stop();
        var update_me = this.getParent().getElement('span');
        
        var add_class_to = this;
        var selected_class = this.getParent().get('class') + '-selected';

        var plus_minus_jsonreq = new Request.JSON({
            'url': this.href,
            'noCache': true,
            'onSuccess': function(value){
                if ( !$defined(value.login) ){
                    update_me.set('html', value.count);
                    if ( value.deleted ){
                        add_class_to.removeClass( selected_class );
                    } else {
                        add_class_to.addClass( selected_class );
                    }
                } else {
                    TAN.login();
                }
            }
        }).get({
            'json': 1
        });
	});
});
