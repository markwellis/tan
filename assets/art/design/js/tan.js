//don't cause errors when there's no console 
if ( typeof( console ) == 'undefined' ){
    var console = {};
}
if ( typeof( console.log ) == 'undefined' ){
    console.log = function(){};
}
if ( typeof( console.groupCollapsed ) == 'undefined' ){
    console.groupCollapsed = function(){};
}
if ( typeof( console.groupEnd ) == 'undefined' ){
    console.groupEnd = function(){};
}

var _template = {
    "_templates": {},
    "register": function( name, call ){
        if ( typeof( this._templates[name] ) != 'undefined' ){
            console.log('already registered');

            return;
        }
        this._templates[name] = function( stash ){ return eval( call ) };
        console.log('registered');
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
                console.log('load failed, code: ' + xhr.status);
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
        console.groupCollapsed( 'template: ' + name );
        var data;

        try{
            if ( this._templates[name] == undefined ){
                console.log('loading');

                this._load( name );
            }

            if ( this._templates[name] === null ){
                console.log('not found');
                return;
            }
            
            console.log('processing');
            data = this._templates[name]( stash );
        } catch( e ){
            console.log( 'caught excption: ' + e.message + " " +  name );
        }
        console.groupEnd( 'template: ' + name );

        return data;
    }
};

var tan = {
    "template": _template,
    "config": function(){
        //TODO IRL this will be part of the page request or something
        var data;
        new Request.JSON( {
            "url": 'json/config.json',
            "async": false,
            "method": "get",
            "onSuccess": function( json ){
                data = json;
            }
        } ).send();

        return data;
    }()
};
