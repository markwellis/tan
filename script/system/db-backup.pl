use warnings;
use strict;

use Time::HiRes qw(time);
use Sys::Hostname;
use Date::Calc qw(Month_to_Text);
use File::Path qw(mkpath);
use File::Copy qw(copy);

##
# database settings...
my $db_user = 'backupguy';
my $db_passwd = 'FiewieJ0';
my $db_db = 'tan';

##
# output settings
my $backup_root_dir = '/mnt/stuff/backups/db';
my $backup_year = get_year();
my $backup_month = get_month();
my $backup_host = hostname();
my $backup_path = "${backup_root_dir}/".get_year().'/'.get_month().'/'.hostname().'/'.get_day();
my $master_file = '../master';
my $backup_file;
my $first_run_of_month = 0;

# Lets run the program...
main();

sub main {
    my $time = time;
    mkpath $backup_path;
    chdir $backup_path;

    $first_run_of_month = first_run_of_month();
    if ($first_run_of_month) {
        $backup_file = $master_file;
    } else {
        $backup_file = get_hour();
    }

    my $hot_copy_results = do_backup();
    my $tar_res = create_tar();
    my $diff_res = create_diff();
    cleanup();
    return 1;
}

sub cleanup {
    `rm -rf $db_db`;
    if (!$first_run_of_month) {
        unlink("${backup_file}.tar");
    }
}

sub make_read_only {
    my $file = shift;
    my $mode = 0444;
    return chmod $mode, $file;
}

sub create_diff {
    if (!$first_run_of_month){
        my $exec = `diff -Naur ${master_file}.tar ${backup_file}.tar > ${backup_file}.diff`;
        my $gzip = `gzip -f ${backup_file}.diff`;
        make_read_only("${backup_file}.diff.gz");
        return $exec;
    }
    return undef;
}

#creates the tar ball
#copies it to day/hour.tar.gz if its the master
sub create_tar {
    my $tar = `tar -cpf ${backup_file}.tar ${db_db}/`;
    make_read_only("${backup_file}.tar");
    if ($first_run_of_month){
        my $new_file = get_hour() . '-master';
        copy("${backup_file}.tar", "${new_file}.tar");
        my $gzip = `gzip -f ${new_file}.tar`;
        make_read_only("${new_file}.tar.gz");
    }
    return $tar;
}

sub do_backup {
    return `mysqlhotcopy -u ${db_user} -p ${db_passwd} ${db_db} .`;
}

sub first_run_of_month {
    if (-e "${master_file}.tar") {
        return 0;
    } else {
        return 1;
    }
}

sub get_year {
    return (localtime)[5]+1900;
}

sub get_month {
    return sprintf("%02d", (localtime())[4]+1) . " - " . Month_to_Text((localtime)[4]+1);
}

sub get_day {
    return sprintf("%02d", (localtime())[3]);
}

sub get_hour {
    return sprintf("%02d", (localtime())[2]);
}
