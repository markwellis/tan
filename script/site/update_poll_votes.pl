use 5.014;

use Term::ProgressBar;
use TAN::Model::MySQL;

my $db = TAN::Model::MySQL->new;

my $polls = $db->resultset('Poll')->search({});

my $count = $polls->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Updating',
    'count' => $count,
});
$progress->minor(0);

#update poll.votes
# poll_answer.votes

while ( my $poll = $polls->next ){
    $progress->update( ++$loop );

    $poll->update( {
        'votes' => $poll->votes->count,
    } );
    foreach my $answer ( $poll->answers ){
        $answer->update( {
            'votes' => $answer->votes->count,
        } );
    }
}
