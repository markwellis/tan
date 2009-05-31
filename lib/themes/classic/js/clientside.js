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
        className: 'recent_comments',  
        hideDelay: 50,  
        showDelay: 50
    });

});