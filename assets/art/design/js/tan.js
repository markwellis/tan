var template = {
    "_templates": {},
    "register": function( name, call ){
        if ( typeof( this._templates[name] ) != 'undefined' ){
            tan.debug('template: "' + name + '" already registered');

            return;
        }
        this._templates[name] = function(){ return eval( call ) };
        tan.debug('template: "' + name + '" registered');
    },
    "_load": function( name ){
        //asset doesn't offer async
        var req = new Request( {
            "url": tan.config.template_path + '/' + name + '.js',
            "async": false,
            "method": "get",
            "onSuccess": function( script ){
                tan.template.register( name, script );
            },
            "onFailure": function( xhr ){
                tan.debug('template: "' + name + '" load failed, code: ' + xhr.status);
                tan.template._templates[name] = null;
            } 
        } );

        //don't autoexec template coz we do funky things with it
        req.processScripts = function( text ){
            return text;
        };
        
        req.send();
    },
    "process": function( name, vars ){
        tan.debug('template: "' + name + '" processing');
        if ( this._templates[name] == undefined ){
            tan.debug('template: "' + name + '" not loaded, loading');

            this._load( name );
        }

        if ( this._templates[name] === null ){
            tan.debug('template: "' + name + '" not found');
            return;
        }
        
        return this._templates[name]( name, vars );
    }
};

var tan = {
    "template": template,
    "debug": function( data ){
        if ( typeof( console ) != 'undefined' ){
            console.log( data );
        }
    },
    "config": function(){
        //TODO IRL this will be part of the page request or something
        var data;
        new Request.JSON( {
            "url": 'json/config.json',
            "async": false,
            "method": "get",
            "onSuccess": function( json ){
                data = json;
            },
        } ).send();

        return data;
    }()
};
