use 5.014;
use TAN::BBcode::Converter;
use TAN::Model::MySQL;
use Term::ProgressBar;
use Try::Tiny;
use utf8;

my $converter = TAN::BBcode::Converter->new;
my $db = TAN::Model::MySQL->new;

my $comments = $db->resultset('Comments')->search({});
my $blogs = $db->resultset('Blog')->search({});
my $forums = $db->resultset('Forum')->search({});
my $profiles = $db->resultset('Profile')->search({});

my $count = $comments->count + $blogs->count + $forums->count + $profiles->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Updating',
    'count' => $count,
});
$progress->minor(0);

open( my $fh, '>', 'log' );
while ( my $comment = $comments->next ){
    $progress->update( ++$loop );
    
    my $c = $comment->_comment;
    utf8::encode($c);
    say $fh "\n***\n" . $c;

    $c = try{
        $converter->parse( $comment->_comment );
    } catch {
        return undef;
    };

    next if !$c;
    next if $c eq $comment->_comment;

    $comment->update( {
        'comment' => $converter->parse( $c ),
    } );
}

while (my $blog = $blogs->next){
    $progress->update( ++$loop );
    
    my $c = $blog->_details;
    utf8::encode($c);
    say $fh "\n***\n" . $c;

    $c = try{
        $converter->parse( $blog->_details );
    } catch {
        return undef;
    };

    next if !$c;
    next if $c eq $blog->_details;

    $blog->update( {
        'details' => $converter->parse( $c ),
    } );
}

while (my $forum = $forums->next){
    $progress->update( ++$loop );
    
    my $c = $forum->_details;
    utf8::encode($c);
    say $fh "\n***\n" . $c;

    $c = try{
        $converter->parse( $forum->_details );
    } catch {
        return undef;
    };

    next if !$c;
    next if $c eq $forum->_details;

    $forum->update( {
        'details' => $converter->parse( $c ),
    } );
}

while (my $profile = $profiles->next){
    $progress->update( ++$loop );
    
    my $c = $profile->_details;
    utf8::encode($c);
    say $fh "\n***\n" . $c;

    $c = try{
        $converter->parse( $profile->_details );
    } catch {
        return undef;
    };

    next if !$c;
    next if $c eq $profile->_details;

    $profile->update( {
        'details' => $converter->parse( $c ),
    } );
}
