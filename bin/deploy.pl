use strict;
use warnings;
use 5.010;

use FindBin qw/$Bin/;
use Config::ZOMG;
use Getopt::Long;
use Scalar::Util qw/looks_like_number/;
use Pod::Usage;
use List::Util qw/first/;
use Term::ANSIColor;
use Carp qw/croak/;

die "please run from the project root dir\n" if ( !-e 'Makefile.PL' );

my @args;
GetOptions (
    'force' => \my $force,
    'debug' => \my $debug,
    '<>'    => sub { push @args, shift },
) || pod2usage(-verbose => 2);

if ( ! scalar @args ) {
    say "no args\n";
    pod2usage(-verbose => 2);
}
my ( $action, $profile, $extra ) = @args;

my $config = Config::ZOMG->new(name => 'deploy', path => "$Bin/..")->load || die "couldn't load config\n";
my $c_profile;

if ( $action eq 'make' ) {
    #make doesn't need $profile

    make();
}
else {
    my @profiles = keys( %{ $config->{profiles} } );
    if ( !$profile ) {
        die "profile not specified options are '" . join( "' or '", @profiles ) . "'\n";
    }
    elsif ( !grep { $profile eq $_ } @profiles ) {
        die "'$profile' is invalid, valid options are '" . join( "' or '", @profiles ) . "'\n";
    }
    $c_profile = $config->{profiles}->{ $profile };

    if ( $action eq 'copy' ) {
        copy();
    }
    elsif ( $action eq 'install' ) {
        install();
    }
    elsif ( $action eq 'deploy' ) {
        deploy();
    }
    elsif ( $action eq 'start' ) {
        start();
    }
    elsif ( $action eq 'stop' ) {
        stop();
    }
    elsif ( $action eq 'restart' ) {
        restart();
    }
    elsif ( $action eq 'rollback' ) {
        rollback();
    }
    else {
        say "invalid action '$action'\n";
        pod2usage(-verbose => 2);
    }
}

sub make {
    my $to_null = "> /dev/null" unless $debug;
    my $stderr_to_stdout = "2>&1" unless $debug;
    if ( !$force ) {
        my $error = "unclean git dir, try running 'git status' and maybe 'git ls-files --other --exclude-standard --directory', or rerun with the --force option\n";

        `git diff --exit-code`;
        die $error if $? >> 8;

        `git diff --cached --exit-code`;
        die $error if $? >> 8;

        die $error if `git ls-files --other --exclude-standard --directory`;
    }

    my $commands = <<END;
rm $config->{app}.tar.gz $to_null $stderr_to_stdout
make distclean $to_null $stderr_to_stdout
rm MANIFEST $to_null $stderr_to_stdout
echo y | perl Makefile.PL $to_null
make manifest $to_null $stderr_to_stdout
make dist DISTVNAME=$config->{app} $to_null #TODO tag this with username
END
    system( $commands );

    die "error making dist\n" if !-e "$config->{app}.tar.gz";
}

sub copy {
    #copy new dist file to servers
    die "no dist to copy\n" if !-e "$config->{app}.tar.gz";

    info( undef, "copying $config->{app}.tar.gz" );
    foreach my $server ( @{$c_profile->{servers}} ) {
        `rsync --chmod=u+rw,g+rw,o+r $config->{app}.tar.gz $server:$c_profile->{release_dir}`;
        `ssh $server chown :$c_profile->{group} $c_profile->{release_dir}/$config->{app}.tar.gz`;

        my $exit_code = $? >> 8;
        die "failed, code $exit_code" if $exit_code;
        info( "$server", "complete" );
    }
}

