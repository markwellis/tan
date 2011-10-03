window.addEvent('domready', function() {
	$$('.TAN-plusminus a').addEvent('click', function(e) {
        e.stop();
        var update_me = this.getParent().getElement('.TAN-object-score');
        
        var add_class_to = this;
        var selected_class = this.get('class').split(' ')[0] + '-selected';

        var plus_minus_jsonreq = new Request.JSON({
            'url': this.href,
            'noCache': true,
            'onSuccess': function(json){
                if ( !$defined(json.login) ){
                    update_me.set('html', json.score);
                    if ( json.deleted ){
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
