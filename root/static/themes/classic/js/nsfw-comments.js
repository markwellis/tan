var image_src = '/static/images/mouseover.png?r=13';
new Asset.image( image_src );

if (nsfw === 0){
    $$('#blog_wrapper img', '.comment_inner img').filter(function(el, index){
        return (el.getProperty('src').indexOf('/static/fckeditor/editor/images/smiley/') < 0);
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
        $$('#blog_wrapper img', '.comment_inner img').filter(function(el, index){
            return (el.getProperty('src').indexOf('/static/fckeditor/editor/images/smiley/') < 0);
        }).each(function(el) {
            resize_image(el, el);
        });
    });
}

function resize_image(image, el){
    if (image.width > 600){
        var width = image.width;
        var height = image.height;
        image.width = 600;
        image.height = 600 * (height / width);
    }
    el.setStyles({
        'width': image.width + 'px',
        'height': image.height + 'px'
    });
}
