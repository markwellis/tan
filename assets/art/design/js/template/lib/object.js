if ( stash.type ){
    new Element('div', {
        'class': 'TAN-object'
    }).adopt(
        tan.template.process( 'lib/object/' + stash.type, stash )
    );
}
