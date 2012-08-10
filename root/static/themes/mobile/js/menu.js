/*
    check .TAN-type-{$name}
    add class .none to .TAN-menu-{$selected_menu_type}
    set $selected_menu_type = $name
    remove class .none from .TAN-menu-{$selected_menu_type}
*/

function change_menu( tab ){
    if ( tab === selected_menu_type ){
        return false;
    }

    var selected_menu = getElementByClass("TAN-menu-" + selected_menu_type );
    var new_menu = getElementByClass("TAN-menu-" + tab );
    selected_menu.className += ' none';
    new_menu.className = "TAN-menu-" + tab;
    
    var new_tab = getElementByClass("TAN-type-" + tab);
    var selected_tab = getElementByClass("TAN-type-" + selected_menu_type);
    new_tab.className += " TAN-menu-tab-" + tab + "-selected";
    selected_tab.className = "TAN-menu-tab TAN-type-" + selected_menu_type;

    selected_menu_type = tab;
    return false;
}

function getElementByClass( className ){
    var elems = document.getElementsByTagName('*'), i;
    for (i in elems){
        if((" " + elems[i].className + " ").indexOf(" " + className + " ") > -1){
            return elems[i];
        }
    }   
}
