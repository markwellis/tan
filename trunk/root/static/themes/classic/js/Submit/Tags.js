var selected;

var thumbs_timer;
window.addEvent('domready', function() {
	document.id('tags').addEvents({
		keyup: function(e) {
            if ( thumbs_timer ){
                $clear(thumbs_timer);
            }
            thumbs_timer = get_thumbs.delay(500);
            e.stop();
		}
	});
	
	$$('.refresh_thumbs').addEvents({
		click: function(e) {
			get_thumbs();
			e.stop();
		}
	});
});

var current_page;
var thumbs;
var per_page = 100;

function get_thumbs(id){
    var tags = document.id('tags').value;
    if ( id ){
        tags = tags + ' !' + id;
    }

    if ( document.id('tags').value ){
        var req = new Request.JSON({
            "url": "/tagthumbs/",
            "noCache": 1,
            "onRequest": function(){
                document.id('thumb_tags').fade(0);
            },
            "onSuccess": function(json_data){
                thumbs = json_data;

                var start = 0;
                var end = per_page;

                document.id('thumb_tags').set('html', '<label>Picture</label><br /><br />');
                add_thumbs( start, end );
                document.id('thumb_tags').fade(1);
                if (id){
                    select_img(document.id('pic' + (id.replace(/\D+/g, '')) ));
                }
            }
        }).get({
            "random": 20,
            "tags": tags
        });
    }
}

function select_img(img){
	if (selected){
		selected.morph({
			'width': '50px',
			'height' : '50px'
		});
	}
	selected = img;
    img.morph({
    	'width': '100px',
    	'height' : '100px'
    });
    document.id('picture_id').value = parseInt(img.id.substring(3), 10);
}

function add_thumbs(start, end) {
	thumbs.slice(start, end).each(function(thumb) {
        var mod = thumb['object_id'] - (thumb['object_id'] % 1000);
		var img = new Element('img', {
			'src': '/static/cache/thumbs/' + mod + '/' + thumb['object_id'] + '/100',
			'class': 'tag_thumb_img',
			'style': 'margin:5px;',
			'id': 'pic' + thumb['object_id']
		});
		img.addEvent('click',function(e){
			select_img(this);
			e.stop;
		});
		img.inject(document.id('thumb_tags'));
	});

    if ( end < thumbs.length){
        var more = new Element('a', {
            'html': 'more',
            'href': '#',
            'events': {
                'click': function(e){
                    e.stop();
                    this.dispose();
                    add_thumbs(start + per_page, end + per_page);
                }
            }
        });
        more.inject(document.id('thumb_tags'));
    }
};

window.addEvent('domready', function() {
    document.id('submit_form').addEvent( 'submit', function(){
        document.id('picture_id-advice').empty();

        if ( !this.getElements('#picture_id')[0].value.toInt() ){
            var error_element = new Element( 'div', {
                "text": 'Please select an image',
                "class": 'validation-advice'
            } );

            document.id('picture_id-advice').adopt( error_element );

            return false;
        }
    } );
});
