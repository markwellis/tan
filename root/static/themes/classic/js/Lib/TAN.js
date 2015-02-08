//http://stackoverflow.com/questions/14267457/firefox-18-breaks-mootools-1-2-5-selector-engine
String.prototype.contains = function(string, separator){
    return (separator) ? (separator + this + separator).indexOf(separator + string + separator) > -1 : String(this).indexOf(string) > -1;
};

var TAN_class = new Class({
    initialize: function(){
        /*
            The TAN class is only called on domready, so 
            we don't need to wrap anything
        */
        this.overlay = new Element('div', {
            "styles": {
                "position": "fixed",
                "left": "0px",
                "right": "0px",
                "top": "0px",
                "bottom": "0px",
                "background": "transparent url('/static/images/overlay.png') repeat left top",
                "display": "none",
                "visibility": "hidden"
            },
            'events': {
                "click": function(){
                    this.set('styles', {
                        "display": "none",
                        "visibility": "hidden"
                    });
                }
            }
        });

        this.box = new Element('div', {
            "styles": {
                "position": "relative",
                "top": "40%",
                "text-align": "center",
                "margin": "0px auto",
                "width": "450px",
                "padding": "5px",
                "border": "1px solid #000",
                "background-color": "#fff",
                "font-size": "1.2em"
            }
        });

        this.overlay.grab(this.box);

        $$("body").grab(this.overlay);

        this.load_recent_comments();
    },
    alert: function (log_text){
        this.box.set('html', log_text);
        this.overlay.set('styles', {
            "display": "block",
            "visibility": "visible"
        });
    },
    login: function (message){
        // do some login logic here...
        if ( !$defined(message) ){
            message = 'Please login';
        }
        this.alert('<a href="/login/">' + message + '</a>');
    },
    nsfw: function(value){
        if ( !!(value || value === 0) ){
            //delete old cookie
            Cookie.dispose('nsfw');
            Cookie.write('nsfw', value, {
                'path': '/',
                'duration': 365 * 10
            });
            return value;
        }

        return parseInt(Cookie.read('nsfw')) || 0;
    },
    load_recent_comments: function() {
        new Request.HTML( {
            'url': '/recent/comments',
            'noCache': true,
            "onSuccess": function( tree, elements, html ) {
                elements.each( function( element, index ) {

                    var comment = element.get('data-comment');
                    if ( comment == undefined ) return;

                    var username = element.get('data-username');

                    new FloatingTips( element, {
                        content: function(e) { return comment },
                        position: 'right',
                        center: false,
                    });
                } );

                var recent_comments = document.id('recent_comments');
                recent_comments.getElements('*').destroy();
                recent_comments.adopt( tree );
            }
        } ).get( {
            'ajax': 1
        } );
    }
});

var TAN;
/*
IMPORTANT
make sure TAN is created in a domready or else 
it'll not work too good!
*/
window.addEvent('domready', function(){
    TAN = new TAN_class();
});
