window.addEvent('load', function() {
    if ( document.id('cropper') ){
        new Lasso.Crop('cropper',{
            preset : [0,0,100,100],
            handleSize : 4,
            opacity : .6,
            color : '#7389AE',
            onResize: function(cords){
                document.id('cords').value = JSON.encode(cords);
            }
        });

    } else {
        document.id('avatar').addEvent('click',function(e){
            this.getParent().getElement('input:[type="submit"]').disabled = 0;
        });
    }

    document.id('crop_form').addEvent('submit',function(e){
        if ( document.id('avatar') && !document.id('avatar').value ){
            TAN.alert('Please select an image to upload');
            return false;
        }
        e.target.getElement('input:[type="submit"]').disabled = 1;
    });
});
