window.addEvent('domready', function() {
	$('submit_form').addEvents({
		submit: function(e) {
			$('submit_form').getElements('input, textarea').each(
				function (el){
					switch (el.id){
						case 'title':
							if (el.value.length < 3){
	            				TAN.alert("Title must be longer than 3 letters");
	            				e.stop();
							}
							break;
						case 'cat':
							if (el.value === ''){
								TAN.alert("Please select a picture");
								e.stop();
							}
							break;
						case 'description':
					        if (el.value.length < 5){
					            TAN.alert("Description must be longer than 5 letters");
					            e.stop();
					        }
					        break;
						case 'blogmain':
					        if (tinyMCE.get('blogmain').getContent().length < 26){
					            TAN.alert("The blog must be atleast 20 letters");
					            e.stop();
					        }
					        break;
						case 'url':
							var regexp = /^(http|https|ftp):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?/i;
							if (regexp.test(el.value) === false){
					            TAN.alert("Please enter a valid url, e.g. http://thisaintnews.com");
					            e.stop();
					        }
							break;
						case 'tags':
					        if (el.value.length < 1){
					            TAN.alert("Please enter a few relevant tags");
					            e.stop();
					        }
					        break;
						case 'pic':
					        if (el.value === '' && $('pic_url').value === ''){
					            TAN.alert("Please select an image to upload");
					            e.stop();
					        }
					        break;
					};
				}
			);
			
		}
	});
});
