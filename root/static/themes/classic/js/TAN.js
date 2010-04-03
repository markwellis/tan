var TAN_class = new Class({
    initialize: function(){
        /*
            The TAN class is only called on domready, so 
            we don't need to wrap anything
        */
        this.roar = new Roar({
            position: 'upperRight',
            duration: 5000
        });
    },
    alert: function (log_text){
        this.roar.alert('Alert', log_text);
    },
    login: function (message){
        // do some login logic here...
        if ( !$defined(message) ){
            message = 'Please login';
        }
        this.alert(message);
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
