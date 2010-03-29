window.addEvent('load', function() {
    if ( $('cropper') ){
        new Lasso.Crop('cropper',{
            preset : [0,0,100,100],
            handleSize : 4,
            opacity : .6,
            color : '#7389AE',
            onResize: function(cords){
                $('cords').value = JSON.encode(cords);
            }
        });

    } else {
        $('avatar').addEvent('click',function(e){
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
