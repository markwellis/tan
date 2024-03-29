(function(){
    var image_content_types = {
        "image/gif": 1,
        "image/jpeg": 1,
        "image/pjpeg": 1,
        "image/png": 1,
    };

    var type = ( image_content_types[document.contentType] ) ? "picture" : "link";
    var tan_url = ["http://thisaintnews.com/submit/" + type + "/post/?type=" + type];

    var url = window.location.href.toString();

    if ( type === "picture" ){
        tan_url.push( "remote=" + encodeURI( url ) );
        tan_url.push( "no_error=1" );
    } else if ( type === "link" ){
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

        tan_url.push( "title=" + encodeURI( title ) );
        tan_url.push( "url=" + encodeURI( url ) );
        tan_url.push( "description=" + encodeURI( description ) );
        tan_url.push( "no_error=1" );
    }

    window.open( tan_url.join("&") );
})();

/*

(function(){var image_content_types={"image/gif":1,"image/jpeg":1,"image/pjpeg":1,"image/png":1,};var type=(image_content_types[document.contentType])?"picture":"link";var tan_url=["http://thisaintnews.com/submit/"+type+"/post/?type="+type];var url=window.location.href.toString();if(type==="picture"){tan_url.push("remote="+encodeURI(url));tan_url.push("no_error=1");}else if(type==="link"){var title=document.title;var metas=document.getElementsByTagName("meta");var description="";for(var x=0;metas.length;++x){if(metas[x]==undefined){break;}if(metas[x].name.toLowerCase()=="description"){description=metas[x].content;break;}}tan_url.push("title="+encodeURI(title));tan_url.push("url="+encodeURI(url));tan_url.push("description="+encodeURI(description));tan_url.push("no_error=1");}window.open(tan_url.join("&"));})();

*/
