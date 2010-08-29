window.addEvent('domready', function(){
    $$('.TAN-recent-comments a').each(function(element,index) { 
        var title = element.get('title');
        if ( title ) {
            var content = title.split('::'); 
            var title = content[0];
            if ( content[1] ){
                title += ' wrote:';
            } else {
                content[1] = '';
            }

            element.store('tip:title', title);  
            element.store('tip:text', "<p>" + content[1] + "</p>");
        }
    });  

    var tips = new Tips('.TAN-recent-comments a', {
        'className': 'TAN-recent-comment-tip',
        'hideDelay': 50,  
        'showDelay': 50
    });
});
