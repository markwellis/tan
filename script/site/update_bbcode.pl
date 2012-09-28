use 5.014;
use TAN::BBcode::Converter;
use TAN::Model::MySQL;
use Term::ProgressBar;
use Try::Tiny;
use utf8;

my $converter = TAN::BBcode::Converter->new;
my $db = new TAN::Model::MySQL;

my $comments = $db->resultset('Comments')->search({});

my $count = $comments->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Updating',
    'count' => $count,
});
$progress->minor(0);

open( my $fh, '>', 'log' );
while (my $comment = $comments->next){
    my $c = $comment->_comment;
    utf8::encode($c);
    say $fh "\n***\n" . $c;

    my $c = try{
        $converter->parse( $comment->_comment );
    } catch {
        return undef;
    };

    next if !$c;

    $comment->update( {
        'comment' => $converter->parse( $c ),
    } );
    $progress->update( ++$loop );
}
