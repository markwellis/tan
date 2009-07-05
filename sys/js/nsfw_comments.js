var i = 0;
var j = 0;


window.addEvent('domready', function() {
    $$('.comment img').each(function(el) {
        if (el.src.indexOf('/sys/js/fckeditor/editor/images/smiley/') < 0){
            var width = el.width;
            var height = el.height;

            var img = new Element('img', {
                'src': '/sys/images/mouseover.jpg',
                'style': 'border:1px solid #000;visibility:hidden',
                'id': 'nsfw_hid_pic' + i
            });

            img.addEvent('mouseover', function(e){
                this.set('opacity','.001');
                e.stop();
            });

            img.addEvent('mouseout', function(e){
                this.set('opacity','1');
                e.stop();
            });

            var parent = el.getParent();

            if (parent.get('tag') === 'a'){
                parent.grab(img); 
            } else {
                $('comment_wrapper').grab(img); 
            }

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
                    'position': 'absolute',
                    'left': cords.left + 'px',
                    'width': cords.width + 'px',
                    'height': cords.height + 'px',
                    'visibility': 'visible'
                });
    
                if (img.getParent().get('tag') !== 'a'){
                    img.setStyles({
                        'top': cords.top + 'px'
                    });
                }
            }

            ++j;
        }
    });
});