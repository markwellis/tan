window.addEvent('domready', function() {
    $$('.TAN-array-more').addEvent('click', function(e) {
        e.stop();
        var number = $$('.TAN-array').length;

        var input_name = $('array-0').get('name');
        var label_name = $$('.TAN-array')[0].getParent().getElement('label').get('text').replace(/ \d+$/, '');

        var label = new Element('li', {
            'html': '<label for="array-' + number + '">' + label_name + ' ' + number + '</label>'
        });

        var input = new Element('li', {
            'html': '<input type="text" name="' + input_name + '" id="array-' + number + '" class="TAN-array" />'
        });
        label.inject(this.getParent(), 'before');
        input.inject(this.getParent(), 'before');
    });
});
