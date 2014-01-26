(function(tinymce) {
    var plugin_version = 0.001;

	tinymce.create('tinymce.plugins.SmiliesPlugin', {
		init : function(ed, url) {
			// Register commands
			ed.addCommand('mceSmiley', function() {
				ed.windowManager.open({
					file : url + '/smilies.html?r=1',
					width : 590,
					height : 270,
					inline : 1
				}, {
					plugin_url : url
				});
			});

            // Register buttons
			ed.addButton('smilies', {
                title : 'Smilies',
                cmd : 'mceSmiley',
                image: url + '/smilies.png'
            });
		},
	});

	// Register plugin
	tinymce.PluginManager.add('smilies', tinymce.plugins.SmiliesPlugin);
})(tinymce);
