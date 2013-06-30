use 5.018;
use warnings;

use Term::ProgressBar;
use Crypt::PBKDF2;

use TAN::Salt;
use TAN::Model::MySQL;

my $db = TAN::Model::MySQL->new;
my $users = $db->resultset('User')->search;

my $count = $users->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Salting',
    'count' => $count,
});
$progress->minor(0);

my $salt_dir = '/mnt/stuff/TAN/salt';

foreach my $user ( $users->all ){
    my $salt = TAN::Salt::salt;
    
#    open my $fh, '>', "${salt_dir}/" . $user->id || die "$!";
#    print $fh $salt;  
#    close $fh;
### use user->_set_salt;
#now update db to use $salt;
    my $crypt = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 10_000,
    );

    $user->update( {
        'password' => $crypt->PBKDF2_base64( $salt, $user->password ),
    } );

    $progress->update( ++$loop );
}
