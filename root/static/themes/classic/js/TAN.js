var TAN_class = new Class({
    alert: function (log_text){
        alert(log_text);
    },
    log: function (log_text){
        this.alert("Depricated: TAN.log called\n" + log_text);
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
