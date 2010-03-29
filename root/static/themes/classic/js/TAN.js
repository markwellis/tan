var TAN_class = new Class({
    initialize: function(){
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
    }
});

var TAN;
window.addEvent('domready', function(){
    TAN = new TAN_class();
});
