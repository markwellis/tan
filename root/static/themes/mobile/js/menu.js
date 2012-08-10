function change_menu( new_tab ){
    if ( new_tab === selected_tab ){
        return false;
    }

    document.getElementById("TAN-menu-" + selected_tab ).className = "none";
    document.getElementById("TAN-menu-" + new_tab ).className = "TAN-menu-" + new_tab;
    
    document.getElementById("TAN-menu-tab-" + selected_tab).className = "TAN-menu-tab TAN-type-" + selected_tab;
    document.getElementById("TAN-menu-tab-" + new_tab).className += " TAN-menu-tab-" + new_tab + "-selected";

    selected_tab = new_tab;
    return false;
}
