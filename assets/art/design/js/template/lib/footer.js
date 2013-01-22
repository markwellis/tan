new Element('div', {
    'id': 'bottom'
}).adopt(
    new Element('div', {
        'class': 'TAN-footer'
    }).adopt(
        new Element('span', {
            "class": "TAN-whos-online"
        }).adopt(
           new Element('a', {
               'href': '/profile/n0body/'
            }).adopt(
                new Element('img', {
                    'src': 'images/avatar.gif',
                    'alt': 'n0body',
                    'title': 'n0body'
                })
            )
        )
    )
);
