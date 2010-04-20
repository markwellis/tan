var image_src = '/static/images/mouseover.png?r=13';
new Asset.image( image_src );

// long regex :\
var safe_reg = /\/static\/fckeditor\/editor\/images\/smiley\/|\/static\/smilies\/|\/sys\/js\/fckeditor\/editor\/images\/smiley\/smileys\//;

window.addEvent('domready', function(){
    if (TAN.nsfw() === 0){
        $$('#blog_wrapper img', '.TAN-comment_inner img').filter(function(el, index){
            if ( el.getProperty('src') ){
                return ( !el.getProperty('src').match(safe_reg) );
            }
            return false;
        }).each(function(el) {
            el.addClass('boob_blocked');
            el.setStyle('visibility', 'hidden');
            
            var image = Asset.image(el.getProperty('src'), {
                'onload': function(image){
                    var el = image.retrieve('el');

                    resize_image(image, el);
                    el.setProperty('src', image_src);
                    el.setStyle('visibility', 'visible');
                    el.addEvents({
                        'mouseover': function(e){
                            e.stop();
                            this.setProperty('src', this.retrieve('original_image').src);
                            this.height = this.height;
                            this.width = this.width;
                        },
                        'mouseout': function(e){
                            e.stop();
                            this.setProperty('src', image_src);
                        }
                    });
                },
                'onerror': function(image){
                    var el = image.retrieve('el');
                    image.height = '0px';
                    image.width = '0px';
                    resize_image(image, el);
                }
            });

            image.store('el', el);
            el.store('original_image', image);
            el.setProperty('src', image_src);
        });
    } else {
        window.addEvent('load', function() {
            $$('#blog_wrapper img', '.TAN-comment_inner img').filter(function(el, index){
                if ( el.getProperty('src') ){
                    return ( !el.getProperty('src').match(safe_reg) );
                }
                return false;
            }).each(function(el) {
                resize_image(el, el);
            });
        });
    }
});

function resize_image(image, el){
    if (image.width > 600){
        var width = image.width;
        var height = image.height;
        image.width = 550;
        image.height = 550 * (height / width);
    }
    el.setStyles({
        'width': image.width + 'px',
        'height': image.height + 'px'
    });
}