sub install {
    my $release_name = time;
    my $release_dir = $c_profile->{release_dir};
    my $share_dir = $c_profile->{share_dir};

    my $git_remote = $config->{git_remote} || "origin";

    my $quiet = "-q" unless $debug;
    info( undef, "tagging release $release_name" );
    `git tag release/$profile/$release_name; git push $quiet $git_remote release/$profile/$release_name`;

    my $create_symlink_commands = '';
    foreach my $source ( keys %{ $config->{symlinks} } ) {
        my $destination = $config->{symlinks}->{$source};
        $create_symlink_commands .= "ln -s $share_dir/$source $release_dir/$release_name/$destination\n";
    }

    foreach my $server ( @{$c_profile->{servers}} ) {
        my $install_commands = <<END;
[ -e $release_dir/$config->{app}.tar.gz ] || { echo "run copy first"; exit 254; }
mkdir $release_dir/$release_name
tar --strip 1 -xzf $release_dir/$config->{app}.tar.gz -C $release_dir/$release_name

#create symlinks
$create_symlink_commands
END

            if ( !first { $_ eq $server } @{$c_profile->{no_carton_install}} ) {
                #install the app!
                $install_commands .= "cd $release_dir/$release_name; carton install\n";
            }

            $install_commands .= <<"END";
#create current symlink
rm $release_dir/current
ln -s $release_dir/$release_name $release_dir/current

#delete old releases
perl -MFile::Path\\ 'remove_tree' -E 'chdir "$release_dir"; \@f = <*>; \@d = sort grep { -d \$_ && ! -l \$_ } \@f; delete \@d[-$config->{keep_releases}..-1]; remove_tree "$release_dir/\$_" for \@d';

END

        _execute_remote_commands( 
            commands => $install_commands,
            servers  => $server,
            info     => "installing $release_name"
        );
    }
    `make distclean > /dev/null 2>&1`
}

sub start {
    foreach my $server ( keys %{$c_profile->{services}} ) {
        my $services = $c_profile->{services}->{$server};

        foreach ( @{$services} ) {
            _execute_remote_commands(
                commands => "systemctl start $_",
                root     => 1,
                servers  => $server,
                info     => "starting $_"
            );
        }
    }
}

sub stop {
    foreach my $server ( keys %{$c_profile->{services}} ) {
        my $services = $c_profile->{services}->{$server};

        foreach ( @{$services} ) {
            _execute_remote_commands(
                commands => "systemctl stop $_",
                root     => 1,
                servers  => $server,
                info     => "stopping $_"
            );
        }
    }
}

sub restart {
    foreach my $server ( keys %{$c_profile->{services}} ) {
        my $services = $c_profile->{services}->{$server};

        foreach ( @{$services} ) {
            my $commands = "systemctl stop $_;systemctl start $_;\n";

            if ( my $status_url = $c_profile->{status_url}->{$server} ) {
                $commands .= << "END";
COUNT=1
while [ 1 ]; do
    STATUS=\$(curl --connect-timeout 3 -m 3 -s -o /dev/null -w "%{http_code}" "${status_url}")
    if ! grep -q 200 <<< \$STATUS; then
        ((COUNT++))
        if [ \$COUNT -gt 20 ]; then
            echo -e "\\e[31mserver failed to start, exiting\\e[0m"
            exit 33
        fi
        echo -e "waiting..."
        sleep 3
    else
       echo -e "..server started"
       break
    fi
done
END
            }
            _execute_remote_commands(
                commands => $commands,
                root     => 1,
                servers  => $server,
                info     => "restarting $_"
            )
        }
    }
}

sub rollback {
    my $release_dir = $c_profile->{release_dir};
    my $rollback = 2;

    if ( $extra && looks_like_number( $extra ) ) {
        if ( $extra > $config->{keep_releases} ) {
            die "can't rollback more than $config->{keep_releases} releases\n";
        }
        $rollback = $extra;
    }
    info( undef, "rolling back $rollback releases" );

    my $commands = <<END;
perl -E 'chdir "$release_dir"; \@f = <*>; \@d = sort grep { -d \$_ && ! -l \$_ } \@f; die "not enough releases to rollback $rollback\\n" if !\$d[-$rollback]; unlink "$release_dir/current"; symlink("$release_dir/\$d[-$rollback]", "$release_dir/current")';
END
    _execute_remote_commands(
        commands => $commands,
        info     => "rolling back"
    );

    restart();
}

