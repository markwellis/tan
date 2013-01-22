var els = new Elements();

tan.template._css.each( function( css ){
    els.push( new Element('link', {
        "type": "text/css",
        "rel": "stylesheet", 
        "media": "screen", 
        "href": tan.config.css_path + '/' + css
    } ) );
} );

els;
