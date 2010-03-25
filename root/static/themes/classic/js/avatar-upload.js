window.addEvent('load', function() {
    if ( $('cropper') ){
        new Lasso.Crop('cropper',{
            ratio : [1,1],
            preset : [1,1,100,100],
            min : [50,50],
            handleSize : 4,
            opacity : .6,
            color : '#7389AE',
            onResize: function(cords){
                $('cords').value = JSON.encode(cords);
            }
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
