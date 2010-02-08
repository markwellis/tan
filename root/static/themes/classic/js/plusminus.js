window.addEvent('domready', function() {
	$$('.addPlus', '.addMinus').addEvents({
		click: function(e) {
            e.stop();
            var update_me = this.getParent().getElement('.plusminus_holder');
            var plus_minus_jsonreq = new Request.JSON({
                'url': this.href + '?json=1',
                'onSuccess': function(value){
                    if ( !$defined(value.login) ){
                        update_me.set('html', value.count);
                    } else {
                        TAN.login();
                    }
                },
                'noCache': true,
            }).get();
		}
	});
});