sub deploy {
    make();
    copy();
    install();
    restart();
}

sub _execute_remote_commands {
    my %args = @_;

    my $commands = $args{commands} // croak "no command";
    my $root = $args{root};
    my $servers = $args{servers};
    my $info = $args{info};

    if ( defined $servers && !ref $servers ) {
        $servers = [$servers];
    }
    $servers //= $c_profile->{servers};

    my $user = '';
    if ( !$root ) {
        $user = "-u $c_profile->{user}";
    }

    foreach my $server ( @{$servers} ) {
        open( my $f, "|-", "ssh $server 'sudo $user -s'") || die "can't exec ssh";
        my $perlbrewrc = "~$c_profile->{user}/perl5/perlbrew/etc/bashrc";
        print $f "[ -e $perlbrewrc ] && source $perlbrewrc\n";
        info( $server, $info );

        my $command_to_run = '';
        foreach my $command ( split /\n/, $commands ) {
            if ( $command ) {
                $command_to_run .= "$command\n";
                say $command if $debug;
            }
        }
        if ( $command_to_run ) {
            print $f "echo -ne \\\e[32m\n";
            print $f "$command_to_run\n";
            print $f "echo -ne \\\e[0m\n";
        }
        close $f;

        my $exit_code = $? >> 8;
        die "remote execution failed, exit code $exit_code" if $exit_code;
    }
}

sub info {
    my ( $host, $info ) = @_;

    if ( $host ) {
        print color('white') . "[$host]" . color('reset') . " ";
    }
    if ( $info ) {
        say color('blue') . "$info" . color('reset');
    }
    else {
        print "\n";
    }
}
=head1 NAME

deploy.pl - deploy an app to a server

=head1 OPTIONS

=over

=item make [--force] - makes dist

makes the dist locally. will refuse to make if the project is git unclean
(extra files, uncommitted changes etc), but you can "make --force" if you B<really>
want to build anyway

=item copy $profile - copies dist to servers

copies dist to $config->{profiles}->{$profile}->{release_dir} on all servers

=item install $profile - installs dist on servers

installs the dist from the release dir into a new dir (timestamped) in the
releases dir as defined in the $config on all servers

=item start $profile - starts app service

runs service start $config->{profiles}->{$profile}->{service} on profile servers

=item stop $profile - stops app service

runs service stop $config->{profiles}->{$profile}->{service} on profile servers

=item restart $profile - restarts app service

runs service restart $config->{profiles}->{$profile}->{service} on profile servers

=item rollback $profile [$releases] - rolls back the release

if releases is provided, rollback this many, else roll back to the previous (you can rollback to the latest with 1)

rollback works by changing the "current" symlink

=item deploy $profile - a shortcut for make, copy, install, restart

same as running these separately

    make
    copy $profile
    install $profile
    restart $profile

=back

=head1 EXAMPLES

    perl deploy.pl make
    perl deploy.pl copy live
    perl deploy.pl install live
    perl deploy.pl restart live

is the same as

    perl deploy.pl deploy live

=head1 CAVEATS

when make is run, it will use your B<CURRENT> checkout, B<AS IS>. stash things
you don't want to be deployed.

=head1 CONFIG

looks for a config one dir up called deploy.json

=head2 example

    {
        "app"           : "CatalystCS",
        "keep_releases" : 5,
        "profiles"      : {
            "live"          : {
                "service"       : "cs-live",
                "servers"       : ["cs-dev"],
                "release_dir"   : "/var/www/cs/live/releases",
                "symlinks"      : {
                    "/var/www/cs/live/share/images"    : "root/images"
                },
                "user"          : "csave"
            },
            "beta"          : {
                "service"       : "cs-beta",
                "servers"       : ["cs-dev"],
                "release_dir"   : "/var/www/cs/beta/releases",
                "symlinks"      : {
                    "/var/www/cs/beta/share/images"    : "root/images"
                },
                "user"          : "csave"
            }
        }
    }

=cut
