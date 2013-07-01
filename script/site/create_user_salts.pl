use 5.018;
use warnings;

use Term::ProgressBar;
use Crypt::PBKDF2;

use TAN::Model::MySQL;

say "Do not run this script if the user passwords are already salted!";
say "type YES to continue";

chomp( my $continue = <> );

if ( $continue ne 'YES' ){
    exit;
}

my $db = TAN::Model::MySQL->new;
my $users = $db->resultset('User')->search;

my $count = $users->count;
my $loop = 0;
my $progress = Term::ProgressBar->new({
    'name' => 'Salting',
    'count' => $count,
});
$progress->minor(0);

my $crypt = Crypt::PBKDF2->new(
    hash_class => 'HMACSHA2',
    hash_args => {
        sha_size => 512,
    },
    iterations => 10_000,
);

foreach my $user ( $users->all ){
    $user->update( {
        'password' => $crypt->PBKDF2_base64( $user->_set_salt, $user->password )
    } );

    $progress->update( ++$loop );
}
