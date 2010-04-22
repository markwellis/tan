window.addEvent('domready', function() {
	$('submit_form').addEvents({
		submit: function(e) {
			$('submit_form').getElements('input, textarea').each(
				function (el){
					switch (el.id){
						case 'title':
							if (el.value.length < 5){
	            				alert("Title must be longer than 5 letters");
	            				e.stop();
							}
							break;
						case 'cat':
							if (el.value === ''){
								alert("Please select a picture");
								e.stop();
							}
							break;
						case 'description':
					        if (el.value.length < 5){
					            alert("Description must be longer than 5 letters");
					            e.stop();
					        }
					        break;
						case 'blogmain':
					        if (tinyMCE.get('blogmain').getContent().length < 26){
					            alert("The blog must be atleast 20 letters");
					            e.stop();
					        }
					        break;
						case 'url':
							var regexp = /^(http|https|ftp):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?/i;
							if (regexp.test(el.value) === false){
					            alert("Please enter a valid url, e.g. http://thisaintnews.com");
					            e.stop();
					        }
							break;
						case 'tags':
					        if (el.value.length < 1){
					            alert("Please enter a few relevant tags");
					            e.stop();
					        }
					        break;
						case 'pic':
					        if (el.value === '' && $('pic_url').value === ''){
					            alert("Please select an image to upload");
					            e.stop();
					        }
					        break;
					};
				}
			);
			
		}
	});
});
