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
        if ( $chk(value) ){
            //delete old cookie
            Cookie.dispose('nsfw');
            Cookie.write('nsfw', value, {
                'path': '/'
            });
            return value;
        }

        return parseInt(Cookie.read('nsfw')) || 0;
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
