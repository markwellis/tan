window.addEvent('load', function() {
    $$('.comment img').each(function(el) {
        if (el.src.indexOf('/sys/js/fckeditor/editor/images/smiley/') < 0){
            var width = el.width;
            var height = el.height;

            first_hide(el);

            el.addEvent('mouseenter', function(e){
                show_image(this);
            });
    
            el.addEvent('mouseleave', function(e){
                hide_image(this);
            });
        }
    });
});

function first_hide(el){
    var width = el.width;
    var height = el.height;

    el.title = el.src;
    el.src = '/sys/images/mouseover.jpg';
    el.style.border = '1px solid #000';
    
    if (width && height){
        el.width = width;
        el.height = height;
    }
}

function hide_image(el){
    var title = el.src;
    el.src = el.title;
    el.title = title;
    el.style.border = '1px solid #000';
}

function show_image(el){
    var src = el.title;
    el.title = el.src;
    el.src = src;
    el.style.border = '1px solid #fff';
}