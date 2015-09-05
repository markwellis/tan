use 5.14.0;

use Cwd 'abs_path';
use File::Basename;
use JSON;
use Tie::Hash::Sorted;

my $dir = dirname( abs_path( __FILE__ ) ) . "/../../root/static/smilies";

my $icons = {};
opendir( my $dh, "$dir" ) || die "failed to opendir $dir: $!";
while ( my $smilie = readdir( $dh ) ){
    #load each image and strip .png add prefix off : and register
    if ( $smilie =~ m/^\./ ){
        next;
    }

    my $alias = ':' . fileparse( $smilie, ".png", ".gif" );
    $icons->{ $alias } = $smilie;

}
closedir( $dh );

my $sort_icons = sub {
    my $hash = shift;

    [ sort {$hash->{$a} cmp $hash->{$b}} keys %$hash ];
};

tie my %sorted, 'Tie::Hash::Sorted',
    'Hash'         => $icons,
    'Sort_Routine' => $sort_icons;

say to_json( \%sorted );
