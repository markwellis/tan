var selected_menu_type;
window.addEvent('domready', function() {
    $$('.TAN-menu-tab').addEvent('click', function(e) {
        e.stop();
        var menu_type = this.getProperty('class').split(' ')[1].replace(/.*-/, '');

        if ( selected_menu_type ){
            var selected_menu = $$('.TAN-type-' + selected_menu_type);
            selected_menu.removeClass('TAN-menu-tab-' + selected_menu_type + '-selected');
            $$('.TAN-menu-' + selected_menu_type).setStyle('display', 'none');
        }
        this.addClass('TAN-menu-tab-' + menu_type + '-selected');
        $$('.TAN-menu-' + menu_type).setStyle('display', 'block');
        selected_menu_type = menu_type;
    });

    $$('.nsfw_filter').addEvent('click', function(e){
        e.stop();
        var nsfw = TAN.nsfw();
        if ( nsfw === 0 ){
            var disable = confirm(
                "Are you sure you want to disable the NSFW work filter?"
                +"\nThere will be content which is not suitable for work"
            );

            if ( disable == false ){
                return 0;
            }
        }
        TAN.nsfw( nsfw ^ 1 );
        window.location.reload();
    });

    $$('.mibbit').addEvent('click', function(e) {
        pop_up("https://widget.mibbit.com/?server=irc.mibbit.com%3A%2B6697&chatOutputShowTimes=true&autoConnect=true"
          +"&channel=%23thisaintnews&settings=8a8a5ac18a22e7eecd04026233c3df93"
          +"&nick=" + mibbit_nick, 720, 400);
        e.stop();
    });

    if ( $defined($$('.TAN-order-by select')) ){
        $$('.TAN-order-by select').addEvent('change', function(e) {
            var oper = (window.location.toString().indexOf('?') !== -1) ? '&' : '?';
            var order = 'order=' + this.value;

            if (window.location.toString().indexOf('order=') !== -1){
                window.location = window.location.toString().replace(/order\=\w+/, order);
            } else {
                window.location = window.location + oper + order;
            }
            e.stop();
        });
    }
});

function pop_up(url,x,y) {
    var mibbit = window.open(url,'mibbit',"toolbar=no,location=no,status=no,menubar=no,scrollbars=no,resizable=yes,width="+x+",height="+y+",top=110,left=110");
}
