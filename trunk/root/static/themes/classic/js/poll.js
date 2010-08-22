window.addEvent('domready', function() {
	$('poll_vote_form').addEvents({
		submit: function(e) {
            e.stop();

            var selected, answer_id;
            this.getElements('input[type="radio"]:checked').each(function(item, index){
                selected = true;
                answer_id = item.value;
            });
            if ( !selected ){
                TAN.alert("You can't vote for nothing");
                return;
            }
            
            var submit_button = this.getElement('input[type="submit"]');
            submit_button.disabled = 1;
            var vote_jsonreq = new Request.JSON({
                'url': this.action,
                'noCache': true,
                'onSuccess': function(results){
                    if ( !$defined(results.login) ){
                        results.each(function(item, index){
                            var ul = new Element('ul', {
                                'class': 'TAN-poll'
                            });

                            var li = new Element('li', {
                                'html': item.name
                            });

                            var percent_holder = new Element('span', {
                                'class': "TAN-poll-percent-holder"
                            });

                            var percent = new Element('span', {
                                'class': "TAN-poll-percent",
                                'styles': {
                                    'width': item.percent.toString() + '%'
                                }
                            });

                            var percent_voted = new Element('span', {
                                'class': "TAN-poll-percent-voted",
                                'html': item.percent + '%'
                            });
                            percent_holder.inject(li);
                            percent.inject(percent_holder);
                            percent_voted.inject(li);
                            li.inject(ul);
                            ul.inject($('poll_vote_form').getParent());
                        });
                        $('poll_vote_form').dispose();
                    } else {
                        submit_button.disabled = 0;
                        TAN.login();
                    }
                },
                'onFailure': function(value){
                    submit_button.disabled = 0;
                    TAN.alert('vote failed :(');
                }
            }).get({
                'answer_id': answer_id,
                'json': 1
            });
		}
	});
});
