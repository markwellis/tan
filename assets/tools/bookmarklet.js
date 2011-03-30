(function(){
    var url = window.location.href.toString();
    var title = document.title;
    var metas = document.getElementsByTagName("meta");
    var description = "";

    for ( var x = 0; metas.length; ++x ){
        if ( metas[x] == undefined ){
            break; 
        }
        if ( metas[x].name.toLowerCase() == "description" ){
            description = metas[x].content;
            break;
        }
    }

    var tan_url = "http://thisaintnews.com/submit/link/post/"
        + "?type=link"
        + "&title=" + encodeURI(title)
        + "&url=" + encodeURI(url)
        + "&description=" + encodeURI(description)
        + "&no_error=1";

    window.open( tan_url );
})();

/*

(function(){var url=window.location.href.toString();var title=document.title;var metas=document.getElementsByTagName("meta");var description="";for(var x=0;metas.length;++x){if(metas[x]==undefined){break;}if(metas[x].name.toLowerCase()=="description"){description=metas[x].content;break;}}var tan_url="http://thisaintnews.com/submit/link/post/"+"?type=link"+"&title="+encodeURI(title)+"&url="+encodeURI(url)+"&description="+encodeURI(description)+"&no_error=1";window.open(tan_url);})();

*/
