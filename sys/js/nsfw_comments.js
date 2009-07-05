var i = 0;
var j = 0;


window.addEvent('domready', function() {
    $$('.comment img').each(function(el) {
        if (el.src.indexOf('/sys/js/fckeditor/editor/images/smiley/') < 0){
            var img = new Element('img', {
                'src': '/sys/images/mouseover.jpg',
                'style': 'display:none',
                'id': 'nsfw_hid_pic' + i
            });
            el.set('opacity','.001');

            el.addEvent('mouseover', function(e){
                this.set('opacity','1');
                e.stop();
            });

            el.addEvent('mouseout', function(e){
                this.set('opacity','.001');
                e.stop();
            });

            $('comment_wrapper').grab(img); 

            ++i;
        }
    });
});

window.addEvent('load', function() {
    $$('.comment img').each(function(el) {
        if (el.src.indexOf('/sys/js/fckeditor/editor/images/smiley/') < 0){
            var cords = el.getCoordinates();
            var img = $('nsfw_hid_pic' + j);

           
            if (img){
                img.setStyles({
                    'display': 'block',
                    'position': 'absolute',
                    'left': cords.left + 'px',
                    'top': cords.top + 'px',
                    'width': cords.width + 'px',
                    'height': cords.height + 'px',
                    'z-index': 1
                });
            }

            el.setStyles({
                'position': 'relative',
                'z-index': 2
            });

            ++j;
        }
    });
});