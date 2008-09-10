function ajax_get(file, pos, style){
	var xmlHttp;
	try{
		xmlHttp=new XMLHttpRequest();
	}
	catch (e0)
	{
		try{ 
			xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch (e1){
			try{
				xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch (e2){
				alert("Your browser can't do AJAX!");
				return false;
			}
		}
	}
	xmlHttp.onreadystatechange=function(){
		if(xmlHttp.readyState===4){
			document.getElementById(pos).innerHTML = xmlHttp.responseText;
		}
	};
	xmlHttp.open("GET",file,true);
	xmlHttp.send(null);
}

function updateThumbs(){
    var tags = document.getElementById('tags').value;
    if (!tags){
        tags='%20';
    }
    ajax_get('/tagthumbs/'+tags+'/', 'thumbtags', 0);
}

function changeMenu(type){var linkarray = ['linklink', 'bloglink', 'picturelink'];
    for (i = 0; i<linkarray.length;i++){document.getElementById(linkarray[i]).className = 'nav '+linkarray[i].substr(0,1)+'nav';}
    var menuholder = document.getElementById('menuholder');menuholder.innerHTML = document.getElementById(type + 'menu').innerHTML;
    document.getElementById(type + 'link').className = 'nav mainselected';
}

function selectImage(image){
    var all = document.all ? document.all :
    document.getElementsByTagName('img');

    for (var e = 0; e < all.length; e++){
        if (all[e].id.substring(0,3)==='pic'){
             all[e].style.height ='50px';
             all[e].style.width ='50px';
        }
    }
    document.getElementById(image).style.height='100px';
    document.getElementById(image).style.width='100px';
    document.getElementById('cat').value = parseInt(image.substring(3), 10);
}

function drawTagImages(evt){
    var charCode = evt.which ? evt.which : event.keyCode;
    if (charCode === 32){
        updateThumbs();
    }
}

function checkForm(what){
    if (what === 'link'){
        var regexp = /^(http|https|ftp):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?/i;
        if (document.getElementById('cat').value === ''){
            alert("Please select a picture");
            return false;
        }
        if (regexp.test(document.getElementById('url').value) === false){
            alert("Please enter a valid url, e.g. http://www.google.com");
            return false;
        }

        if (document.getElementById('title').value.length < 5){
            alert("Title must be longer than 5 letters");
            return false;
        }
        if (document.getElementById('description').value.length < 5){
            alert("Description must be longer than 5 letters");
            return false;
        }
        if (document.getElementById('tags').value.length < 3){
            alert("Please enter a few relevant tags");
            return false;
        }
    }

    if (what === 'picture'){
        if (document.getElementById('pic').value === ''){
            alert("Please select an image to upload");
            return false;
        }
        if (document.getElementById('pictitle').value.length < 5){
            alert("Title must be longer than 5 letters");
            return false;
        }
        if (document.getElementById('pictags').value.length < 3){
            alert("Please enter a few relevant tags");
            return false;
        }
    }

    if (what === 'blog'){
        if (document.getElementById('cat').value === ''){
            alert("Please select a picture");
            return false;
        }
        if (document.getElementById('blogtitle').value.length < 5){
            alert("Title must be longer than 5 letters");
            return false;
        }
        if (document.getElementById('blogdescription').value.length < 5){
            alert("Description must be longer than 5 letters");
            return false;
        }
        if (FCKeditorAPI.GetInstance('blogmain').GetHTML().length < 26){
            alert("The blog must be atleast 20 letters");
            return false;
        }
        if (document.getElementById('tags').value.length < 3){
            alert("Please enter a few relevant tags");
            return false;
        }
    }
    return true;
}


function scaleItem(item0, x){
    var item = document.getElementById(item0);
    var height = parseInt(item.style.height, 10) || parseInt(item.height, 10);
    var diffX = height - x;
    var y = x + 20;
    if (diffX < 0) {
        item.style.maxWidth=y + 'px';
        item.style.height=x + 'px';
    } else {
        item.style.maxWidth=y  + 'px';
        item.style.height=x + 'px';
    }
}

function popupBox(id){
    imgdiv = document.getElementById('thumb'+id);
    popup = document.getElementById('popup'+id);
    if (imgdiv.className !== 'Imgnormal Imgover'){
        imgdiv.className='Imgnormal Imgover';
        popup.style.display = 'block';
    }
}

function unpopup(id){
    imgdiv = document.getElementById('thumb'+id);
    popup = document.getElementById('popup'+id);
    if (imgdiv.className !== 'Imgnormal'){
        imgdiv.className='Imgnormal';
        popup.style.display = 'none';
    }
}

function addPlus(id, type, plus){
    var ts = new Date().getTime();
    ajax_get('/doplus/'+type+'/'+id+'/'+ts, plus, 0);
}

function addMinus(id, type, minus){
    var ts = new Date().getTime();
    ajax_get('/dominus/'+type+'/'+id+'/'+ts, minus, 0);
}

function taddMinus(id, type, minus){
    var ts = new Date().getTime();
    ajax_get('/tdominus/picture/'+id+'/'+ts, minus, 0);
}

function taddPlus(id, type, minus){
    var ts = new Date().getTime();
    ajax_get('/tdoplus/picture/'+id+'/'+ts, minus, 0);
}
