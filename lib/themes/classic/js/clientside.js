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
    
    $$('.mibbit').addEvent('click', function(e) {
        $$('.mibbit').addEvent('click', function(e) {
            popUpWindow(this.href, 720, 400);
            e.stop();
        });
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

function popUpWindow(URLStr,width,height) {
	winName = "mibbitPopUp"
	winSetup = "toolbar=no," +
	"location=no," +
	"status=no," +
	"menubar=no," +
	"scrollbars=no," +
	"resizable=yes," +
	"width="+width+"," +
	"height="+height+"," + 
	"top=110," +
	"left=110"
	sgWindow = window.open(URLStr,winName,winSetup) ;
}