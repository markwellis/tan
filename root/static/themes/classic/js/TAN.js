var TAN_class = new Class({
    log: function (log_text){
        alert(log_text);
    },
    login: function (message){
        // do some login logic here...
        if ( !$defined(message) ){
            message = 'Please login';
        }
        alert(message);
    }
});

var TAN = new TAN_class();
