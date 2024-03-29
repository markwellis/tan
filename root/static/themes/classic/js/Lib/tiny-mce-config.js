tinymce.PluginManager.load('smilies', '/static/tiny_mce_plugins/smilies/smilies.js?r=1');

var tiny_mce_config = {
    theme: "advanced",

    plugins: "-smilies,fullscreen,inlinepopups",

    theme_advanced_buttons1: "code,|,undo,redo,|,fontsizeselect,|,"
        + "bold,italic,underline,strikethrough,|,"
        + "justifyleft,justifycenter,justifyright,"
        + "justifyfull|,sub,sup,|,forecolor,backcolor,|,"
        + "hr,bullist,numlist,|,"
        + "link,unlink,image,smilies,|,fullscreen",
    theme_advanced_buttons2: "",
    theme_advanced_buttons3: "",
    theme_advanced_buttons4: "",
    theme_advanced_toolbar_location: "top",
    theme_advanced_toolbar_align: "left",
    theme_advanced_statusbar_location: "bottom",
    theme_advanced_resizing: true,

    forced_root_block : false,
    force_br_newlines : true,
    force_p_newlines : false,

    mode: "specific_textareas",
    gecko_spellcheck: "1",
    valid_elements: "*[*]",
    relative_urls : false,
    convert_urls : false,
    entity_encoding: "numeric"
};
