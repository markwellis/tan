var xmlhttp;
(function(){
    if ( window.XMLHttpRequest ){
        try{
            xmlhttp = new XMLHttpRequest();
        } catch( e ){
            xmlhttp = false;
        }
    }
})();

function tin_tan( object_id, el ){
    if ( !xmlhttp ){
        return true;
    }

    xmlhttp.onreadystatechange = function(){
        if (
            ( xmlhttp.readyState == 4  )
            && ( xmlhttp.status == 200 )
        ){
            var json = eval( "(" + xmlhttp.responseText + ")" );
            parse_json( json, object_id );
        }
    };
    xmlhttp.open("GET", el.href + "?json=1", true);
    xmlhttp.send();

    return false;
}

function parse_json( json, object_id ){
    if ( json.login === 1 ) {
        return window.location= '/login/';
    }
    var score = document.getElementById( object_id + ':score' );
    var tin = document.getElementById( object_id + ':tin' );
    var tan = document.getElementById( object_id + ':tan' );

    score.innerHTML = json.score;
    tin.innerHTML = "TIN (" + json.plus + ")";
    tan.innerHTML = "TAN (" + json.minus + ")";

    tin.className = "";
    tan.className = "";

    switch( json.created ){
        case "plus":
            tin.className = 'TAN-tintan-selected';
            break;
        case "minus":
            tan.className = 'TAN-tintan-selected';
            break;
    }
}
