(function(){
    var output = []

    tan.template._css.each( function( css ){
        output.push(
            new Element('link', {
                "type": "text/css",
                "rel": "stylesheet", 
                "media": "screen", 
                "href": tan.config.css_path + '/' + css
            } )
        );
    } );

    return output;
})();
