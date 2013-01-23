[
    new Element('h2', {
        'class': 'TAN-type-' + stash.type,
        'text': stash.title
    }),
    new Element('a', {
        'href': 'view/' + stash.type + '/' + stash.id
    }).adopt(
        new Element('img', {
            'class': 'TAN-object-image',
            'src': stash.image,
            'alt': ''
        })
    ),
    new Element('p', {
        'text': stash.description ? stash.description : ''
    }),
    new Element('span', {
        'class': 'TAN-object-info-bar'
    }).adopt(
        new Element('a', {
            'class': 'TAN-object-user TAN-pipe-right',
            'href': 'profile/' + stash.username, //TODO uriencode
            'text': ' ' + stash.username 
        }).grab(
            new Element('img', {
                'src': 'images/avatar.gif',
                'alt': '#'
            }),
            'top'
        ),
        new Element('a', {
            'class': 'TAN-plus',
            'href': '#',
            'text': 'TIN (' + stash.plus + ')'
        }),
        new Element('span', {
            'class': 'TAN-object-score',
            'text': stash.score
        }),
        new Element('a', {
            'class': 'TAN-minus TAN-pipe-right',
            'href': '#',
            'text': 'TAN (' + stash.minus + ')'
        }),
        new Element('a', {
            'href': '#',
            'text': ' ' + stash.comments
        }).grab(
            new Element('img', {
                'src': 'images/comment.png',
                'alt': '#'
            }),
            'top'
        )
    )
];
