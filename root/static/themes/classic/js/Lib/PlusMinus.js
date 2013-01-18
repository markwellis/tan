window.addEvent('domready', function() {
	$$('.TAN-plusminus a').addEvent('click', function(e) {
        e.stop();
        
        var plusminus = this.getParent();
        new Request.JSON({
            'url': this.href,
            'noCache': true,
            'onSuccess': function( json ){
                if ( json.login ){
                    TAN.login();
                    return;
                }

                var plus_selected = plusminus.getElement('.TAN-plus-selected');
                if ( plus_selected ){
                    if ( plus_selected.hasClass('TAN-plus-selected') ){
                        plus_selected.removeClass('TAN-plus-selected');
                    }
                }
                
                var minus_selected = plusminus.getElement('.TAN-minus-selected');
                if ( minus_selected ){
                    if ( minus_selected.hasClass('TAN-minus-selected') ){
                        minus_selected.removeClass('TAN-minus-selected');
                    }
                }

                //add class to correct item
                if ( json.created ){
                    var classname = 'TAN-' + json.created;
                    plusminus.getElement('.' + classname).addClass( classname + '-selected' );
                }
                //update plus/minus/score count
                plusminus.getElement('.TAN-object-plus').set( 'html', json.plus );
                plusminus.getElement('.TAN-object-minus').set( 'html', json.minus );
                plusminus.getElement('.TAN-object-score').set( 'html', json.score );
            }
        }).get({
            'json': 1
        });
	});
});
