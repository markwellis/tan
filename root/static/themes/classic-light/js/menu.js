var selected_menu_type;
window.addEvent('domready', function() {
    $$('.TAN-menu-tab').addEvent('click', function(e) {
        e.stop();
        var menu_type = this.getProperty('class').split(' ')[1].replace(/.*-/, '');

        if ( selected_menu_type ){
            var selected_menu = $$('.TAN-menu-tab-' + selected_menu_type + '-selected');
            selected_menu.removeClass('TAN-menu-tab-' + selected_menu_type + '-selected');
            $$('.TAN-menu-' + selected_menu_type).setStyle('display', 'none');
        }
        this.addClass('TAN-menu-tab-' + menu_type + '-selected');
        $$('.TAN-menu-' + menu_type).setStyle('display', 'block');
        selected_menu_type = menu_type;
    });
});
