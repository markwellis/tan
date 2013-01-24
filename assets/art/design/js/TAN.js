var TAN = new Class({
    'initialize': function( config ){
        this.config = config;
        this.template = new Template( this.config.template );
    }
});
