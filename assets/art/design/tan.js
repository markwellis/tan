var template = {
    "_templates": {},
    "register": function( name, call ){
        tan.debug('template: ' + name + ' registering');

        if ( typeof( this._templates[name] ) != 'undefined' ){
            tan.debug('template: ' + name + ' already registered');

            return;
        }
        this._templates[name] = call;
        tan.debug('template: ' + name + ' registered');
    },
    "_load": function( name ){
        tan.debug('template: ' + name + ' loading');

        //asset doesn't offer async
        var req = new Request( {
            "url": name + '.js',
            "async": false,
            "method": "get",
            "onSuccess": function( script ){
                tan.debug('template: ' + name + ' fetched');
                if ( tan.template._templates[name] == undefined ){
                    tan.debug('template: ' + name + " didn't call tan.template.register");
                    tan.template._templates[name] = null;
                }

            },
            "onFailure": function( xhr ){
                tan.debug('template: ' + name + ' load failed, code: ' + xhr.status);
                tan.template._templates[name] = null;
            } 
        } ).send();
    },
    "process": function( name, vars ){
        tan.debug('template: ' + name + ' processing');
        if ( this._templates[name] == undefined ){
            tan.debug('template: ' + name + ' not loaded, loading');

            this._load( name );
        }

        if ( this._templates[name] === null ){
            tan.debug('template: ' + name + ' not found');
            return;
        }

        $$('body')[0].adopt( this._templates[name]( name, vars ) );
    }
};

var tan = {
    "template": template,
    "debug": function( data ){
        if ( typeof( console ) != 'undefined' ){
            console.log( data );
        }
    }
};
