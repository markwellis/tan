use utf8;
use Encode;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";
binmode STDIN,  ":utf8";

use strict;
use warnings;
use 5.020;

use FindBin qw/$Bin/;
use DBI;
use Path::Tiny;
use Getopt::Long;
use Config::ZOMG;
use List::Util qw/first/;

my $migration_dir = path( "$Bin/../migrations" );
my $plan = $migration_dir->child('plan');
my $config = Config::ZOMG->new(name => 'config', path => $migration_dir)->load || die "couldn't load config\n";

my $target = 'default';
my @args;
GetOptions (
    'target|t=s'    => \$target,
    '<>'            => sub { push @args, decode_utf8( shift ) },
) || die "need options";

say "using profile '$target'";

if ( exists $config->{$target}->{tunnel} ) {
    my $pid = fork;
    if ( !$pid ) {
        #child
        my $host = $config->{$target}->{tunnel}->{host};
        my $local_port = $config->{$target}->{tunnel}->{port}->{local};
        my $remote_port = $config->{$target}->{tunnel}->{port}->{remote};
        say "opening ssh tunnel to $host:$remote_port => 127.0.0.1:$local_port";
        exec "ssh -N ${host} -L ${local_port}:127.0.0.1:${remote_port}";
    }
    else {
        sleep 2;
        END {
            if ( $pid ) {
                say "closing ssh tunnel";
                kill 'TERM', $pid;
            }
        }
    }
}

my $dsn = $config->{$target}->{dsn};
my $user = $config->{$target}->{user};
my $password = $config->{$target}->{password};

my $per_db_settings = {
    mysql   => {
        connect_options => {
            mysql_multi_statements => 1,
            mysql_enable_utf8 => 1,
        },
        post_connect => sub {
            my $dbh = shift;
            $dbh->do( 'SET NAMES utf8mb4' );
        },
        create_table => q/CREATE TABLE IF NOT EXISTS _db_manager (
                `id`            INTEGER PRIMARY KEY AUTO_INCREMENT,
                `filename`      VARCHAR(128) NOT NULL,
                `timestamp`     INTEGER NOT NULL,
                `created_at`    TIMESTAMP NOT NULL DEFAULT NOW(),
                UNIQUE INDEX    _db_manager_filename (filename)
            ) CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ENGINE=innodb;/,
    },
    Pg      => {
        connect_options => {
            pg_enable_utf8  => 1,
        },
        create_table => q/CREATE TABLE IF NOT EXISTS "_db_manager" (
              "id" serial NOT NULL,
              "filename" character varying(128) NOT NULL,
              "timestamp" bigint NOT NULL,
              "created_at" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
              PRIMARY KEY ("id"),
              CONSTRAINT "_db_manager-filename:unique" UNIQUE ("filename")
            );/,
    }
};

my $dbtype = first { $dsn =~ m/dbi:$_:/ } keys %$per_db_settings;
my $dbsettings = $per_db_settings->{ $dbtype };

my $dbh = DBI->connect( $dsn, $user, $password, {
    RaiseError => 1,
    PrintError => 0,
    AutoCommit => 1,
    %{ $dbsettings->{connect_options} },
} );
if ( $dbsettings->{post_connect} ) {
    $dbsettings->{post_connect}->( $dbh );
}

sub quote ( $;@ ) {
    $dbh->quote_identifier( @_ );
}

create_manager_table( $dbh );

die "command" if !$args[0];
my $command = shift @args;
if ( $command eq 'deploy' ) {
    say "deploying";
    if ( scalar @args == 0 ) {
        deploy_all( $dbh );
    }
    else {
        deploy_one( $dbh, $_ ) for @args;
    }
}
elsif ( $command eq 'revert' ) {
    say "reverting";
    revert_one( $dbh, $_ ) for @args;
}
elsif ( $command eq 'verify' ) {
    say "verifying";
    if ( scalar @args == 0 ) {
        verify_all( $dbh );
    }
    else {
        verify_one( $dbh, $_ ) for @args;
    }
}
elsif ( $command eq 'list' ) {
    my $sub_command = shift @args;
    if ( !defined $sub_command ) {
        say "subcommand required";
        exit 1;
    }
    if ( $sub_command eq 'deployed' ) {
        list_deployed( $dbh );
    }
    elsif ( $sub_command eq 'available' ) {
        list_available( $dbh );
    }
    else {
        say "$command $sub_command is not a command";
    }
}
elsif ( $command eq 'add' ) {
    my $name = shift @args;
    if ( !defined $name ) {
        say "name required";
        exit 1;
    }
    add_migration( $name );
}
else {
    say "$command is not a command";
}

