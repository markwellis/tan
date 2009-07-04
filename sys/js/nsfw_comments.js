window.addEvent('domready', function() {
    $$('.comment img').each(function(el) {
        if (el.src.indexOf('/sys/js/fckeditor/editor/images/smiley/') < 0){
            var width = el.width;
            var height = el.height;

            el.title = el.src;
            el.src = '/sys/images/mouseover.jpg';
            el.style.border = '1px solid #000';

            el.height = height;
            el.width = width;
    
            el.addEvent('mouseenter', function(e){
                var src = el.title;
                el.title = el.src;
                el.src = src;
                el.style.border = '1px solid #fff';
            });
    
            el.addEvent('mouseleave', function(e){
                var title = el.src;
                el.src = el.title;
                el.title = title;
                el.style.border = '1px solid #000';
            });
        }
    });
});
