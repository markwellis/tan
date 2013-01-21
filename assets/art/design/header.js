tan.template.register("header", function(){
    return Element('div', {
        "class": "TAN-header"
    }).adopt( 
        new Element('h1', {
            "class": "TAN-logo",
            "html": "This Aint News TAN"
        }), 
        new Element('div', {
            'class': 'TAN-top-menu',
        }).adopt(
            new Element('p').adopt(
                new Element('a', {
                    'href': '#',
                    'text': 'Stats'
                }),
                new Element('a', {
                    'href': '#',
                    'text': 'Chat'
                }),
                new Element('a', {
                    'href': '#',
                    'text': 'Logout'
                }),
                new Element('a', {
                    'href': '#',
                    'text': 'Donate'
                })
            ),
            new Element('p').adopt(
                new Element('a', {
                    'href': '#',
                    'text': 'Profile'
                }),
                new Element('a', {
                    'href': '#',
                    'text': 'Enable Filter' //TODO
                }),
                new Element('a', {
                    'href': '#',
                    'text': 'Admin Log'
                }),
                new Element('a', {
                    'href': '#',
                    'text': 'FAQ'
                })
            )
        )
    );
} );