sub create_manager_table {
    my $dbh = shift;

    my $create_table = $dbsettings->{create_table};

    my $old_client_min_messages = $dbh->selectrow_arrayref( "SHOW client_min_messages" );
    $dbh->do( "SET client_min_messages TO warning" );
    #turn off the stupid "NOTICE:  relation "_db_manager" already exists, skipping" warning
    $dbh->do( $create_table ) or die $dbh->errstr;
    $dbh->do( "SET client_min_messages TO $old_client_min_messages->[0]" );
}

sub deploy_all {
    my $dbh = shift;

    my $sth = $dbh->prepare( "SELECT @{[ quote 'filename' ]} FROM @{[ quote '_db_manager' ]}" );
    my @deployed = @{ $dbh->selectcol_arrayref( $sth ) };

    my @migrations = _migrations();
    foreach my $migration ( @migrations ) {
        next if grep { $_ eq $migration } @deployed;

        deploy_one( $dbh, $migration );
    }
}

sub deploy_one {
    my $dbh = shift;
    my $migration = shift;

    print "$migration";
    my $script = $migration_dir->child('deploy')->child( "$migration.sql" );
    my $timestamp = _migration_timestamp( $migration );
    if ( _execute( $dbh, $script, 1 ) ) {
        $dbh->do(
            "INSERT INTO @{[ quote '_db_manager' ]} ( @{[ quote 'filename' ]}, @{[ quote 'timestamp' ]}) VALUES (?, ?)",
            {},
            $migration,
            $timestamp
        );
    }
}

sub verify_all {
    my $dbh = shift;

    my @migrations = _deployed( $dbh );
    foreach my $migration ( @migrations ) {
        verify_one( $dbh, $migration );
    }
}

sub verify_one {
    my $dbh = shift;
    my $migration = shift;

    print "$migration";

    my $script = $migration_dir->child('verify')->child( "$migration.sql" );
    _execute( $dbh, $script );
}

sub revert_one {
    my $dbh = shift;
    my $migration = shift;

    my $sth = $dbh->prepare( "SELECT 1 FROM @{[ quote '_db_manager' ]} WHERE @{[ quote 'filename' ]} = ?" );
    my $exists = @{ $dbh->selectcol_arrayref( $sth, {}, $migration ) };

    print "$migration";

    if ( !$exists ) {
        print "\n\tnot deployed\n";
        return;
    }

    my $script = $migration_dir->child('revert')->child( "$migration.sql" );
    if ( _execute( $dbh, $script ) ) {
        $dbh->do( "DELETE FROM @{[ quote '_db_manager' ]} WHERE @{[ quote 'filename' ]} = ?", {}, $migration );
    }
}

sub list_deployed {
    my $dbh = shift;

    my @migrations = _deployed( $dbh);
    foreach ( @migrations ) {
        say "  $_";
    }
}

sub list_available {
    my $dbh = shift;

    my @deployed = _deployed( $dbh);
    my @migrations = _migrations();

    my %seen;
    @seen{ @migrations } = ();
    delete @seen{ @deployed };
    my @available = keys %seen;

    foreach ( @available ) {
        say "  $_";
    }
}

sub add_migration {
    my $migration_name = shift;

    die "migration name already exists" if grep { $_ eq $migration_name } _migrations();
    my $timestamp = time;

    $plan->append_utf8("$timestamp $migration_name\n");

    my @template = ("BEGIN;\n", "\n", "    \n", "\n", "COMMIT;\n");
    foreach ( qw/deploy revert verify/ ) {
        my $migration = $migration_dir->child( $_ )->child( "$migration_name.sql" );
        $migration->parent->mkpath;
        $migration->spew_utf8( @template );
    }
}

sub _deployed {
    my $dbh = shift;

    my $sth = $dbh->prepare(
        "SELECT @{[ quote 'filename' ]} FROM @{[ quote '_db_manager' ]} ORDER BY @{[ quote 'timestamp' ]}"
    );
    return @{ $dbh->selectcol_arrayref( $sth ) };
}

sub _migrations {
    my %migrations = %{ _read_plan() };
    return map { $migrations{ $_ } } sort { $a <=> $b } keys %migrations;
}

sub _migration_timestamp {
    my $migration = shift;

    my %migrations = %{ _read_plan() };
    foreach ( keys %migrations ) {
        return $_ if $migrations{ $_ } eq $migration;
    }
}

sub _read_plan {
    my %migrations;
    foreach my $line ( $plan->lines_utf8 ) {
        chomp $line;

        my ( $date, $filename ) = split / /, $line;

        #XXX potential clash here, although unlikely
        $migrations{ $date } = $filename;
    }

    return \%migrations;
}

sub _execute {
    my $dbh = shift;
    my $script = shift;
    my $die = shift;

    if ( !$script->exists ) {
        print " - file not found\n";
        return;
    }

    eval {
        $dbh->do( $script->slurp_utf8 );
    };
    if ( $@ ) {
        my $error = $dbh->errstr;
        print " - NOT OK\n\t$error\n";
        exit 1 if ( $die );
    }
    else {
        print " - OK\n";
        return 1;
    }
}
