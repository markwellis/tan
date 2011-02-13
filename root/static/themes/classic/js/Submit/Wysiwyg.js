window.addEvent('domready', function() {
    if ( typeof( tinyMCE ) != 'undefined' ){
        document.id('submit_form').addEvent( 'submit', function(){
            var classes = this.getElements('.wysiwyg')[0].get('class').toString().split(' ');
            var content = tinyMCE.get( this.getElements('.wysiwyg')[0].get('id') ).getContent();

            var error_messages = [];
            var msg_pos;

            classes.each( function( class_name ){
                var split_class_name = class_name.split(':');
                switch( split_class_name[0] ){
                    case 'required':
                        if ( content.trim() == '' ){
                            error_messages.push('Error: This field is required.');
                        }
                        break;
                    case 'minLength':
                        if ( 
                            ( typeof( split_class_name[1] ) != 'undefined' ) 
                            && ( content.length < split_class_name[1] )
                        ){
                            error_messages.push(
                                'Error: Please enter at least ' 
                                + split_class_name[1] 
                                + ' characters (you entered ' 
                                + content.length
                                + ' characters).'
                            );
                        }
                        break;
                    case 'maxLength':
                        if ( 
                            ( typeof( split_class_name[1] ) != 'undefined' ) 
                            && ( content.length > split_class_name[1] )
                        ){
                            error_messages.push(
                                'Error: Please no more than ' 
                                + split_class_name[1] 
                                + ' characters (you entered ' 
                                + content.length
                                + ' characters).'
                            );
                        }
                        break;
                    case 'msgPos':
                        if ( typeof( split_class_name[1] ) != 'undefined' ){
                            msg_pos = split_class_name[1];
                        }
                        break;
                }
            } );

            $( msg_pos ).empty();
            if ( error_messages.length ){
                if ( msg_pos ){
                    error_messages.each( function( error_message, i ){
                        var error_element = new Element( 'div', {
                            "text": error_message,
                            "class": 'validation-advice'
                        } );
                        $( msg_pos ).adopt( error_element );
                    } );
                }
                return false;
            }
        } );
    }
});
