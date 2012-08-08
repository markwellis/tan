window.addEvent('domready', function() {
	$$('.TAN-plusminus a').addEvent('click', function(e) {
        e.stop();
        
        var plusminus = this.getParent().getParent().getParent();
        new Request.JSON({
            'url': this.href,
            'noCache': true,
            'onSuccess': function( json ){
                if ( json.login ){
                    TAN.login();
                    return;
                }

                var plus_selected = plusminus.getElement('.TAN-plus-arrow-selected');
                if ( plus_selected ){
                    if ( plus_selected.hasClass('TAN-plus-arrow-selected') ){
                        var remove_plus_selected = new Fx.Morph( plus_selected, {
                            "link": "chain",
                            "onComplete": function(){
                                plus_selected.removeClass('TAN-plus-arrow-selected');
                            }
                        } );
                        remove_plus_selected.start('.TAN-plus-arrow');
                    }
                }
                
                var minus_selected = plusminus.getElement('.TAN-minus-arrow-selected');
                if ( minus_selected ){
                    if ( minus_selected.hasClass('TAN-minus-arrow-selected') ){
                        var remove_minus_selected = new Fx.Morph( minus_selected, {
                            "link": "chain",
                            "onComplete": function(){
                                minus_selected.removeClass('TAN-minus-arrow-selected');
                            }
                        } );
                        remove_minus_selected.start('.TAN-minus-arrow');
                    }
                }

                //add class to correct item
                if ( json.created ){
                    var classname = 'TAN-' + json.created + '-arrow';
                    var el = plusminus.getElement('.' + classname);
                    el.set('morph', {
                        "link": "chain",
                        "onStart": function(){
                            el.addClass('morph-in-action');
                        },
                        "onComplete": function(){
                            el.removeClass('morph-in-action');
                            el.addClass( classname + '-selected' );
                        },
                        "onCanel": function(){
                            el.removeClass('morph-in-action');
                            el.removeClass( classname + '-selected' );
                            el.set('styles', {});
                        }
                    } );
                    el.morph('.' + classname + '-selected');
                } else {
                    // cancel any in progress morphs (happens if click twice fast on arrow)
                    plusminus.getElements('.morph-in-action').each( function( el ){
                        el.get('morph').cancel();
                    } );
                }
                //update plus/minus/score count
                plusminus.getElement('.TAN-plus').set( 'html', json.plus );
                plusminus.getElement('.TAN-minus').set( 'html', json.minus );
                plusminus.getElement('.TAN-object-score').set( 'html', json.score );
            }
        }).get({
            'json': 1
        });
	});
});
