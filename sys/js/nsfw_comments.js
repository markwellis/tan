var i = 0;
var j = 0;

/*  
 * this isnt in a domready wrapper coz its directly after the images, so it'll be ok
 * and hopefully a little faster than a domready 
 */
if (nsfw === 1){
    $$('#blog_wrapper img', '.comment img').each(function(el) {
        if (el.src.indexOf('/sys/js/fckeditor/editor/images/smiley/') < 0){
            var img = new Element('img', {
                'src': '/sys/images/mouseover.png?r=8',
                'style': 'display:none',
                'id': 'nsfw_hid_pic' + i
            });
            el.set('opacity','.001');

            el.addEvents({
                'mouseover': function(e){
                    img.fade('.001');
                    this.fade('1');
                    e.stop();
                },
                'mouseout': function(e){
                    img.fade('1');
                    this.fade('.001');
                    e.stop();
                }
            });

            $('nsfw_blocker_containter').grab(img); 

            ++i;
        }
    });
}

window.addEvent('load', function() {
    $$('#blog_wrapper img', '.comment img').each(function(el) {
        if (el.src.indexOf('/sys/js/fckeditor/editor/images/smiley/') < 0){
            var cords = el.getCoordinates();

            if (cords.width > 600){
                el.width = 600;
                el.height = 600 * (cords.height / cords.width);
                var cords = el.getCoordinates();
            }

            if (nsfw === 1){
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
            }

            el.setStyles({
                'position': 'relative',
                'z-index': 2
            });

            ++j;
        }
    });
});