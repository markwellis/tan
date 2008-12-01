Event.observe(window, 'load', function() {
    listItems = $('mainmenu').childElements();
    currentList = listItems[listItems.length - 1].down().next();
    
    for (i = 0; i < listItems.length; i++){
        Event.observe(listItems[i], 'click', function(e) {
            var list = Event.element(e).next();
            if (list.previous().hasClassName('openlist')){
                currentList.previous().addClassName('openlist');
                Effect.toggle(currentList, 'blind', { duration: 0.3 });
                Effect.toggle(list, 'blind', { duration: 0.3, queue: { position: 'end', scope: 'accordion', limit: 1 }});
                list.previous().removeClassName('openlist');
                currentList = list;
            }
        });
        if (i < (listItems.length - 1)){
            listItems[i].down(1).hide();
            listItems[i].down(1).removeClassName('hidden');
        }
    }
});