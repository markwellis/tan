[
    new Element('h2', {
        'text': stash.title
    }),
    new Element('a', {
        'href': 'view/' + stash.type + '/' + stash.id
    }).adopt(
        new Element('img', {
            'class': 'TAN-object-image',
            'src': 'images/pacino.jpg',
            'alt': ''
        })
    ),
    new Element('p', {
        'text': stash.description
    }),
    new Element('span', {
        'class': 'TAN-object-info-bar'
    }).adopt(
        new Element('a', {
            'class': 'TAN-object-user',
            'href': 'profile/' + stash.username,
            'text': stash.username
        }).adopt(
            new Element('img', {
                'src': 'images/avatar.gif',
                'alt': '#'
            })
        )
        /*
                        <a href="#" class="TAN-tintan">TIN (6)</a> 201 <a href="#" class="TAN-tintan">TAN (0)</a>
                        <a href="#"><img src="images/comment.png" alt="" /> 9</a>
        */
    )

];
