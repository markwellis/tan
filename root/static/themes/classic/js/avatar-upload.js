window.addEvent('load', function() {
    if ( $('cropper') ){
        new Lasso.Crop('cropper',{
            preset : [0,0,100,100],
            handleSize : 4,
            opacity : .6,
            color : '#7389AE',
            onResize: function(cords){
                $('cords').value = JSON.encode(cords);
                $('width').value = cords['w'];
                $('height').value = cords['h'];
            }
        });
        new MooRainbow('bgcolour', {
            'imgPath': '/static/images/mooRainbow/',
            'startColor': [255,255,255],
            'onChange': function(color) {
                $('bgcolour').setStyle('background-color', color.hex);
                $('bgcolour').value = color.hex;
                $('bgcolour').setStyles({
                    'background-color': color.hex,
                    'color': color.hex
                });
            }
        });

        $('crop_form').addEvent('submit', function(e){
            e.stop();
            var crop = new Request.JSON({
                'url': this.action + '?ajax=1',
                'data': {
                    'cords': e.target.getElement('#cords').value,
                    'bgcolour': e.target.getElement('#bgcolour').value
                },
                'onSuccess': function(data){
                    if ( data ){
                    // UPDATE preview image...
                        var date = new Date;
                        $('preview').setStyle('background-image', 'url(' + $('cropper').src.replace(/\.no_crop\?m=\d+/, '_preview?m=' + date.getTime()) + ')');
                    } else {
                        TAN.alert('Error');
                    }
                    e.target.getElement('input:[type="submit"]').disabled = 0;

                }
            }).get();
        });

    } else {
        $('avatar').addEvent('change',function(e){
            this.getParent().getElement('input:[type="submit"]').disabled = 0;
        });
    }

    $('crop_form').addEvent('submit',function(e){
        if ( $('avatar') && !$('avatar').value ){
            TAN.alert('Please select an image to upload');
            return false;
        }
        e.target.getElement('input:[type="submit"]').disabled = 1;
    });
});
