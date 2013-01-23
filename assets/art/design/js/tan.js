var template = {
    "_templates": {},
    "register": function( name, call ){
        if ( typeof( this._templates[name] ) != 'undefined' ){
            tan.debug('template: "' + name + '" already registered');

            return;
        }
        this._templates[name] = function( stash ){ return eval( call ) };
        tan.debug('template: "' + name + '" registered');
    },
    "_load": function( name ){
        var _this = this;
        //Asset doesn't offer async
        var req = new Request( {
            "url": tan.config.template_path + '/' + name + '.js',
            "async": false,
            "method": "get",
            "onSuccess": function( script ){
                _this.register( name, script );
            },
            "onFailure": function( xhr ){
                tan.debug('template: "' + name + '" load failed, code: ' + xhr.status);
                _this._templates[name] = null;
            } 
        } );

        //don't autoexec template coz we wrap it in a function and eval it
        req.processScripts = function( text ){
            return text;
        };
        
        req.send();
    },
    "process": function( name, stash ){
        if ( this._templates[name] == undefined ){
            tan.debug('template: "' + name + '" loading');

            this._load( name );
        }

        if ( this._templates[name] === null ){
            tan.debug('template: "' + name + '" not found');
            return;
        }
        
        tan.debug('template: "' + name + '" processing');
        return this._templates[name]( stash );
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
