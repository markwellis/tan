window.addEvent( 'domready', function(){
    $$('.TAN-profile-user-admin-form input[type=submit]').addEvent( 'click', function(){
        return confirm('Are you sure');
    } );
} );
