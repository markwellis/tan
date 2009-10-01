var last_tab;
var last_menu;

window.addEvent('domready', function(){
    $$('.tab').addEvent('click', function(e) {
        e.stop();
        if (this.hasClass('tab_selected')){
            return false;
        }
        this.addClass('tab_selected');
        if (last_tab){
            last_tab.removeClass('tab_selected');
        }
        if (last_menu){
            $(last_menu).style.display='none';
        }
        $(this.title + '_menu').style.display='block';

        last_tab = this;
        last_menu = this.title + '_menu';
    });
    
    $$('a.recent_comments').each(function(element,index) {  
        var content = element.get('title').split('::');  
        element.store('tip:title', content[0]);  
        element.store('tip:text', content[1]);  
    });  

    var tips = new Tips('.recent_comments',{  
        'className': 'recent_comments',  
        'hideDelay': 50,  
        'showDelay': 50
    });
    
    $$('.mibbit').addEvent('click', function(e) {
        pop_up("https://widget.mibbit.com/?server=irc.thisaintnews.com%3A%2B6697&chatOutputShowTimes=true&autoConnect=true"
          +"&channel=%23thisaintnews&settings=8a8a5ac18a22e7eecd04026233c3df93"
          +"&nick=" + mibbit_nick, 720, 400);
        e.stop();
    });

    if ( $defined($('order_by')) ){
        $('order_by').addEvent('change', function(e) {
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
    var conf = "toolbar=no," +
        "location=no," +
        "status=no," +
        "menubar=no," +
        "scrollbars=no," +
        "resizable=yes," +
        "width="+x+"," +
        "height="+y+"," + 
        "top=110," +
        "left=110";
    var mibbit = window.open(url,'mibbit',conf);
}

