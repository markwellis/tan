window.addEvent('domready', function() {
    $$('.container').fade('out');

    $$('#inside li').addEvents({
        'mouseenter': function(e){
            e.stop();
            var container = $('container_' + this.id);

            if ($defined(container)){
                var image_link = this.getElement('.picture_thumb');
                container.position({
                    'relativeTo': this,
                    'offset': {
                        'x': -180,
                        'y': -200 
                    }
                });
                
                var fade = function fade(){
                    this.fade('in');
                    this.removeClass('hidden');
                }

                this.store('delay', fade.delay(300, container));
            }
        },
        'mouseleave': function(e){
            e.stop();
            var container = $('container_' + this.id);

            if ($defined(container)){
                container.fade('toggle');
                $$('.container').addClass('hidden');

                $clear(this.retrieve('delay'));
                this.eliminate('delay');
            }
        }
    });
});