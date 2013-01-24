new Element('div', {
    "class": "TAN-header"
}).adopt( 
    new Element('h1', {
        "class": "TAN-logo"
    }).adopt(
        new Element('a', {
            "href": "/",
            "text": "This Aint News TAN"
        })
    ), 
    new Element('div', {
        'class': 'TAN-top-menu'
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
        ),
        new Element('form', {
            'method': 'get',
            'action': '/search/',
            'class': 'TAN-search'
        }).adopt(
            new Element('fieldset').adopt(
                new Element('input', {
                    'type': 'text',
                    'value': '', //TODO
                    'name': 'q'
                }),
                new Element('input', {
                    'type': 'submit',
                    'value': 'Search'
                })
            )
        )
    )
);
