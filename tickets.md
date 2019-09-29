#617 - broken gifs - 2015-10-16 13:06:51 - new
```
http://i.imgur.com/PhkKp8y.gif
```
#616 - deploy remove js/css minifed cache - 2015-09-01 21:00:01 - new
```
change it to not be a symlink, and add the version on the end as query param
```
#615 - case sensitive useranme - 2015-09-01 20:54:05 - closed
```
make sure to lc username when logging in, and when checking if it already exists
```
#614 - broken gif 500 error - 2015-10-08 19:10:32 - closed
```
https://thisaintnews.com/static/user/pics/1328745600/1329003111_WTF--.gif
```
#613 - replace TT html filter - 2015-08-13 09:29:29 - new
```
__PACKAGE__->config(
    FILTERS => {
        html          => \&stronger_html_encoder,
    }
);
use HTML::Entities ();

sub stronger_html_encoder {
    HTML::Entities::encode( $_[0] );
}

```
#612 - sbmitted tags order changed - 2015-08-05 14:58:07 - new
```
it got reversed, that's not cool
```
#611 - submit tags case sensitive - 2015-09-01 20:58:56 - closed
```
i think
```
#610 - remove nano seconds from timestamp display - 2015-08-05 09:20:09 - new
```
because it's shit
```
#609 - external views are not being recorded - 2015-08-03 10:47:45 - new
```
104880 | 2015-02-08 16:00:40

was the last one
```
#608 - get changes from server - 2015-10-08 19:08:52 - closed
```
there's loads to import
```
#607 - reCAPTCHA v2 - 2015-07-29 22:06:48 - new
```
perhaps do it as part of the formhandler thing
```
#606 - "+" is not valid in email address! - 2015-07-29 22:04:46 - new
```
fix it
```
#605 - 500 error Could not open file /var/www/TAN/root/static/cache/thumbs/137000/137913: Is a directory - 2015-05-31 10:54:04 - closed
```
Caught exception in TAN::Controller::Thumb->index "write image  error Could not open file /var/www/TAN/root/static/cache/thumbs/137000/137913: Is a directory at /var/www/TAN/lib/TAN/Controller/Thumb.pm line 37."
```
#604 - 500 error - Could not open file /var/www/TAN/root/static/cache/ thumbs/67000/67102: Is a directory at - 2015-04-27 07:53:01 - new
```
Error:
Caught exception in TAN::Controller::Thumb->index "write image  error Could not open file /var/www/TAN/root/static/cache/thumbs/67000/67102: Is a directory at /var/www/TAN/lib/TAN/Controller/Thumb.pm line 37."


URL:
https://thisaintnews.com/thumb/67000/67102/index.html

Referer:


Client IP:
98.165.96.8
```
#603 - image thumbnail is blurred - 2015-10-08 19:12:23 - closed
```
see https://thisaintnews.com/view/picture/137359/global-temperature-anomalies-averaged-from-2008-through-2012
```
#602 - redirect old recent comments url - 2015-03-21 15:19:30 - closed
```
RewriteRule ^/recent_comments/?$ /recent/comments [R=301,NE,L]
```
#601 - remove pagecache plugin - 2015-03-21 15:10:11 - closed
```
it's terrible, and because of the new stash thing it doesn't work properly
```
#600 - og data wrong - 2015-03-21 15:03:39 - closed
```
needs to be article, not website. and make the thumbnail bigger
```
#599 - recent comments on deleted objects still show - 2015-03-11 22:04:04 - closed
```
it's not checking object.deleted
```
#598 - convert image model to use imager - 2015-03-11 19:51:57 - closed
```
instead of shelling out to convert
```
#597 - hide quotes in recent comments - 2015-10-08 19:13:47 - closed
```
it's ugly
```
#596 - recent links etc - 2015-02-08 22:47:23 - new
```
add it
```
#595 - convert to Path::Tiny - 2015-02-08 22:47:23 - new
```
in places, like TAN::Model::ParseHTML
```
#594 - html video embed - 2014-10-21 21:55:40 - closed
```
add versions to all modules (good time to  switch to distzilla?)

only load modules with out version

add option for ssl, and disable url to embed for sites that don't support ssl (liveleak etc)
```
#593 - disable sslv3 - 2014-10-21 22:04:37 - closed
```
it's already done on the server, but make it official

https://blog.cloudflare.com/sslv3-support-disabled-by-default-due-to-vulnerability/
```
#592 - change req->param(foo) to req->params->{foo} - 2015-02-08 22:47:23 - new
```
because of the security problems, and other things
```
#591 - 302 redirect on / - 2014-09-09 21:56:29 - closed
```
it should be a 301, and it's not serving the whole hostname either
```
#590 - tweak score algorithm - 2014-09-09 21:56:29 - closed
```

```
#589 - 500 error on change password with length over 50 - 2014-09-09 21:56:29 - closed
```
not a very helpful error!
```
#588 - upgrade ssl cert to sha256 - 2014-10-21 22:13:09 - closed
```
https://shaaaaaaaaaaaaa.com/check/thisaintnews.com
```
#587 - views revisions - 2015-02-08 22:48:14 - new
```
at the moment there's a update_or_create, which is 2 sql queries, it would be far more sensible to just insert a new view and use the created date as the revision number
```
#586 - remove profile pages from objects - 2015-02-08 22:47:23 - new
```
it's stupid, make it a separate table
```
#585 - nsfw admin log items shouldn't show - 2015-02-08 22:47:23 - new
```
coz that's not cool
```
#584 - Wide character in syswrite on poll vote - 2015-02-08 22:47:23 - new
```
— I want to have cake and eat it too. (for Beelz) 
```
#583 - rename forigen keys in db and run dbicdump - 2015-02-08 22:47:23 - new
```
the big problem when i ran this before was it renaming all the relationships. they might not be perfect, but for now it's a good idea to rename them in the db, run dbicdump and then work on the rest from there
```
#582 - tin tan comments - 2015-02-08 22:47:23 - assigned
```
move plus_minus to 2 new tables, tin & tan.

add ability to tin/tan comments

comments that have a tan > $CUTOFF_AMOUNT should be hidden by default

something about user comment tin:tan ratio auto hiding?
```
#581 - cleanup code - 2015-02-08 22:47:23 - assigned
```
remove profiler, whitespace etc 

lots of little things, make it tidier
```
#580 - tagthumbs doesn't check for deleted - 2015-10-08 19:12:45 - closed
```
you can have a deleted pic a tag thumb
```
#579 - change sslciphersuite - 2014-06-09 21:31:48 - closed
```
http://blog.cloudflare.com/killing-rc4-the-long-goodbye

EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
```
#578 - static cache-control public header - 2014-05-01 19:42:20 - closed
```
because it's better for caching apparently, especially mixed with ssl
```
#577 - move backups - 2014-10-21 22:13:29 - closed
```
shared hosting is expiring, move it back to tvc
```
#576 - switch back to openssl - 2014-04-26 17:07:45 - closed
```
since it's getting a lot more inspection now, it'll be safer. also tls 1.2
```
#575 - twitter worker not working - 2015-10-08 19:13:04 - closed
```
it's well out of date
```
#574 - bookmarklet blank page - 2015-02-08 22:47:23 - new
```
if you submit one image, then another, the 2nd will be a blank page :/
```
#573 - comments not adding to search index - 2014-04-26 14:08:51 - closed
```
:|
```
#572 - http https urls don't duplicate detect - 2015-02-08 22:47:23 - new
```
eg 

https://www.youtube.com/watch?v=5Krz-dyD-UQ

and 

http://www.youtube.com/watch?v=5Krz-dyD-UQ

can both be submitted
```
#571 - password change ability - 2015-02-08 22:47:23 - new
```
add it
```
#570 - renew tan cert - 2014-04-08 18:14:31 - closed
```
because of heartblead, just make a new one
```
#569 - switch to nss instead of openssl - 2014-04-08 12:25:11 - closed
```
openssl is bad apparently, nss is much more betterer
```
#568 - update password storage salt etc - 2015-02-08 22:47:23 - new
```
http://www.wumpus-cave.net/2014/03/31/perl-encryption-primer-passwords/

{{{#!perl
# These should come from a general configuration
my $PASSPHRASE_CLASS = 'Authen::Passphrase::BlowfishCrypt'; # AKA bcrypt
my %AUTHEN_PARAMETERS = (
    salt_random => 1,            # Creates a good salt for us
    cost        => $BCRYPT_COST, # Tweak as necessary
);
 
my $auth = $PASSPHRASE_CLASS->new(
    %AUTHEN_PARAMETERS,
    passphrase => $passphrase,
);
my $hashed_passphrase = $auth->as_rfc2307;
}}}

and

{{{#!perl
my $matched = 0;
my $auth = Authen::Passphrase->from_rfc2307( $db_passphrase );
if( $auth->match( $passphrase ) ) {
    if( ref($auth) ne $PASSPHRASE_CLASS ) {
        my $new_auth = $PASSPHRASE_CLASS->new(
            %AUTHEN_PARAMETERS,
            passphrase => $passphrase,
        );
        my $new_db_passphrase = $new_auth->as_rfc2307;
        # Save $new_db_passphrase back into your database for this user
    }
    # Also check for bcrypt cost, but be sure not to assume bcrypt is used.  Left as an
    # exercise to the reader.
    $matched = 1;
}
# return $matched for successful/unsuccessful login
}}}
```
#567 - image doesn't upload :/ - 2014-10-21 22:12:30 - closed
```
for some reason this is an invalid image, when it's not
```
#566 - backup scripts - 2015-10-08 19:14:28 - closed
```
db backup - don't backup views table data - might have to make it a 2 step backup, schema.sql + data.sql

remove encryption, as it's not going anywhere unsafe now
```
#565 - search nsfw - 2014-03-09 21:31:34 - closed
```
needs to set nsfw:0 instead of nsfw:n
```
#564 - embedded  videos ssl - 2014-04-26 14:09:30 - closed
```
Liveleak et 
```
#563 - dance smilie is wrong - 2014-01-26 00:15:15 - closed
```
there are 2 dance.gif and dance.png, rename and add an alias
```
#562 - video embed https - 2014-10-21 22:13:59 - closed
```
viemo etc
```
#561 - sitemap pinger worker - 2015-02-08 22:47:23 - new
```
doesn't log the sitemap url, seems broken.

investigate

pinging http://submissions.ask.com/ping?sitemap=
pinging http://www.google.com/webmasters/sitemaps/ping?sitemap=
pinging http://search.yahooapis.com/SiteExplorerService/V1/updateNotification?appid=IRxERwfV34EV44V9LTrJsENRs0V4JlaxrmVCr93OXcpqgzdQqUVRjKIo0FrabG1g&url=
pinging http://webmaster.live.com/ping.aspx?siteMap=
pinging http://api.moreover.com/ping?u=
```
#560 - upgrade to ubuntu 13.10 (for apache 2.4) - 2013-10-26 14:00:50 - closed
```
use the mozilla recommended settings (requires apache 2.4)

https://wiki.mozilla.org/Security/Server_Side_TLS
```
#559 - reduce salt size - 2013-10-17 21:47:23 - closed
```
512 is massive, drop it to 32 instead
```
#558 - secure tan - 2014-05-04 13:20:49 - closed
```
~~encrypt db backups~~
~~encrypt system backups~~
~~encrypt existing backups~~
encrypt tan.pl git
~~encrypt tan.pl salt~~ no point when #568 is done
encrypt tan.pl trac

~~Disable read permissions for backup scripts~~
Apparmour

```
#557 - recaptcha  use ssl - 2013-09-20 22:46:54 - closed
```
it's not being displayed on the login page because it's not ssl
```
#556 - exception simple accessor name - 2013-09-20 20:55:45 - closed
```
make sure name is a valid perlsub name

same for lucyx search result
```
#555 - ebaumsworld video embed fail - 2013-09-20 21:16:02 - closed
```
https://thisaintnews.com/view/video/130523/Otester-Found-in-South-Africa
```
#554 - gearman::xs - 2013-09-20 19:46:08 - closed
```
replace gearman with gearman::xs
```
#553 - replace json::xs with Cpanel::JSON::XS - 2013-09-20 18:53:26 - closed
```
it's more better init
```
#552 - perl 5.18.1 - 2013-09-18 20:26:20 - closed
```
upgrade
```
#551 - ssl fixes - 2013-09-17 17:54:46 - closed
```
Enable forward secrecy

Ssllabs.com get rating up!
```
#550 - certificate www.this... instead of dev - 2013-09-17 17:52:00 - closed
```
Change it
```
#549 - max password input length - 2013-09-20 22:46:54 - closed
```
You could dos the site with a really long password
```
#548 - move modules to github - 2013-08-10 09:27:01 - closed
```
help perl a lil bit
```
#547 - Nielsen’s ten heuristics - 2013-07-26 17:49:10 - closed
```
Get it
```
#546 - mysql error in syslog - 2013-07-19 09:45:19 - closed
```
Jul 18 06:35:52 tan mysqld: 130718  6:35:52 [Warning] Unsafe statement written to the binary log using statement format since BINLOG_FORMAT = STATEMENT. Statement is unsafe because it invokes a trigger or a stored function that inserts into an AUTO_INCREMENT column. Inserted values cannot be logged correctly. Statement: INSERT INTO `views` ( `created`, `ip`, `object_id`, `session_id`, `type`, `user_id`) VALUES ( NOW(), '66.249.78.22', '90809', 'e9a72794ed40aedf579dc9f2bee1a20a584b37d6', 'internal', NULL )
```
#545 - apparmour or grsec, use one - 2013-07-23 20:05:40 - closed
```
probably apparmor as it's installed and ubuntu standard
```
#544 - ban probey ip's - 2013-07-24 13:21:14 - closed
```
they annoy me
```
#543 - warning in errorlog - 2013-07-20 14:53:58 - closed
```
Use of uninitialized value in concatenation (.) or string at /var/www/TAN/lib/TAN/Controller/Search.pm line 20.
```
#542 - rkhunter cron - 2013-07-15 21:33:42 - closed
```
Install it and add a cron job
```
#541 - twitter spammer broken - 2013-07-20 14:53:58 - closed
```
hmm
```
#540 - youtube timecode - 2013-07-08 22:27:31 - closed
```
it uses ?start= instead of #t= now
```
#539 - accesslogs in vhosts - 2013-07-08 12:15:14 - closed
```
some don't have them, some do. clean them up etc
```
#538 - leach protector - 2013-07-24 13:28:33 - closed
```
rewrite it in apache land

see https://trac.thisaintnews.com/thisaintnews/browser/tan/conf/varnish/tan.vcl?rev=b156b5eea1ad343b0555adfc9a27c40d6c68d3a7 for the rules
```
#537 - tan www.thisiantnews.com redirect - 2013-07-04 13:59:00 - closed
```
when you type thisaintnews.com into address it gets redirected to https://www.thisaintnews.com then https://thisaintnews.com/index/all/0/ change the redirect detect thing to have a condition for www.
```
#536 - trac vhost on ssl - 2013-07-04 13:10:42 - closed
```
get new ip, ssl cert (use cacert) etc
```
#535 - re2  - impliment and benchmark - 2014-10-21 22:09:57 - closed
```
find suitable use cases etc
```
#534 - unix socket for starman - 2013-07-03 13:24:20 - closed
```
i think it supports them, change the startup script and vhost config to use them instead
```
#533 - smilies.png (for tinymce icon) scale to 20x20 - 2013-06-30 14:22:21 - closed
```
currently 24x24
```
#532 - resize comment icon to 15x15 - 2013-06-30 14:22:21 - closed
```
currently 20x20 scaled to 15x15

check this wont mess anything up
```
#531 - resize twitter icon to 15x15px - 2013-06-30 14:22:21 - closed
```
it's currently 16x16 scaled to 15. 
```
#530 - url decode on submit bookmarklet - 2013-07-16 18:23:41 - closed
```
yeah
```
#529 - remove --limit-requestbody in startup script - 2013-06-30 14:22:20 - closed
```
it's not needed anymore for starman

also move apache limit request body outside of vhost 
```
#528 - admin delete coment failed - 2013-06-30 15:39:21 - closed
```
Error:
DBIx::Class::Storage::DBI::_dbh_execute(): DBI Exception: DBD::mysql::st execute failed: BIGINT UNSIGNED value is out of range in '(`tan`.`object`.`comments` - 1)' [for Statement "UPDATE `comments` SET `deleted` = ? WHERE ( `comment_id` = ? )" with ParamValues: 0=1, 1='308385'] at /var/www/TAN/lib/TAN/Controller/View/Comment.pm line 155

https://thisaintnews.com/view/link/115435/Turning-the-tables-on-Big-Brother--Now-internet-users-can-watch-who-is-spying-on-them-in-blow-against-Google-s-new-snooping-policy#comment308385
```
#527 - find slow sql queries - 2013-10-17 21:50:46 - closed
```
for example the page count isn't cached
```
#526 - ditch varnish, use spdy and ssl - 2013-07-03 12:46:42 - closed
```
not needed, just use apache and mod_cache for the tan app
```
#525 - sanitize input - 2013-06-25 23:06:21 - closed
```
Error:
DBIx::Class::Storage::DBI::_select_args(): A supplied offset attribute must be a non-negative integer at /var/www/TAN/lib/TAN/Schema/ResultSet/Object.pm line 77



URL:
http://thisaintnews.com/index/all/0/?page=6'%20or%201%3Dconvert(int%2Cchr(114)%7C%7Cchr(51)%7C%7Cchr(100)%7C%7Cchr(109)%7C%7Cchr(48)%7C%7Cchr(118)%7C%7Cchr(51)%7C%7Cchr(95)%7C%7Cchr(104)%7C%7Cchr(118)%7C%7Cchr(106)%7C%7Cchr(95)%7C%7Cchr(105)%7C%7Cchr(110)%7C%7Cchr(106)%7C%7Cchr(101)%7C%7Cchr(99)%7C%7Cchr(116)%7C%7Cchr(105)%7C%7Cchr(111)%7C%7Cchr(110))--
```
#524 - dev.thisaintnews.com not using custom module path - 2013-06-25 10:30:55 - closed
```
probably something wrong in start_tan.sh
```
#523 - css image sizer - 2015-02-08 22:47:23 - new
```
instead of the js way it's done now, in comments, blogs forums etc

see mobile css for correct way to do it
```
#522 - http caching - 2013-07-20 14:58:52 - new
```
	

    sub end : ActionClass('RenderView') {
        my ( $self, $c ) = @_;
     
        my $cache_time = $c->stash->{'cache_time'};
        if (defined( $cache_time )  && ! (scalar @{ $c->error })) {
            $c->response->headers->last_modified(time);
            $c->response->headers->expires(time + $cache_time);
            $c->response->headers->header(cache_control => "public, max-age=$cache_time");
        }
        else {
            $c->response->headers->last_modified(time);
            $c->response->headers->expires(time - 1);
            $c->response->headers->header(cache_control => "no-cache, must-revalidate");
            $c->response->headers->header(pragma => "no-cache");
        }
     
    }


```
#521 - youtube us nocookie site - 2013-06-25 10:20:00 - closed
```
Privacy
```
#520 - twitter spammer uses old api - 2013-06-21 09:50:06 - closed
```
upgrade
```
#519 - remove newlines for none mobile posts - 2013-07-20 15:00:07 - new
```
Make it one giant blob of text, so when editing/quoting on mobile it doesn't get messed up
```
#518 - db_backup script not dumping triggers - 2013-06-20 19:20:59 - closed
```
it's a bitch
```
#517 - sns-structcadtech.com - 2013-06-20 14:24:50 - closed
```
add this
```
#516 - varnish redirect rule - 2013-06-20 14:13:12 - closed
```
redirect all unmatched to thisaintnews.com
```
#515 - aws - 2013-06-20 12:21:20 - closed
```
needs aws, don't forget it's patched
```
#514 - git commit hook new PYTHONPATTH - 2013-06-20 11:45:53 - closed
```
because it's not in system anymore
```
#513 - trac - 2013-06-20 11:28:35 - closed
```
setup trac vhost
```
#512 - dbix warning - 2013-06-20 09:39:37 - closed
```
Malformed UTF-8 character (unexpected non-continuation byte 0x20, immediately after start byte 0xff) in regexp compilation at /mnt/stuff/perl/perls/perl-5.18.0/lib/site_perl/5.18.0/DBIx/Class/Storage/DBIHacks.pm line 516.

caused by 

DBIx/Class/Storage/DBIHacks.pm:469:    $sql_maker->{quote_char} = ["\x00", "\xFF"];
```
#511 - accesslog - 2013-06-18 12:59:48 - closed
```
there's no accesslog in starman, apply this

http://search.cpan.org/~miyagawa/Plack-1.0028/lib/Plack/Middleware/AccessLog.pm
```
#510 - link rel="image_src" - 2013-06-21 11:11:22 - closed
```
for reddit, facebook etc
```
#509 - devel config not loading - 2013-06-15 19:32:21 - closed
```
add CATALYST_CONFIG_LOCAL_SUFFIX=devel to start_tan script
```
#508 - create tickets from markdev.new_install_list - 2013-06-15 15:41:44 - closed
```
exciting
```
#507 - exim - 2013-06-18 12:56:39 - closed
```
pretty sure that it's a standard install on current tan server. 

tandev has same standard install, test it
```
#506 - max file upload size - 2013-06-20 14:04:07 - closed
```
currently starman and varnish will allow w/e through.

fix that so the max size is like 8mb or something
```
#505 - gearmanx::simple::worker is now deprecated - 2013-06-14 19:34:07 - closed
```
add a note to the pod that it's now unmaintained, release
```
#504 - convert worker scripts to upstart - 2013-06-14 16:52:53 - closed
```
probably don't need to use app:daemon any more, or gearmanx::simple::worker for that matter
```
#503 - given/when is now experimental - 2013-06-15 19:32:21 - closed
```
given is experimental at /var/www/TAN/lib/TAN/Controller/Tcs.pm line 35.
when is experimental at /var/www/TAN/lib/TAN/Controller/Tcs.pm line 36

may be others lurking, find them!
```
#502 - catalyst 5.90040 - 2013-06-15 16:00:45 - closed
```
http://search.cpan.org/~jjnapiork/Catalyst-Runtime-5.90040/lib/Catalyst/Upgrading.pod
```
#501 - starman upstart job - 2013-06-13 17:14:58 - closed
```
create a upstart job, have it respawn etc
```
#500 - new server - 2013-06-20 15:30:17 - closed
```
make devbox
 log everything
 tickets under 5.1

when done, test like mad

remake devbox

test, test, test

order server and remake server

test test test

switch dns

other?
```
#499 - root redirect removes query params - 2013-06-12 17:14:01 - closed
```
eg /?show_minify becomes /index/all/0/
```
#498 - configs for varnish and apache - 2013-06-13 17:14:58 - closed
```
create them
```
#497 - don't detect mobile on thumb or minify - 2013-06-12 15:44:05 - closed
```
no point, since it goes through static and varnish will remove the cookie, so it'll be ran again and again...
```
#496 - disable debug on Plugin::Cache - 2013-06-12 14:24:48 - closed
```
prints a lot of memcached traces, not needed
```
#495 - static on seperate domain - 2013-06-12 15:57:16 - closed
```
static.thisaintnews.com

```
#494 - psgi - 2013-06-12 12:55:33 - closed
```
create tan.psgi for starman
```
#493 - autoconvert beaking img scr - 2013-06-11 19:27:53 - closed
```
the following

<img alt="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" src="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" height="659" width="490" />

becomes

<a href="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" height="659" src="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" width="490" /> 
```
#492 - facebook  video embed - 2013-06-25 09:55:02 - closed
```
Apperentlh facebook  videos are embeddable
```
#491 - o_0 smiley face not auto converting - 2013-06-21 10:14:57 - closed
```
o_0

And reversed
```
#490 - profile user page missing avatars - 2013-06-21 11:11:22 - closed
```
the page of all the users has no avatars
```
#489 - admins cant change type on own posts - 2013-06-21 11:15:57 - closed
```
Can't change own forum to poll etc
```
#488 - bookmarklet submit white page - 2013-07-16 22:35:45 - closed
```
not sure what it's all about, investigate.
```
#487 - proper bookmarklet support with quick add url - 2013-07-20 14:58:08 - new
```
After #486

Add new url that takes url to submit as parameter and then redirects to submit

Auto detects type (image, video, link) and fetches metadata where possible so prefilled om submit page
```
#486 - submit auto complete - 2013-07-20 14:58:08 - new
```
insert url, have it pull data automatically (where possible)

also check for repost etc

AJAX
```
#485 - facebook spammer - 2013-07-20 14:58:08 - new
```
make one like the twitter spammer. 

make a facebook group
```
#484 - reddit spammer - 2015-02-08 22:47:23 - new
```
make a reddit spammer like the twitter one
```
#483 - open graph tags - 2013-06-25 10:51:52 - closed
```
https://developers.facebook.com/tools/debug/og/object?q=http%3A%2F%2Fthisaintnews.com%2Fview%2Fpicture%2F128257%2FAt-the-click-of-a-button%23comment369128
```
#482 - liveleak fullscreen doesn't go full screen - 2013-06-25 10:20:00 - closed
```
Check the embed code
```
#481 - auto embed failures - 2013-04-23 17:11:19 - closed
```
Video embed failed without tags on

http://thisaintnews.com/view/blog/127926/The-Shock-of-the-Shite

Look at code, strip video tags and add to tests
```
#480 - submit upload custom picture - 2013-07-20 14:58:08 - new
```
How about a "upload other picture for post" button that would have a popup streamlined picture upload, and when you hit done the popup closes and the main post uses that picture. Sure you'd still havento enter title + tags, but that's not too bad is it?
```
#479 - facebook world thing - 2013-07-20 14:58:08 - new
```
Show objects that have comments newer than last view, limited to 20 or so
```
#478 - recent comments upgrade - 2013-07-20 14:58:08 - new
```
Recent viewed, recent tined, recent tanned, recent posted, recent promoted. Add those
```
#477 - chrome citing render error - 2013-04-20 08:47:12 - closed
```
when smilies were being replaced with img tag, but it wasn't closed, chrome was refusing to render the ajax recieved content.

I've hacked the doctype to html5 in an untestable attempt to stop this, also have fixed the img tag problem, but it's not a long term soultion.

seems to be mootools asking for text/xml, instead of text/html. hmmm

https://groups.google.com/forum/?fromgroups=#!topic/mootools-users/1HQeLJ_vMt0

investigate the cause and find a proper fix.

try making a standalone html page that requests the broken html and injects it and see if it breaks xhtml page and works on html5 page, find a fix

also it's not valid html5
http://validator.w3.org/check?uri=http%3A%2F%2Fthisaintnews.com%2Fview%2Fpicture%2F127925%2FError-Message&charset=%28detect+automatically%29&doctype=Inline&group=0
```
#476 - Use of uninitialized value in substitution - 2013-04-20 08:52:14 - closed
```
Use of uninitialized value in substitution (s///) at /var/www/thisaintnews.com/htdocs2/lib/TAN/Model/Submit.pm line 55.
Use of uninitialized value in string eq at /var/www/thisaintnews.com/htdocs2/lib/TAN/Model/Submit.pm line 56.

```
#475 - youtube playlist - 2013-06-25 10:17:36 - new
```
add support for the above
```
#474 - teweet embed - 2013-04-18 11:36:06 - new
```
https://dev.twitter.com/docs/embedded-tweets
```
#473 - who's online mobile - 2015-02-08 22:47:23 - new
```
At the top of the page maybe?
```
#472 - update faq video support - 2013-04-17 10:02:36 - closed
```
Lists video sites that are no longer suppoted
```
#471 - youtube video timeselector #t= - 2013-04-18 12:27:02 - closed
```
should be easy, e.g.

http://www.youtube.com/watch?v=5t99bpilCKw#t=00m08s
```
#470 - mobile order by - 2015-02-08 22:47:23 - new
```
Add order by sort box thing on indexes for mobile pages
```
#469 - password salting - 2013-07-01 10:06:42 - closed
```
http://crackstation.net/hashing-security.htm

Do it, find a way to do it without requiring useres passwords, eg sha password, salt sha, hash sha + salt
```
#468 - catalyst::plugin::email uses email::send which is depricated - 2013-06-18 12:55:45 - closed
```
email::send uses return::value which is depricated.

update catalyst::plugin::email to use email::sender

send patches
```
#467 - db script to convert smiley images to :smilies - 2015-02-08 22:47:23 - new
```
split from #461 since I don't have a proper test setup on this netbook

Script to go through db and convert smilie imgs into plaintext
```
#466 - add flock around delete old js versions - 2013-04-17 07:25:25 - closed
```
So only one person gets to delete, stop the errors in the error_log
```
#465 - nsfw filter disables itself on mobile site - 2013-07-12 21:04:19 - closed
```
Why? Cookie maybe? Cache checker?
```
#464 - mobile tan profile link - 2013-04-17 10:08:03 - closed
```
At top of page
```
#463 - ajax comment edit mobile site - 2013-07-20 14:58:52 - new
```
Ajaxinate
```
#462 - better nl2br for mobile - 2013-07-26 18:21:47 - closed
```
It doesn't work for blogs anyway.

Make it so that if you submit and then edit it doesn't double nl2br.

Tests
```
#461 - smilies, urls and auto embed - 2013-04-19 15:59:53 - closed
```
First up, better be test driven.

Second, use the bbcode module

Auto convert urls into hyperlinks, if they're not already, and not in embed iframes, or are not embeddable

Smilies, both ;-)  and ;) should be the same. Smilie inserter should just insert plaintext instead of image.

Script to go through db and convert smilie imgs into plaintext
```
#460 - video urls - 2013-04-10 07:11:15 - closed
```
Vimeo puts a /m in the url if on mobile

Ebuamsworl doesnt have to end in a /

Check others
```
#459 - edit object submit button says "submit $type" instead of "Edit $type" - 2013-04-04 05:54:33 - closed
```
fix
```
#458 - edit comment on mobile textarea is TINY!!! - 2013-04-15 05:21:06 - closed
```
make it normal sized!
```
#457 - write mass_undelete script - 2013-04-04 05:31:59 - closed
```
pass in mass delete arg, have it decode the json and update deleted=>0
```
#456 - new users can't upload avatar - 2013-04-04 05:32:01 - closed
```
coz it's set to NULL in the db.

change template where it does replace to pass in avatar, change user result avatar to take avatar filename
```
#455 - mobile site tune ups - 2013-02-23 08:12:15 - closed
```
add padding under comment box, as the keyboard on android covers it.

add hr under menu on recent comments page

make page buttons bigger
```
#454 - mobile site is shit on touch - 2013-02-17 04:53:58 - closed
```
add some padding around things, make hyperlink font slightly bigger
```
#453 - Error opening file for reading: Permission denied - 2013-04-14 15:12:04 - closed
```
{{{
findin open
./TAN/Model/Image.pm:49:    open( my $fh, "<", $input ) || die "bugger"; #lock input, because output doesn't exist
./TAN/Model/Submit/Module/Picture.pm:119:        open(INFILE, $image_info->{'temp_file'}->filename);
./TAN/Model/Minify.pm:20:        open(INPUT, $output);
./TAN/Model/Minify.pm:28:        open(INPUT, "< ${input}");
./TAN/Model/Minify.pm:31:            open(OUTPUT, "> ${output}");
}}}

add in some debug and error handling etc
```
#452 - nl2br nor working in comment submit for mobile - 2013-04-16 10:00:26 - closed
```
but it is working on comment edit. fix
```
#451 - tinymce 3.5.8 - 2013-01-21 12:14:25 - closed
```
upgrade
```
#450 - broken menu - 2013-01-18 09:58:30 - closed
```
go to upcoming or promoted page then go to the same page, menu broken. some javascript error about split
```
#449 - broken tin/tan buttons on ff 18 - 2013-01-19 11:50:04 - closed
```
change them to be more simple
```
#448 - object revisions - 2013-06-30 14:29:10 - closed
```
split up #333
```
#447 - comment revisions - 2013-06-30 14:29:02 - closed
```
split up ticket #333
```
#446 - 500 error mobile template - 2012-12-06 12:33:03 - closed
```
it's showing the normal template
```
#445 - 500 error - 2012-12-06 12:28:22 - closed
```
changing forum to blog on mobile

Error:
DBIx::Class::ResultSet::create(): DBI Exception: DBD::mysql::st execute failed: Duplicate entry '124779' for key 'PRIMARY' [for Statement "INSERT INTO blog ( blog_id, description, details, picture_id, title) VALUES ( ?, ?, ?, ?, ? )" with ParamValues: 0='124779', 1="What if...actually existed?", 2="<strong><span style="font-size:xx-large; color:#ff6600">What if Star Trek Holodecks actually existed?</span></strong><br /><br /><span style="font-size:small; color:#000000"><strong>What is a holodeck?</strong><br />A holodeck is simply a holographic projection in special rooms, using advanced technology to simulate matter inside a special room, usually found in space stations or are ground based. This means that although objects created inside the hol</span>odeck are holograms, special advanced equipment is used to replicate or transport matter to them, making them able to be touched/carried/held by the user. The tech is so powerful it can create believable AI personalities, so to the unaware they would think they were talking to a real person.<br /><br />This is a holodeck <br />[video]http://www.youtube.com/watch?v=E11v3qmuKxk[/video]<br />Notice how Commander William Riker simply inputs vague commands and the computer builds it for him. In other areas of Star Trek after TNG su...", 3="53068", 4="What if..."] at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Submit/Edit.pm line 148



URL:
http://thisaintnews.com/submit/forum/edit/124779/post

Referer:
http://thisaintnews.com/submit/forum/edit/124779/

Client IP:
149.135.146.45


```
#444 - ssh to tan.pl - 2012-12-06 12:29:10 - closed
```
can't ssh from tan.com
```
#443 - 500 error - 2012-12-06 12:24:59 - closed
```
Error:
Caught exception in TAN::Controller::Tcs->agree "Can't call method "update" on an undefined value at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Tcs.pm line 56."


URL:
http://thisaintnews.com/tcs/submit?accept=Agree

Referer:
http://thisaintnews.com/tcs

Client IP:
68.7.233.61


```
#442 - date joined wrong on profile page - 2012-12-06 12:35:25 - closed
```
it's showing like this:
Joined 2012-12-03T08:30:53 ago

probably missing the _accessor in the db schema
```
#441 - avatar upload - 2012-12-03 01:09:21 - closed
```
pre_crop page needs a ?t=$time adding to the url so it sees the correct image, also all the old avatars are still there, maybe add a user old avatar thing
```
#440 - blank 404 page for minify - 2012-12-01 13:21:45 - closed
```
no point serving up a huge 404 page when a blank page will do
```
#439 - db cleanup - 2012-11-30 08:38:02 - closed
```
~~change db to use BOOL instead of ENUM('Y','N')~~

~~update db schema code~~

~~change code to reflect change from ENUM('Y','N') to BOOL~~

~~change db types to better fit (ie, not all big ints)~~

~~update recent_comments view (rename NSFW to nsfw etc)~~

~~remove extra things (old lookups? etc)~~

~~workers~~

~~search index rebuild script~~

~~db triggers~~
```
#438 - javascript frontend - 2013-07-20 14:58:52 - new
```
after #420
```
#437 - terms and conditions - 2012-10-28 03:09:28 - closed
```
make it so they have to be accepted to use tan

rewrite t&cs

use cms to write t&cs, but use custom template to display them with accept (update user.tcs to tcs.rev) or decline (log user out)
```
#436 - cms admin missing - 2012-10-23 13:07:38 - closed
```
link is missing
```
#435 - comment delete missing - 2012-10-21 10:14:54 - closed
```
for some reason it's not there anymore, fix it
```
#434 - domains at zonedit - 2012-10-19 12:36:35 - closed
```
move none tan domains to new account.

move seans to own account.

perhaps same for lymehurst

remove howmanykillings.com
```
#433 - backup git - 2012-10-09 02:43:40 - closed
```
adjust backup script
```
#432 - test 2 - 2012-10-09 02:36:15 - closed
```
hook close test
```
#431 - test 1 - 2012-10-09 02:36:15 - closed
```
hook test
```
#430 - test git hooks - 2012-10-09 02:26:45 - closed
```
close this with hook
```
#429 - tidy up - 2012-10-16 08:46:49 - closed
```
there's a lot of old scripts and things hanging around that needn't be. cleanup time!
```
#428 - consolidate templates - 2012-10-16 08:46:48 - closed
```
lots of duplicates in view, move to shared. check other places
```
#427 - add no_bbcode to comment, use in quote - 2012-09-28 14:38:39 - closed
```
so instead of quoting the output html, quote the bbcode etc
```
#426 - Parse::TAN - 2012-09-28 13:59:21 - closed
```
make it into a model?

write tests

make quote tag nestable

remove youtube tag, write script to update database

make video tag remove hyperlinks
```
#425 - move TAN::Submit into modules - 2012-09-26 05:28:01 - closed
```
move it, update things as required, test etc
```
#424 - add pseudo class support - 2012-09-25 11:56:15 - closed
```

```
#423 - Image::Magick over `convert` - 2012-09-24 10:23:44 - closed
```
switch because using `convert` is a lil backwards
```
#422 - Model::Image flocking - 2012-09-24 11:20:18 - closed
```
flocking hell!
```
#421 - Mobile view animated gif truncated - 2012-09-24 08:46:51 - closed
```
Make it show the whole image
```
#420 - new design - 2014-05-14 21:26:15 - assigned
```
new design 
```
#419 - data::validate::image fails on tiff - 2012-08-25 00:52:33 - closed
```
due to convert error

/www/majesticmodules/Data-Validate-Image-0.006/t/test_data/images/image.tiff
TIFF 46x46 46x46+0+0 8-bit TrueColor DirectClass 908B 0.000u 0:00.000
convert: Error writing data for field "DocumentName". `/dev/null' @
error/tiff.c/TIFFErrors/496.

```
#418 - mobile site tin/tan ajx - 2012-08-19 02:42:49 - closed
```
or make it return to referer
```
#417 - edit comment font wierd - 2012-08-19 03:27:28 - closed
```
it's wrong on edit comment via ajax, dunno about on edit comment page
```
#416 - quote is missing an extra line break - 2012-08-19 03:49:05 - closed
```
after the [/quote] there should be another line break
```
#415 - more missing on tag thumbs - 2012-08-19 03:16:53 - closed
```
it's goned!
```
#414 - xss vun in recent_comments page - 2012-08-12 07:45:18 - closed
```
fix it!
```
#413 - Filter not working - 2012-08-12 08:48:35 - closed
```

```
#412 - Add marin bottom to TAN-bottom - 2012-08-12 07:41:33 - closed
```

```
#411 - emoticons plugin not working - 2012-08-19 03:07:41 - closed
```
check the original vs new emoticons.htm
```
#410 - use tags stems in twitter - 2012-08-19 03:14:11 - closed
```

```
#409 - move session cache - 2012-08-15 09:51:59 - closed
```
so that users don't get logged out on restart
```
#408 - menu javascript - 2012-08-10 08:08:47 - closed
```
make it so the menu changes on click
```
#407 - change HTML::Video::Embed to take a class instead of height/width - 2012-08-27 08:30:09 - closed
```
test works properly etc
```
#406 - edit page - 2012-10-07 12:47:24 - closed
```

```
#405 - profile page - 2012-08-28 08:59:20 - closed
```

```
#404 - remove menu items - 2012-08-10 02:07:58 - closed
```
home, admin log, chat etc
```
#403 - up/down link - 2012-08-10 02:12:38 - closed
```
top and bottom of page
```
#402 - duplicate username? - 2012-08-09 02:14:14 - closed
```
DBIx::Class::ResultSet::find_or_create(): Query returned more than one row.  SQL that returns multiple rows is DEPRECATED for ->find and ->single at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Profile/User.pm line 49
```
#401 - quick tag edit page - 2012-10-29 09:38:02 - new
```
make a page with 
{{{
title
  tags
}}}

where tags is editable, then a save button, maybe hidden fields to say if tags have been changed on object or not
```
#400 - edit comment page missing reason box for admin edit - 2012-08-27 01:04:51 - closed
```
add it in
```
#399 - smiley leach protection - 2012-08-28 23:00:59 - closed
```
make it so
```
#398 - tinymce upgrade - 2012-08-10 01:48:51 - closed
```
tinymce on tan is well outdated, upgrade
```
#397 - mobile site - 2012-10-07 13:46:29 - closed
```
create mobile site
```
#396 - unmatched regex operator - 2012-08-08 06:40:49 - closed
```
Error:
Caught exception in TAN::Controller::View->type "Unmatched [ in regex; marked by <-- HERE in m/^piypu[ <-- HERE prn.comcture$/ at /var/www/thisaintnews.com/htdocs2/lib/TAN/Model/Object.pm line 44."
DBIx::Class::ResultSet::find(): No such relationship 'all' on Object at /var/www/thisaintnews.com/htdocs2/lib/TAN/Schema/ResultSet/Object.pm line 175



URL:
http://thisaintnews.com/view/piypu[prn.comcture/120037/Devastating-Earthquake-in-Australia--5-2-on-the-richter-scale--or-some-shit-like-that-

Referer:


Client IP:
90.244.232.97
```
#395 - triggers in db backup script - 2012-08-08 07:04:40 - closed
```
they're not there
```
#394 - use 5.014 - 2012-08-08 08:09:47 - closed
```
add this to TAN.pm get new features

change number matching regex to use /a modifyer
other changes
```
#393 - share this - 2013-04-15 15:42:08 - closed
```
button on things
```
#392 - update tan server - 2012-08-07 07:43:17 - closed
```
run do-release-upgrade
```
#391 - workers script - 2012-07-05 09:04:55 - closed
```
add cd /tmp into restart and start script
```
#390 - leach protection not workign in chrome - 2012-08-08 08:46:43 - closed
```
for some reason i can go straight to pics, http://thisaintnews.com/static/user/pics/1335398400/1335465180_Best-Craigslist-car-ad-of-all-time.jpg
```
#389 - new version of lucy - 2012-08-08 00:59:08 - closed
```
update lucyx::simple and reindex, see also #387
```
#388 - admin log page title - 2012-07-05 09:06:02 - closed
```
^
```
#387 - replace indexes with search - 2012-10-22 06:41:38 - new
```
depends on #371

make it so that the indexes are all searches

need to add score,comments,views,tin,tan etc to search index and related events

add rewrite rules for old /index/foo/bar/ urls

figure out a way of doing caching

benchmark search index load and mysql index load

figure out how to order by promoted date

nice if figured out how to search between dates & order by random
```
#386 - new smiley - 2012-08-08 08:35:44 - closed
```

http://thisaintnews.com/view/picture/114672/Jerk
```
#385 - js/css minifier - 2012-10-18 10:14:20 - closed
```
make it so the cached version url is like

/static/cache/$VERSION/(js|css)/filename

and then make sure old versions of cached files are removed.
```
#384 - change avatar location - 2012-10-19 10:44:47 - closed
```
put them in folders like the rewrite, username/upload_time and add a field to the user table in the db that contains the avatar filename. make sure on upload old avatars are removed.
```
#383 - 500 error - 2012-08-08 07:34:02 - closed
```
Error:
Caught exception in TAN::View::RSS->process "Can't locate object method "_promoted" via package "TAN::Model::MySQL::Comments" at /var/www/thisaintnews.com/htdocs2/lib/TAN/View/RSS.pm line 16."


URL:
http://thisaintnews.com/search/?page=2&amp;q=hubble&amp;rss=1

Referer:
http://thisaintnews.com/search/?page=2&q=hubble

Client IP:
203.0.223.244



```
#382 - replace profile links with search link - 2012-08-08 04:31:50 - new
```
eg comments to username:foo type:comments etc
```
#381 - submit broken on ipad.... probably - 2012-03-03 12:53:05 - closed
```
coz of tiny mce, so atleast for blog|forum. investigate
```
#380 - can't comment on ipad - 2012-03-03 09:53:28 - closed
```
coz the comment.js unload is only looking for iPhone|Android, not iPad
```
#379 - twitter hash tags - 2012-08-08 09:42:11 - closed
```
in twitter script, not sure how, maybe based on word lookup in tag db and hashtag the most popular word, exclude words like 'the' 'and' etc
```
#378 - quote link missing on new comment on ajax comment post - 2012-08-08 00:48:13 - closed
```
^
```
#377 - add vote count next to poll - 2012-10-16 08:46:48 - closed
```
see title
```
#376 - add votes column to poll table - 2012-10-07 12:46:23 - closed
```
and change object.score to be an int
```
#375 - search faq - 2012-03-03 12:17:12 - closed
```
write it
```
#374 - lotto - 2012-08-08 04:11:34 - assigned
```
make it
```
#373 - first 2 comments of new user show as comment #1 - 2012-08-08 08:05:44 - closed
```
see title
```
#372 - change server in backup sync script - 2012-01-28 11:33:24 - closed
```
from thisaintnews.pl to ftp.thisaintnews.pl

done on live, just not in svn
```
#371 - rss profile/comment and search - 2012-08-08 08:34:15 - closed
```
check it, make it work
```
#370 - ajax comment post missing hr - 2012-01-25 04:17:16 - closed
```
at top
```
#369 - new things not being added to search index - 2012-01-25 03:50:01 - closed
```
for some reason.
```
#368 - things that point to /search should point to /search/ - 2012-01-25 04:19:20 - closed
```
iirc it's only the tag links, but check
```
#367 - warning - 2012-01-25 04:20:58 - closed
```
Use of uninitialized value in concatenation (.) or string at /var/www/thisaintnews.com/htdocs2/root/templates/classic/view/video.tt line 7.
```
#366 - html::video::embed add youtu.be - 2012-01-19 04:19:55 - closed
```
youtu.be
```
#365 - number format on profile page - 2012-01-19 04:28:58 - closed
```
so it doesn't say things like 
 links: 302020202

instead it says

 links: 302,020,202
```
#364 - nsfw in page title - 2012-01-19 04:33:39 - closed
```
^
```
#363 - ip ban table - 2012-03-03 11:52:02 - closed
```
for deleted users
```
#362 - deleted images need to delete image - 2012-01-19 04:34:52 - closed
```
see title
```
#361 - object description looks indented - 2011-12-10 16:01:57 - closed
```
first line, add a margin-top or something to it
```
#360 - remove /var/log/* in backups? - 2011-12-05 21:07:56 - closed
```
experiment on markdev, see if the folder is emptied that the log files are remade and there's no errors
```
#359 - check old backup delete script is working(after february) - 2012-03-03 11:50:57 - closed
```
check there's no old files left over, and too much hasn't been deleted
```
#358 - 500 error - 2011-12-10 16:16:27 - closed
```
DBIx::Class::ResultSet::update_or_create(): DBI Exception: DBD::mysql::st execute failed: Deadlock found when trying to get lock; try restarting transaction [for Statement "INSERT INTO views ( created, ip, object_id, session_id, type, user_id) VALUES ( NOW(), ?, ?, ?, ?, ? )" with ParamValues: 0='99.224.236.112', 1="110828", 2='530df24660d537feef432c13f92c4ad81118dc6c', 3='external', 4=undef] at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Redirect.pm line 75
```
#357 - change scor column - 2011-12-10 16:43:20 - closed
```
change it from float to int or something
```
#356 - scripts - 2011-11-26 22:01:00 - closed
```
~~change sql backup script to use folderless format~~

~~change all backup scripts to use xv~~

~~check rsync to tan.pl script (error handleing)~~

~~backup sync script doesn't copy db backups~~

~~add /var/lib/varnish to backup exclude list~~

check/add tan.pl delete script

check backup delete scripts work properly

add script to delete old views from view table
```
#355 - deleted items still in search index - 2011-12-10 16:48:15 - closed
```
^
```
#354 - tag edit broken - 2011-11-26 22:37:13 - closed
```
i think it's a permissions problem
```
#353 - plus minus box - 2011-10-25 11:11:55 - closed
```
change to arrows up and down, show tins and tans again.

make fade on change.

make so can only tin or tan.
```
#352 - break view controller into sub components - 2011-10-04 02:07:07 - closed
```
make it not so big
```
#351 - change plus minus to show score - 2011-10-03 23:14:09 - closed
```
and not plus + minus
```
#350 - cms page content type and noeditor options - 2011-10-01 12:58:20 - closed
```
add them
```
#349 - sitemap content-type - 2011-10-01 07:43:19 - closed
```
it's being served as text/html when it should be application/xml
```
#348 - not updating score if new score < old score is dumb - 2011-10-01 06:33:00 - closed
```
coz tans don't work, comment deletions don't lower score. thinking about it, it was a very bad idea in the first place, since scores are organic, so fix

also change age penalty to 60 days instead of 50
```
#347 - css js multilevel include not working right - 2011-10-01 05:21:09 - closed
```
they're not getting the mtime for things like Submit@tags
```
#346 - input validation - 2011-10-01 05:01:34 - closed
```
Error:
Couldn't render template "profile/user/comments.tt: undef error - DBIx::Class::ResultSet::all(): A supplied offset attribute must be a non-negative integer at /var/www/thisaintnews.com/htdocs2/root/templates/classic/profile/user/comments.tt line 13
"

```
#345 - admins own edits appearing in admin log - 2011-10-01 06:52:12 - closed
```
they shouldn't
```
#344 - url encode submit tag thumbs - 2011-10-01 05:21:53 - closed
```
so people can do things like /b or 9/11. 

 /tagthumbs/anonymous%204chan%20/b//?noCach
```
#343 - cant edit profile - 2011-10-01 06:40:44 - closed
```
or change avatar, probably only works for admins, im guessing it's the role checkin code blocking normal users
```
#342 - deadlock when updating score - 2011-10-01 06:56:48 - closed
```
Error:
DBIx::Class::Relationship::CascadeActions::update(): DBI Exception: DBD::mysql::st execute failed: Deadlock found when trying to get lock; try restarting transaction [for Statement "UPDATE object SET score = ? WHERE ( object_id = ? )" with ParamValues: 0=1.220, 1='108193'] at /var/www/thisaintnews.com/htdocs2/lib/TAN/Schema/Result/Object.pm line 203

```
#341 - 500 error on delete all user content - 2011-10-01 06:28:43 - closed
```
something to do with the scoring system

Caught exception in TAN::Controller::View->update_score "Can't call method "object" on unblessed reference at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/View.pm line 37."


```
#340 - find undef value in cache in cms result - 2011-09-09 05:40:41 - closed
```
im pretty sure it's in the menu since it errors on every page
```
#339 - posted date on promoted objects - 2011-09-10 03:17:03 - closed
```
^
```
#338 - threaded comments - 2012-08-08 04:32:34 - new
```
make comments threaded

 * make quote button apply to active editor
 * quote should thread
 * how far should comments thread over?
```
#337 - don;t update score if new score < old score - 2011-09-09 05:21:07 - closed
```
^
```
#336 - cant edit polls - 2011-09-08 00:09:37 - closed
```
answers are missing
```
#335 - update score on comment delete - 2011-09-07 03:40:10 - closed
```
see title
```
#334 - pagination last page 404 - 2011-09-07 10:23:15 - closed
```
in more place than 1 the last page on the pager links to a 404 page. 
```
#333 - revisions - 2012-12-09 05:53:09 - closed
```
use the cms page style revisions on objects and comments, do away with the json shit in the admin log
```
#332 - stemmed tags - 2011-09-02 06:42:59 - closed
```
http://search.cpan.org/~creamyg/Lingua-Stem-Snowball-0.952/lib/Lingua/Stem/Snowball.pm
```
#331 - edit change types - 2011-09-10 06:37:06 - closed
```
^
```
#330 - page meta tages - 2011-09-02 05:16:12 - closed
```
http://www.paperstreet.com/blog/1341
```
#329 - uri encode url on remote image upload - 2011-08-30 02:50:17 - closed
```
^
```
#328 - tins and tans on profile - 2011-08-30 04:22:49 - closed
```
see title
```
#327 - uninitialized value warnings - 2011-08-30 03:46:29 - closed
```
Use of uninitialized value $tag in substitution (s///) at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Submit/Edit.pm line 192.

Use of uninitialized value in pattern match (m//) at /var/www/thisaintnews.com/htdocs2/lib/TAN.pm line 85.
```
#326 - undef value in cache - 2011-08-30 03:41:07 - closed
```
probably in cms

Use of uninitialized value in subroutine entry at (eval 389) line 15
```
#325 - subqueries - 2011-08-27 05:21:42 - closed
```
http://search.cpan.org/~abraxxa/DBIx-Class-0.08195/lib/DBIx/Class/Manual/Cookbook.pod#Subqueries
```
#324 - tags in page meta keywords - 2011-08-27 05:26:50 - closed
```
put the tags in the page meta keywords
```
#323 - nsfw blog/comment cache - 2011-08-27 04:48:42 - closed
```
~~make it so forums pages are cached the same way as blog pages.~~

then again, why do they even need to be cached different? nsfw is a cookie attr now, so surely the pages are the same, just on one the boob blocker runs. 

investigate
```
#322 - comments on nsfw threads showing in profile with filter on - 2011-08-27 04:45:19 - closed
```
erm, see title?
```
#321 - avatars - 2011-08-27 04:56:16 - closed
```
remove ?m=timestamp, make a rewrite rule instead, proxy servers aint caching
```
#320 - page width - 2011-08-23 09:17:20 - closed
```
make less wide
```
#319 - sns-structcadtech robots.txt - 2011-08-24 12:29:39 - closed
```
robots.txt
```
#318 - cms - 2011-08-30 03:39:45 - closed
```
make a cms system
```
#317 - xml error - 2011-08-27 03:45:10 - closed
```
on submit comment with a video
```
#316 - link doesn't work - 2011-08-07 11:07:11 - closed
```
this link should work: /view/video/104358/
```
#315 - xss recent comments - 2011-08-07 03:12:25 - closed
```
on preview you can insert things
```
#314 - nsfw image filter in forums - 2011-08-07 03:23:01 - closed
```
not working
```
#313 - forum section - 2011-07-31 08:27:39 - closed
```
make forum section
```
#312 - poll votes not showing - 2011-07-22 07:33:26 - closed
```
the % isnt showing
```
#311 - 500 error in rss - 2011-07-21 01:22:19 - closed
```
Error:
Caught exception in TAN::View::RSS->process "Can't locate object method "is_video" via package "TAN::View::TT" at /var/www/thisaintnews.com/htdocs2/lib/TAN/View/RSS.pm line 37."


URL:
http://thisaintnews.com/index/all/0/?rss=1

```
#310 - tempalate toolkit - 2011-07-21 01:13:47 - closed
```
convert templates to TT
```
#309 - edit lock - 2012-12-05 13:51:23 - closed
```
make it lock for edits after admin edits something

add link back to admin_log
```
#308 - profile pagination 404 error - 2011-07-21 07:24:44 - closed
```
http://thisaintnews.com/static/user/pics/1306368000/1306375881_New-Discovery-EdRoberts-Lives-Inside-TAN-Server.jpg
```
#307 - edit_object_nsfw role - 2011-04-10 03:07:06 - closed
```
allow edit nsfw and picture_id only
```
#306 - logger frontend - 2011-04-10 22:59:02 - closed
```
make a frontend for it
```
#305 - error 410 - 2011-04-09 00:50:31 - closed
```
simply error page template
make 410 gone error
return this error for a deleted object view
```
#304 - add url method to user - 2011-04-04 00:00:09 - closed
```
url for users profile
```
#303 - rename css/js files - 2012-10-18 10:14:20 - closed
```
so they match controller/template names
```
#302 - code cleaning - 2011-03-30 03:37:42 - closed
```
lots of times there's references to $location, which should be $type

so it's $object->type and not $object->location, which is dumb

also there's eval's dotted around for this kind of thing find and remove

find and fix
```
#301 - bookmarklet for images - 2011-03-30 02:59:46 - closed
```
update it

document.contentType
[http://en.wikipedia.org/wiki/Internet_media_type#Type_image]
```
#300 - chat in own window - 2011-03-30 02:40:08 - closed
```
why it no work anymore
```
#299 - object thumbs not centred - 2011-03-30 01:47:08 - closed
```
change css to match > a >
```
#298 - meta description is wrong on all pages - 2011-03-30 02:06:52 - closed
```
says social news for internet pirates :/
```
#297 - add no error for bookmarklet - 2011-03-30 02:12:52 - closed
```
created bookmarklet, make it show no error, other than repost error
```
#296 - add <a> around object thumb picture - 2011-03-20 22:40:56 - closed
```
so can click and see picture in full
```
#295 - link/blog/poll picture relation ship called "image" - 2011-03-20 21:28:05 - closed
```
wtf is the consistancy?
```
#294 - report - 2012-08-08 04:11:34 - new
```
users can report things
 * objects
 * comments
 * users
 * admins

reports can be read but not deleted
```
#293 - object delete - 2011-03-27 20:34:10 - closed
```
 * add object delete via flag in db
 * enable only for user role delete_object
```
#292 - access denied page - 2011-04-02 21:44:48 - closed
```
make an access denied page
```
#291 - new smiley - 2011-03-17 03:52:54 - closed
```
http://thisaintnews.com/view/picture/100652/mohammed-trollface
```
#290 - add db tables etc - 2011-03-12 01:36:32 - closed
```
many_to_many 

user => user_admin => admin
```
#289 - contact user - 2012-10-29 10:37:31 - closed
```
make it so admins can contact user
```
#288 - admin levels - 2011-04-10 15:51:59 - closed
```
 * ~~edit_object~~
 * ~~delete_object~~
 * ~~edit_user~~
 * ~~delete_user~~
 * ~~edit_comment~~
 * ~~admin_user~~
 * god
```
#287 - fullscreen youtube videos - 2011-03-27 20:59:51 - closed
```
enable it
```
#286 - index nwo trackerings - 2011-03-08 01:21:57 - closed
```
record index views so nwo tracker is more accurate
```
#285 - recent comments using wrong index - 2011-03-11 22:34:47 - closed
```
needs an index hint
```
#284 - deadlock - 2011-03-07 23:03:54 - closed
```
mark@tan:~$ [error] Caught exception in engine "DBIx::Class::ResultSet::update_or_create(): DBI Exception: DBD::mysql::st execute failed: Deadlock found when trying to get lock; try restarting transaction [for Statement "INSERT INTO views ( created, ip, object_id, session_id, type, user_id) VALUES ( NOW(), ?, ?, ?, ?, ? )" with ParamValues: 0='38.113.234.181', 1='100408', 2='d66cd57af4bb8ac6211ea379c0eeac7379be6169', 3='internal', 4=undef] at /var/www/thisaintnews.com/htdocs2/lib/TAN.pm line 58"

http://stackoverflow.com/questions/2596005/working-around-mysql-error-deadlock-found-when-trying-to-get-lock-try-restartin
```
#283 - convert db to innodb - 2011-03-07 03:01:23 - closed
```
 * convert to innodb
 * tune mysql config
 * flatten data {object => [view, plus, minus, comments], poll_answers => [votes]}
 * triggers
 * foreign keys
 * backup script
```
#282 - twitter worker bombed out - 2011-02-27 16:52:45 - closed
```
something about duplicate status, add eval around submit stuff
```
#281 - nsfw filter making images bigger - 2011-02-27 20:01:28 - closed
```
its not right

[http://thisaintnews.com/view/link/100046/CodeCogs---Online-LaTeX-Equation-Editor#comment233053]
```
#280 - poll title is a url - 2011-02-27 16:16:28 - closed
```
it tries to go to the external redirect /pollid url :/
```
#279 - gearman - 2011-02-26 18:17:32 - closed
```
do it
```
#278 - picture edit caching - 2011-02-23 18:32:01 - closed
```
(index) cache isnt being invalidated after edit
```
#277 - submit description nl2br - 2011-02-23 19:01:35 - closed
```
see title
```
#276 - Lucy - 2012-01-19 09:00:54 - closed
```
upgrade to Lucy
```
#275 - 500 error no such column plus - 2011-02-24 21:17:26 - closed
```
DBIx::Class::Row::get_column(): No such column 'plus' at /var/www/thisaintnews.com/htdocs2/lib/TAN/View/Template/Classic/Lib/PlusMinus.pm line 12

DBIx::Class::Row::get_column(): No such column 'comments' at /var/www/thisaintnews.com/htdocs2/lib/TAN/View/Template/Classic/Lib/Object.pm line 53
```
#274 - 500 error showing monkey not borris - 2011-02-20 12:55:55 - closed
```
fix it
```
#273 - blank submissions - 2011-02-19 01:46:02 - closed
```
dickheads just putting in spaces
```
#272 - are views being recorded for none logged in users - 2011-02-19 21:36:04 - closed
```
varnish + page cache = no tan. page views not being recorded (potentially) investigate
```
#271 - fail2ban - 2011-02-27 20:39:03 - closed
```
ssh fail2ban
```
#270 - top ad - 2011-02-15 20:45:24 - closed
```
remove the bottom one
```
#269 - rss content-type is wrong - 2011-02-15 20:05:44 - closed
```
change it to be application/xml
```
#268 - sumbit is slow - 2011-02-20 15:11:19 - closed
```
see why
```
#267 - project wonderful - 2011-02-17 00:10:29 - closed
```
make it load in a Asset?
```
#266 - twitter - 2011-02-23 00:25:06 - closed
```
make on promotion event that submits to twitter
```
#265 - dupliate profile for user - 2011-02-14 22:53:36 - closed
```
DBIx::Class::ResultSet::find_or_create(): Query returned more than one row.  SQL that returns multiple rows is DEPRECATED for ->find and ->single at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Profile.pm line 66
```
#264 - Use of uninitialized value in subroutine entry at (eval 466) line 15. - 2011-02-19 23:57:36 - closed
```
this url causes the above

http://thisaintnews.com/view/picture/93335/SFFFFFFxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
#263 - add index to robots.txt - 2011-02-14 22:01:10 - closed
```
there's no need for google to index the index, they have the sitemaps
```
#262 - reddit nsfw - 2011-02-16 22:48:43 - closed
```
for some reason the images aint showing, check the referrer and update the leech protector accordingly
```
#261 - remove 'no Moose' - 2011-02-14 19:26:04 - closed
```
stops strict working, remove it
```
#260 - you muppet - test after enabling strict! - 2011-02-14 19:08:22 - closed
```
broken 1.6.1 by not even restarting devbox. fix strict errors. p.s. shame on you
```
#259 - submit modules not using strict - 2011-02-14 18:47:01 - closed
```
they unload Moose, which also unloads strict + warnings. remove Moose unloading
```
#258 - thumb controller try{} around resize - 2011-02-14 18:46:20 - closed
```
resize has been updated to throw an exception on failure, and they aint being caught!
```
#257 - image upload failed no image file but added to db - 2011-02-14 18:42:39 - closed
```
caused a flood of 500 errors
```
#256 - floor week for image thumbs - 2011-02-14 18:42:39 - closed
```
1297296000.05847 is wrong
```
#255 - motools convert $ to document.id - 2011-02-14 21:40:02 - closed
```
should be pretty easy
```
#254 - remove video detection from templates - 2011-05-18 06:13:36 - closed
```
currently the template does video detection, this will be done at submit time now. remove it
```
#253 - edit link submit validators to return type => video - 2011-05-18 06:13:23 - closed
```
make it so that video use's the link submit schema + validators but it returns the correct type
```
#252 - convert existing links to videos - 2011-05-18 06:13:11 - closed
```
write script to go through current links and convert to video
```
#251 - create video table - 2011-05-18 06:12:55 - closed
```
create table and db schema and add relationships to object
```
#250 - 500 error for none numeric page no - 2011-02-13 22:35:09 - closed
```
getting 500 from google for urls like

URL:
http://thisaintnews.com/index/all/1/?page=avqcaopjlpu

Error:
DBIx::Class::ResultSet::pager(): Can't create pager for non-paged rs at /var/www/thisaintnews.com/htdocs2/lib/TAN/Schema/ResultSet/Object.pm line 132
```
#249 - validate thumb - 2011-02-13 22:20:31 - closed
```
make sure tag thumbs is validated
```
#248 - convert search model to use catalyst model factory perrequest - 2011-02-13 20:57:57 - closed
```
coz it doesnt like being a long lived module
```
#247 - resize problem - 2011-02-14 20:22:51 - closed
```
one of these files (govenator) doesn't resize correctly 
```
#246 - make images scalable - 2011-09-01 07:04:13 - closed
```
 * maybe store in db
 * set image domain for future proofing (static server)
 * flock thumb generation
```
#245 - menu click too fast - 2011-02-14 21:44:42 - closed
```
change it so if you click it too fast, it just goes to upcoming that section
```
#244 - picture desccription - 2011-01-11 01:01:42 - closed
```
make it optional
```
#243 - write tests for model::image - 2012-09-26 05:25:51 - closed
```
there's a lot of code in there, and not a single test!
```
#242 - fix avatar upload page - 2011-01-03 20:45:43 - closed
```
its broken coz of the new submit stuff.

depends on #241
```
#241 - update model('thumb') to use exception::simple - 2011-01-09 18:02:33 - closed
```
make it work damnit! returning 'error' is just not acceptable. not now, not never
```
#240 - mootols 1.3 - 2011-01-03 20:41:44 - closed
```
check all js for mootools 1.3 incompatibilities
```
#239 - change namespace for submit templates - 2011-01-03 03:37:03 - closed
```
they're in ::Submit::Type:: and should just be in ::Submit::
```
#238 - smilies - 2011-02-14 20:10:36 - closed
```
http://i122.photobucket.com/albums/o241/Trouble1st/emotes/ComputerSmash-1.gif

http://i122.photobucket.com/albums/o241/Trouble1st/emotes/aintsaying.png

http://i122.photobucket.com/albums/o241/Trouble1st/emotes/computernerd.gif

http://www.babyandbump.com/images/smilies/ignore.gif
```
#237 - allow class on a elements - 2011-01-10 20:09:41 - closed
```
make it so
```
#236 - auto comment refresh - 2012-10-29 10:38:30 - closed
```
make view page poll for new comments
```
#235 - edit - 2011-02-13 21:30:15 - closed
```
make edit work with new submit system
```
#234 - flash params on fail - 2011-02-09 01:12:47 - closed
```
save params, load them in template
```
#233 - nsfw - 2011-01-02 01:54:08 - closed
```
enable nsfw for everything.

code should mostly be in place, needs checkbox in template
```
#232 - javascript - 2011-02-08 18:59:05 - closed
```
make client side js

 * ajax submit?
 * validation
 * rework tag browser
```
#231 - poll sumbit - 2011-01-02 01:46:30 - closed
```
make submit work
```
#230 - http 303 - 2011-02-14 22:01:10 - closed
```
redirect with 303 after post
```
#229 - kinosearchx::simple improvements - 2010-12-01 21:34:04 - closed
```
fix update_or_create failing to delete 

make entries per page an option to search
```
#228 - release KinoSearch::Simple - 2010-12-01 21:33:50 - closed
```
convert it to use KinoSearch1 and be called KinoSearchX. Release on cpan and github.

make tan work with new KinoSearchX module, install from cpan on live site.
```
#227 - make editor grow - 2010-11-22 22:17:52 - closed
```
make it grow when ppl type things
```
#226 - delay ad loading - 2010-11-21 23:15:05 - closed
```
put them in a onload event wrapper
```
#225 - disable tinymce for incomptable broswers - 2010-11-21 22:08:18 - closed
```
iphone and android
```
#224 - delete comment code is broken - 2010-11-21 21:40:26 - closed
```
doesn't let you delete if you don't have a js enabled browser
```
#223 - fetcher should use File::Temp - 2010-11-12 23:19:26 - closed
```
save to a File::Temp and return it instead of requiring a save_to param
```
#222 - project wonderful - 2010-11-04 23:12:37 - closed
```
change ads to project wonderful
```
#221 - remove google - 2010-11-04 23:12:40 - closed
```
ads and analytics
```
#220 - nsfw filter is mashin image sizes - 2010-11-21 17:07:29 - closed
```
http://thisaintnews.com/view/blog/94016/Special-Report--Rally-Against-The-Cuts#
```
#219 - remove ads on nsfw stuff - 2010-11-02 02:15:40 - closed
```
google done bitched, so fix it so theres no ads on indexes with the nsfw filter off, and no ads on nsfw content.

perhaps enable nsfw options on other objects, should be relatively simple
```
#218 - user messaging - 2012-10-29 10:37:51 - new
```
we should be able to pm each other, although with the option to ignore pm's or something i dunno
```
#217 - auto rotate images - 2010-11-18 19:49:04 - closed
```
  -auto-orient         automagically orient (rotate) image
```
#216 - new smiley - 2010-11-13 23:01:26 - closed
```
http://www.homebrewtalk.com/images/smilies/occasion14.gif
```
#215 - favourite button - 2012-08-08 04:11:34 - new
```
add a favourite button so people can bookmark stuff or w/e
```
#214 - pingback, trackback - 2012-09-24 14:53:19 - closed
```
add them, maybe just pingback, but do both is possible

 [http://search.cpan.org/~rjray/RPC-XML-0.73/lib/RPC/XML.pm]
 [http://search.cpan.org/~tima/Net-Trackback-1.01/lib/Net/Trackback.pm]
```
#213 - move videos to own place - 2011-02-13 23:36:39 - closed
```
write script to move links to videos keep object_id.

dunno how submit should work coz its really just the same as a link
```
#212 - create module system - 2011-02-13 22:20:31 - closed
```
something jsony that defines how tan works, so that submit, view, random, menu, profile etc function automated(ish).

make appropriate code function as independent as possible for rapid future feature addition.
```
#211 - who's online - 2010-08-30 21:45:24 - closed
```
select distinct(user.username) from views join user on (views.user_id = user.user_id) where created > date_sub(now(), interval 5 minute)

should cut it
```
#210 - profiles - 2010-10-17 18:48:14 - closed
```
polls are missing from user page

make index page of all users, sorted by something or other, dunno

add messaging
```
#209 - backup rotation - 2011-03-10 22:32:38 - closed
```
make script to delete old backups so all hdd space doesnt get eaten 
```
#208 - strip uploaded images - 2010-09-05 22:18:47 - closed
```
as long as they're not animated
```
#207 - google analytics - 2010-08-21 17:39:19 - closed
```
functiono
```
#206 - add votes to poll object comment bar thingy - 2010-08-20 02:41:44 - closed
```
erm ^
```
#205 - change poll colour - 2010-08-20 02:30:16 - closed
```
make it royal blue #002366
```
#204 - paginate tag thumbs submit - 2010-08-11 17:13:30 - closed
```
paginate em
```
#203 - poll edit caching - 2011-02-20 15:13:14 - closed
```
edit an answer, it shows the edit on the view page, on the edit page though its the old answer still :\
```
#202 - stop using date_ago - 2010-08-20 02:28:05 - closed
```
replace it with w/e it is that does it for the poll count down, although it might be a lil long. either way figure it oot
```
#201 - perl templating system - 2010-08-22 19:19:32 - closed
```
convert templates

 * ~~chat~~[1329]
 * ~~faq~~[1329]
 * ~~index~~[1326]
 * ~~lib~~[1326-1328]
 * ~~login~~[1332:1333]
 * ~~profile~~[1334]
 * ~~search~~[1330:1331]
 * ~~submit~~[1332]
 * ~~tag~~[1330:1331]
 * ~~view~~[1327:1328]
```
#200 - search select page broken - 2010-08-05 01:43:35 - closed
```
it just stays on page 1
```
#199 - comedy central [video] - 2011-03-27 21:45:19 - closed
```
http://www.comedycentral.com/videos/index.jhtml?videoId=147895&title=nixons-back
```
#198 - comment count - 2010-08-05 01:43:16 - closed
```
its weird, for first comment says #2, and also counts deleted comments
```
#197 - clean code - 2010-08-23 00:51:39 - closed
```
move logic from controllers to models where applicable
```
#196 - edit tagthumbs - 2010-08-29 02:55:21 - closed
```
it seems broken, too many tags and duplicates
```
#195 - moose convert catalyst::plugin::event - 2010-07-26 03:34:59 - closed
```
there's one varible should be an accessor, accessor already created
```
#194 - clean code - 2011-02-13 23:54:10 - closed
```
view controller and submit controller contain a lot of logic that should be in a model.

refactor
```
#193 - common regex - 2010-09-05 22:07:54 - closed
```
split common used regex into own model
```
#192 - avatar uploader help - 2010-07-26 03:40:06 - closed
```
theres no info on the crop avatar page, its really confusing to n00bs
```
#191 - trim tags - 2010-07-26 03:21:41 - closed
```
remove extra whitespace
```
#190 - convert kinosearch::tan into kinosearch::simple - 2010-07-11 01:14:40 - closed
```
convert it, make it more generic and pluggable
```
#189 - spawn hooks into events plugin/dispatch type - 2010-07-08 22:32:44 - closed
```
which ever one is better is the bets one
```
#188 - change hooks - 2010-07-08 22:34:13 - closed
```
change them to use a sub ref instead of a forward call. log for debug
```
#187 - stash submit stuff - 2010-07-09 01:53:07 - closed
```
flash it on failure so don't has to retype it all
```
#186 - switch to google ads - 2010-07-05 21:52:34 - closed
```
they're better than adjug, only 3 per page though
```
#185 - namespace::autoclean - 2011-02-13 23:33:42 - closed
```
use this in all modules
```
#184 - add kontraband video support - 2010-07-11 18:11:28 - closed
```
add support for the following video site

[http://www.kontraband.com/videos/23216/Americas-Path-To-Socialism/]
```
#183 - menu bug - 2010-07-04 00:06:22 - closed
```
when you click location then come back to current without changing upcoming, current upcoming isnt highligted
```
#182 - page titles - 2010-07-04 02:59:55 - closed
```
lots of pages don't have titles, fix it yo
```
#181 - plus_minus - 2010-07-04 15:06:28 - closed
```
fix it 

if you +/- thenopen thing and +/- it works backwards
```
#180 - new tiny mce - 2010-06-28 01:02:02 - closed
```
upgrade from 3.2.7 to 3.3.7 [http://tinymce.moxiecode.com/js/tinymce/changelog.txt]


[https://sourceforge.net/projects/tinymce/files/TinyMCE/3.3.7/tinymce_3_3_7.zip/download]




```
#179 - stike-through doesn't work - 2010-06-24 15:06:36 - closed
```
the html filter is clobbering it
```
#178 - add animated gif detection - 2010-06-22 22:09:28 - closed
```
''convert -identify animated.gif /dev/null''

should do it
```
#177 - search - 2010-07-07 00:00:42 - closed
```
lucene search engine thingy

http://lucene.apache.org/
```
#176 - clear  index caches - 2010-07-12 02:52:38 - closed
```
use hooks #174
```
#175 - check user saved comment - 2010-06-28 01:33:41 - closed
```
sometimes it throws a 500 error, improve it so it doesn't
```
#174 - hooks - 2010-06-27 15:45:29 - closed
```
add hooks for

 * object->submit
 * object->edit
 * object->plus_minus
 * ????
 * profit

use hooks to clear caches, have them hook in at compile time
```
#173 - polls - 2010-08-01 17:47:39 - closed
```
perhaps polls would be good

todo:
 * ~~json mode~~[1304]
 * ~~submit add more answers js~~[1301]
 * ~~submit validation js/backend~~[1302:1303]
 * ~~optimisation/cacheing~~[1307]
 * ~~end in ''x'' days~~[1305]
 * ~~edit~~[1308]
 * ~~clear caches etc~~
 * ~~test logic~~
 * ~~test security~~
```
#172 - clean code - 2010-07-04 16:28:10 - closed
```
improve tagthumbs.pm, its not nice.

refactor index.pm to use profile style index template
```
#171 - animated gifs on preview page - 2010-06-21 18:35:16 - closed
```
hack it so it shows the original image for size 600.
```
#170 - google video broken - 2010-06-20 20:09:22 - closed
```
for 
http://video.google.com/videoplay?docid=-678466363224520614

```
#169 - add domain to links + extrernal views - 2010-06-19 00:58:35 - closed
```
see title
```
#168 - nsfw image filter - 2010-06-18 15:26:19 - closed
```
isnt functioning on blogs, make it fixed
```
#167 - Parse::BBCode updated, remove local copy - 2010-06-15 19:23:42 - closed
```
Its been updated, no longer any need to have a local modified copy
```
#166 - cache blog - 2010-06-18 14:43:48 - closed
```
blog aint cached, do it like comments
```
#165 - add profile page - 2010-06-14 22:29:10 - closed
```
add in profiles
```
#164 - entity encoding in tinymce breaking chrome - 2010-06-14 16:45:13 - closed
```
change entity_encoding to numeric in tinymce config
```
#163 - tag thumbs - 2010-06-17 23:59:03 - closed
```
some are coming up with '''0''' as the id. remove them
```
#162 - add megavideo embed - 2010-06-13 19:37:08 - closed
```
http://www.megavideo.com/?v=37ZFO2UR

<object width="640" height="418"><param name="movie" value="http://www.megavideo.com/v/37ZFO2URf1d88b806d04aefb182f1348b3988510"></param><param name="allowFullScreen" value="true"></param><embed src="http://www.megavideo.com/v/37ZFO2URf1d88b806d04aefb182f1348b3988510" type="application/x-shockwave-flash" allowfullscreen="true" width="640" height="418"></embed></object>
```
#161 - move all system script in project - 2011-02-27 20:22:49 - closed
```
all system scripts backups, sitemap, tor blocker, etc to be moved in project
```
#160 - update faq - 2010-06-21 15:50:44 - closed
```
 * add a bit about avatars must be sfw.
 * update NSFW text to link to http://en.wikipedia.org/wiki/Not_safe_for_work
 * add a bit about how to connect to irc via chatzilla/mirc

```
#159 - order by - 2010-06-13 14:38:58 - closed
```
when changing the order to idnews etc, it orders by oldest first.
```
#158 - change doc type to transitional - 2010-06-13 14:27:16 - closed
```
due to &nbsp; not being valid in xhtml strict
```
#157 - db backup script - 2010-06-13 14:53:57 - closed
```
syntax error at /etc/cron.daily/tan_backup line 143, near "1) "
```
#156 - general errors - 2010-06-13 14:32:01 - closed
```
Use of uninitialized value $source in pattern match (m//) at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Redirect.pm line 43.

Use of uninitialized value $source in pattern match (m//) at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Redirect.pm line 56.

Use of uninitialized value $pic_time in modulus (%) at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Redirect.pm line 59.

Use of uninitialized value $filename in concatenation (.) or string at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Redirect.pm line 61

----

Use of uninitialized value in division (/) at /var/www/thisaintnews.com/htdocs2/lib/TAN/Model/Thumb.pm line 64.

Use of uninitialized value in division (/) at /var/www/thisaintnews.com/htdocs2/lib/TAN/Model/Thumb.pm line 64.

[error] Caught exception in TAN::Controller::Thumb->resize "Illegal division by zero at /var/www/thisaintnews.com/htdocs2/lib/TAN/Model/Thumb.pm line 64."



```
#155 - urls in comments can't be over 100 chars long - 2010-06-12 19:36:10 - closed
```
fix it, provide a new filter, use Data::Validate::URI
```
#154 - add vimeo video support - 2010-06-12 20:55:29 - closed
```
http://vimeo.com/12429821

<object width="400" height="225"><param name="allowfullscreen" value="true" /><param name="allowscriptaccess" value="always" /><param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=12429821&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" /><embed src="http://vimeo.com/moogaloop.swf?clip_id=12429821&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="400" height="225"></embed></object><p><a href="http://vimeo.com/12429821">Israeli Attack on the Mavi Marmara, May 31st 2010 // 15 min.</a> from <a href="http://vimeo.com/culturesofresist">Cultures of Resistance</a> on <a href="http://vimeo.com">Vimeo</a>.</p>
```
#153 - nsfw filter doesnt stay off - 2010-06-12 15:40:28 - closed
```
the cookie its in is a session cookie, make it last longer.
```
#152 - make a faq - 2010-06-11 03:43:27 - closed
```
make a faq
```
#151 - banned users - 2010-06-10 19:04:11 - closed
```
make sure they can't log in
```
#150 - move irc - 2010-06-09 18:35:30 - closed
```
its now irc.mibbit.com
```
#149 - header wrong in safari - 2010-06-09 17:56:09 - closed
```
its all over the show
```
#148 - rework old images redirect - 2010-06-10 22:03:02 - closed
```
for thumbs and for image files coz they're moved.

perhaps make leech proofer work more better with old images/thumbs
```
#147 - DBIx::Class::UTF8Columns is deprecated - 2010-06-06 17:16:37 - closed
```
http://search.cpan.org/~frew/DBIx-Class-0.08122/lib/DBIx/Class/UTF8Columns.pm

remove it and replace with ''mysql_enable_utf8'' connect flag
```
#146 - sitemap - 2010-07-01 20:36:01 - closed
```
remake sitemap generator
```
#145 - username is missing from pic on index - 2010-06-05 01:45:34 - closed
```
theres no username, but there is a avatar
```
#144 - page cache fucks up with utf8 data - 2010-06-05 01:40:58 - closed
```
damn it to hell!!!!
```
#143 - [video] bbcode - 2010-06-05 01:51:22 - closed
```
make it accept a hyperlink as well as plaintext url. i.e. make it tard proof :p
```
#142 - fix render die - 2010-06-05 21:14:18 - closed
```
they've changed the way it works, need to remove the renderclass end function and trap the exception and some other shit.

[http://search.cpan.org/~bobtfish/Catalyst-View-TT-0.34/lib/Catalyst/View/TT.pm#render%28$c,_$template,_\%args%29]

[http://search.cpan.org/~abw/Template-Toolkit-2.22/lib/Template/Exception.pm]
```
#141 - add sha512 for pictures - 2010-06-05 01:47:23 - closed
```
update convert script, add new field in db. update submit controller and redirect to pic if sha512 matches.
```
#140 - convert script - 2010-06-04 00:04:20 - closed
```
make it move images into a sub dir % time shit or something.

make old/new avatar, and old/new image dir env varible
```
#139 - remove links to user profile - 2010-06-02 02:46:36 - closed
```
since it doesn't exist yet
```
#138 - make convert script ordered - 2010-06-01 21:09:34 - closed
```
its not pulling records out in any order and it could be causing some missing pictures. fix
```
#137 - .htaccess - 2010-06-01 22:10:53 - closed
```
add .htaccess
```
#136 - image redirect - 2010-06-02 02:34:46 - closed
```
make anti-leech controller
```
#135 - seo confirm shizzle - 2010-05-31 10:19:10 - closed
```
add the confirm stuff for the search engines.
```
#134 - old article redirect - 2010-05-31 17:33:08 - closed
```
create controller for redirecting old articles to the new ones. 301 or w/e is best, i forget.
```
#133 - check all code - 2010-06-21 15:34:52 - closed
```
see what can be speeded up, refined, refactored etc etc
```
#132 - move registration into sub of login - 2010-05-26 23:59:14 - closed
```
move it from Login.pm to login/Registration.pm
```
#131 - create new js alert popup overlay thing - 2010-05-22 02:26:45 - closed
```
make it real simple like - but real obvious
```
#130 - forgot mail controller - 2010-05-26 23:17:28 - closed
```
make a password reset controller
```
#129 - up upload limit - 2010-05-27 01:05:13 - closed
```
3-4mb should do
```
#128 - sort by - 2010-05-02 17:43:57 - closed
```
make sort by bar ?order=
```
#127 - videos - 2010-05-03 00:28:02 - closed
```
live site supports more than just youtube links, upgrade new tan

possibly add new bbcode [video] tag (maybe not if timewise)
```
#126 - sql indexes - 2010-06-07 17:39:27 - closed
```
nothing is indexed

index as much as possible, like sort by, page numbers, comments, tin tans.

bassically just figure it all out
```
#125 - nsfw safe random image search - 2010-04-08 20:40:18 - closed
```
make it respect nsfw settings
```
#124 - picture bar - 2010-07-03 01:42:02 - closed
```
add the picture bar back
```
#123 - nsfw filter - 2010-04-10 00:36:45 - closed
```
update it to ignore the new smileys
```
#122 - thumb images look wrong - 2010-04-06 22:14:16 - closed
```
they dont look right, detect if image is a gif or not and convert accordingly
```
#121 - back to main - 2010-07-03 01:42:10 - closed
```
add bac kto main link somewhere
```
#120 - embedded videos - 2010-05-03 00:13:21 - closed
```
make more things embed with generic [video] bbcode
```
#119 - tin/tan comments - 2010-07-03 01:41:46 - closed
```
comments tin/tan
```
#118 - add notifaction area - 2010-03-29 22:38:38 - closed
```
use something existing
```
#117 - javascript - 2010-04-04 14:53:49 - closed
```
TAN class, add proper logger alert thingy, and a confirm thingy for somethign, i forget what, im tired but pretty sure its needed
```
#116 - add stats link - 2010-03-29 23:11:15 - closed
```
add link to stats
```
#115 - donation button - 2010-03-29 23:15:12 - closed
```
add donation button
```
#114 - css min thing - 2010-05-02 17:27:41 - closed
```
like whats there for the js
```
#113 - comments need more user info - 2010-04-03 20:46:16 - closed
```
like
 * comment number (figure this out)
 * joined etc
```
#112 - recent comments are xss'able - 2010-03-14 23:49:29 - closed
```
if you make a comment of <a href="blah blah" /> it will be a link in the preview. although, should the preview not be the actual comment?
```
#111 - promotion system - 2010-04-05 00:55:37 - closed
```
currently things don't get promoted
```
#110 - commenting broken - 2010-03-05 00:06:08 - closed
```
it reports it was made 40 days ago when posting via ajax
```
#109 - tags - 2010-06-21 19:38:15 - closed
```
make a tags index page
```
#108 - redirect controller - 2010-06-01 18:52:19 - closed
```
make redirect controller
```
#107 - XSS protection - 2010-03-16 23:15:47 - closed
```
currently the comments page is XSS vunerable

use HTML::StripScripts::Parser ( http://tinymce.moxiecode.com/punbb/viewtopic.php?id=6495 )


```
#106 - BBCode - 2010-01-05 01:00:34 - closed
```
Use Parse::BBCode to build a new BBCode module

blocks #42
```
#105 - ubuntu server - 2010-04-09 20:57:58 - closed
```
coz of the ubuntu on the live server, make a new dev box based on ubuntu, possibly from a backup of the live one
```
#104 - pod - 2010-01-01 17:39:13 - closed
```
write pod
```
#103 - user registration - 2010-05-19 00:28:39 - closed
```
rewrite the user registration stuff.
```
#102 - create image validator - 2009-12-17 00:05:04 - closed
```
 * blocks #38
 * Data::Validate::Image
 * use Image::Info
 * tests


```
#101 - fix db schema - 2009-12-07 08:48:46 - closed
```
old_lookup needs a type

plus_minus is mia
```
#100 - image caching - 2009-11-18 23:43:18 - closed
```
group it by `id - (id % 1000)`
```
#99 - images - 2009-10-25 18:05:33 - closed
```
make images go into a sub dir, split every 100 or so.
```
#98 - sitemap generator - 2009-10-25 18:16:11 - closed
```
update it
```
#97 - rate limit posting - 2012-08-08 04:11:34 - new
```
make some kind of anti flood protection
```
#96 - add rewrite rules for old urls - 2009-10-25 17:27:44 - closed
```
things like pictures, smileys, anything else?
```
#95 - change dispatcher to use strpos - 2009-10-11 15:26:18 - closed
```
add a key string to the map, then to the preg_match if the strpos matches, should be much faster
```
#94 - smarter js inclusion - 2009-10-11 03:07:26 - closed
```
 * make it automatically adjust the revison
 * make it minify and cache
 * make cherokee rule to handle if cache exists
```
#93 - remote image upload - 2009-12-27 14:42:34 - closed
```
seems to be letting me put a link to the html page in, then dying coz its not an image. I guess the error handling shit aint working too good...

this was the link it dowloaded - http://img476.imageshack.us/i/banhammer15gq9.jpg/
```
#92 - ougoing link tracker - 2010-02-28 18:12:59 - closed
```
make an outgoing link tracker, and display it on the object
```
#91 - photo albums - 2012-08-08 04:11:34 - new
```
photo albums, work just like indexes
```
#90 - logger - 2011-04-10 15:46:54 - closed
```
add open events logger
```
#89 - bulk content management - 2011-04-04 22:55:46 - closed
```
make all in one content management page
```
#88 - user management - 2011-04-10 02:36:19 - closed
```
add user management pages

 * ~~Delete Content~~
 * ~~Delete Avatar~~
 * ~~Delete~~

skipped

 * Change Username
 * Contact
```
#87 - rss feeds - 2010-08-22 16:14:00 - closed
```
everypage needs an rss feed
```
#86 - caching - 2010-06-07 15:44:59 - closed
```
cache as much as possible, also clear caches when needed
```
#85 - super cache - 2009-10-05 15:56:31 - closed
```
make a static html output cache for non-logged in users
```
#84 - error handler - 2010-01-02 18:52:32 - closed
```
write a proper error handling function

have it send emails to somekind of address (needs setting up)
```
#83 - tinymce - 2009-12-06 18:46:57 - closed
```
new fckeditor, ckeditor 3 - http://ckeditor.com/

 * reduce toolbar clutter when upgrade in progess
 * add some more smileys, including burger etc.
```
#82 - new htmlpurifier - 2009-10-22 18:27:03 - closed
```
upgrade to version 4 - http://htmlpurifier.org/
```
#81 - edit comment controller - 2010-04-04 21:05:55 - closed
```
make edit controller controller, should be simplish
```
#80 - chat controller - 2009-11-19 00:03:47 - closed
```
for none js users
```
#79 - random controller - 2009-11-30 00:14:24 - closed
```
make random controller
```
#78 - plus/minus - 2010-02-28 18:10:34 - closed
```
make plus minus controller and js
```
#77 - comments - 2010-02-28 18:11:48 - closed
```
comment system

make it post with ajax
```
#76 - nsfw filter - 2009-09-22 14:53:48 - closed
```
make nsfw filter
```
#75 - create f object - 2009-09-20 22:46:18 - closed
```
create it
```
#74 - dubstep - 2009-09-07 22:55:36 - closed
```

```
#73 - Carrot Cake - 2009-10-17 15:28:34 - closed
```
Refreshments

I'm thinking we should have more cakes, these meetings suck.


Also, fuck you
```
#72 - javascript - 2010-01-01 02:59:07 - closed
```
 * rewrite all the current javascript with moo.
 * remove all inline script, where possible
 * make comment posting work via ajax
```
#71 - Change database schema - 2009-11-15 00:02:48 - closed
```
 * make all things in the same table, requires some kind of old id field
 * write conversion tool
 * port existing code
 * add category support
```
#70 - categories - 2010-07-03 01:46:56 - closed
```
Tits and vag in some kind of hybrid Noodz" category, pages of tits actually put some people off

Links/Blogs/Pics/Wimminz should have a few categories.

'''''Links/Blogs'''''
 * Politics
 * Conflicts
 * WTF
 * Entertainment
 * Technology (more encompassing than internets)
....the less the better

'''''Pictures'''''
 * Noodz section

Try make it so they can change the category after they post it too, good chap. 
```
#69 - new indexes - 2009-09-07 22:53:05 - closed
```
create new index pages
```
#68 - tag_thumbs controller - 2009-12-31 22:43:16 - closed
```
blocks #38

submit tag thumb browser, make it paginated
```
#67 - youtube links should embed - 2009-08-07 22:12:14 - closed
```
use the bbcode code
```
#66 - page impressions - 2010-04-14 00:08:46 - closed
```
create a pi model and table, record as much as possible

 * date
 * page
 * ip
 * useragent
 * session id
 * user_id
 * url
```
#65 - animated gifs in thumbs - 2009-11-15 00:02:27 - closed
```
make animated thumbs work. 
```
#64 - removed nsfw ads - 2009-07-04 22:37:33 - closed
```
they're slow and look really really really spammy.
```
#63 - strip all uploaded images - 2009-07-04 21:24:24 - closed
```
run strip on them

http://www.php.net/manual/en/function.imagick-stripimage.php
```
#62 - hide nsfw images in comments - 2009-07-05 00:23:49 - closed
```
 * hide all images in comments if filter is off
 * dont  hide smileys, perhaps add a class to them?
```
#61 - fix image leaching - 2009-07-04 14:51:07 - closed
```
a lot of images are being leached, fix it with mod rewrite.
```
#60 - upgrade edit_comment - 2009-07-13 23:56:59 - closed
```
its kind of a bastard child at the moment, get it fixed.
```
#59 - fix youtube - 2009-08-23 20:15:30 - closed
```
youtube is broken, replace the html output of the bbcode. also add [video] bbcode
```
#58 - edit submissions - 2010-05-31 01:59:59 - closed
```
write it
```
#57 - edit comments - 2009-09-23 16:46:34 - closed
```
rewrite it to use new code design
```
#56 - avatar uploader - 2010-03-24 22:02:35 - closed
```
make it use the new code layout
```
#55 - image resizer - 2009-08-07 14:51:41 - closed
```
rewrite it to use the new code stuff (model, controller) etc
```
#54 - remove forums - 2009-06-18 22:38:44 - closed
```
kill them good.
```
#53 - change promotion system - 2011-09-07 01:32:30 - closed
```
make it maths, score based

unique views, comments, tins, tans
compare for the previous 2 days

perhaps use submission date?

dont put live yet, just scores only.

add system of page views, unique ip only, xforwarded_for, user_id, date, referer
```
#52 - picture description cutoff on submit - 2009-06-01 18:37:53 - closed
```
its because its named pdescription on pics
```
#51 - fix "Invalid multibyte sequence in argument" in recent comments - 2009-06-01 18:37:01 - closed
```
its annoying
```
#50 - tag model - 2009-12-28 02:32:15 - closed
```
create tests for tag model
```
#49 - reduce page load time - 2009-07-13 23:56:17 - closed
```
its mostly coz of the ads.
causing javascript loading to be delayed
perhaps wrap in a on domready event thingy.
```
#48 - ad thing for tom - 2009-05-24 18:35:40 - closed
```
make widgit thing


```
#47 - remote image upload - 2009-12-28 02:32:15 - closed
```
write tests
```
#46 - switch to lighttpd - 2009-08-23 20:15:59 - closed
```
its about 2x faster than apache, and can use aio for turbo sends.

http://www.cyberciti.biz/tips/howto-increase-lighttpd-performance-with-linux-aio.html
dev-libs/libaio

Will need to use the dispatcher for this to work properly, and safely. as a side effect, this will also mean switching to fastcgi
```
#45 - block tor - 2009-10-04 20:12:34 - closed
```
''you can obtain the list in plain txt format updated every 5 minutes from Tor Network Status sites located in

the US
http://torstatus.kgprog.com/ip_list_exit.php

or

the Old Europe
http://torstatus.blutmagie.de/ip_list_exit.php''

write a perl script
```
#44 - investigate moving all code to dispatcher - 2009-09-08 18:10:39 - closed
```
see if its easy or not.
```
#43 - add more ads - 2009-05-12 14:19:23 - closed
```
yep.
```
#42 - new article pages - 2010-02-28 18:10:14 - closed
```
tags on page

new controller that redirects to link

edit box for non logged in users => login/registration

other shit

```
#41 - sql clone_db_for_testing - 2009-01-28 00:31:30 - closed
```
part of #40 really, make a function that clones every table in the db.

create temporary table log_t like log;
alter table log_t rename log;
```
#40 - unit tests - 2009-05-04 23:12:56 - closed
```
Make unit tests for the models
```
#39 - new index pages - 2009-10-05 15:58:13 - closed
```
break up into MVC, include all menu option
```
#38 - new submit pages - 2010-01-01 17:38:14 - closed
```
the submissions pages need cleaning up and templating etc
```
#37 - new shit - 2009-05-06 21:18:56 - closed
```
Editing/Posting Comments:
This small thing Irks me. Whenever you post or edit a comment, it loads a completely new page just so you can edit it, then pressing submit loads a completely new page again, which completely loads a new page again until you can actually see your comment.

-To somehow implement a system (Kind of like Youtube profile comments) where it didn't take you out of the article and all the comments whenever you posted a comment or edited your comment.

-To have a standard hotbar above each comment or edit comment that you do that allows you to bold, italic, colorize etc your text. Not having this by now is shocking to say the least.

-Remove the comment rating system. I think in all my time on shoutwire, I've looked at this once and said "Wow this is un-necessary".

Submitting Articles:

One thing that really irks me as well is the amount of spam useless articles submitted everyday. I recently found that you have to enter the code in the image in order to submit. I've noticed a significant decrease in spam submissions. Good job.

General Suggestions:

This is purely for social value, but someone could simply invent a ranking system for SW users. It might be based on how long that user has been registered with SW.

Example, a guy who has been on SW for 2+ years might have a ranking of "Old Facker" or something. It might be worth looking into to improve the mood of SW.

-Changing the Name of "Promoted Blogs" to "Top 5 Blogs"

Well that's all I can think of for now, I'm sure there's more.

If anyone cares and agrees with me or not, feel free to comment.


http://shoutwire.com/ecomments/227362/E_Some_Suggestions_to_Improve_SW.html
```
#36 - create new cache model - 2008-12-30 22:03:02 - closed
```
basic interface to memcache
```
#35 - create basic object model - 2008-12-30 22:03:07 - closed
```
called
 m_object
needs several functions:

 * get_page_list
 * get_object_details
 * get_meplusminus

```
#34 - Add lightwindow - 2009-05-06 21:19:15 - closed
```
Add it for login/registration page, probably other stuff, but dunno what.
```
#33 - add comment box for non logged in users - 2009-05-06 21:19:15 - closed
```
Allow the comment box on the page for non logged in users, then mark the comment as hidden in the db (add column) and change upon login/registration.

 * add hidden, date_hidden columns to comments table
 * make hidden comments not show
 * add code to docomment.php
 * add registration complete comment code 
 * add cron job that deletes old hidden comments (+72 hours)

Sit back and relax!
```
#32 - backup trac - 2009-06-14 21:28:40 - closed
```
use rsync, its pretty easy
```
#31 - system upgrades - 2008-12-23 22:44:24 - closed
```
Upgrade the servers/desktops etc
```
#30 - install nagios - 2009-05-04 23:01:58 - closed
```
could do with being on all the servers since its enterprise class, maybe [ http://beginlinux.com/blog/2008/11/install-nagios-3-on-ubuntu-810/ this ] will be of use 
```
#29 - impliment object caching - 2009-05-06 21:19:15 - closed
```
depends on #27, #28

 * use [ http://uk3.php.net/memcache this ] and cache as much as possible
 * make content page cached untill more comments in the cache, use name scheme like {{{ {$type}{$id}{$comment_count} }}}
 * default cache time for 5 mins (perhaps more, test and find out)

```
#28 - add edit_time column to most table's - 2009-05-06 21:19:15 - closed
```
need a edit_time column to pretty much all the tables (all the ones that need it anyway).
```
#27 - install memcached - 2009-05-06 21:19:15 - closed
```
needs to be installed
```
#26 - move page order around - 2009-05-06 21:19:15 - closed
```
look at the site in links, its not nice, and thats what google sees! reorder.
```
#25 - etags - 2009-05-06 21:19:15 - closed
```
should be based on the file mtime and some other shit. md5 is slow
```
#24 - pagination - 2009-05-04 23:01:38 - closed
```
needs to only show +- 5 pages
```
#23 - log is fucked. - 2009-05-06 21:19:15 - closed
```
its not puttin comment_id in the db, and the link_id its putting in is wrong, so the others might be too.
```
#22 - fix titles in article page + add goto url - 2009-05-06 21:19:15 - closed
```
 * add url that redircts to the story
  * counts the view 
  * perhaps opens the page in some kind of frame

 * make the title in the article <h1> rather than a link back to the article
```
#21 - clamav + spamassisin for email - 2009-05-04 22:56:25 - closed
```
get it set up
```
#20 - email2trac - 2009-05-04 22:58:38 - closed
```
set this up, or something similar

https://subtrac.sara.nl/oss/email2trac
```
#19 - comments - 2009-05-06 21:19:15 - closed
```
when theres no comments and your not logged in it looks shit
```
#18 - add scriptaculous - 2009-05-06 21:19:15 - closed
```
will require .htaccess mod rewrite stuff + code/script.php changes
```
#17 - shells comp - 2008-11-24 20:19:53 - closed
```
'''
== fix shells comp! ==
'''
```
#16 - add phpdoc to trac - 2009-05-04 22:57:31 - closed
```
get the plugin and get it done
```
#15 - plus_minus tracker - 2010-08-23 00:30:39 - closed
```
ppl need to be able to see who plus'd what
```
#14 - fix pagination - 2009-05-06 21:19:15 - closed
```
its broken, fix it
```
#13 - edit page - 2009-05-06 21:19:15 - closed
```
make a page so things can be edited
```
#12 - impliment session flash - 2009-05-06 21:19:15 - closed
```
or similar, then improve messages everywhere, eg, submit, login, login fail, logout etc
```
#11 - email verifaction - 2009-05-06 21:19:15 - closed
```
impliment email verifaction with a  long random number  + new db table.
```
#10 - add user setting page - 2011-02-13 23:33:42 - closed
```
wghere can upload avatar, set timezone, email, password, notifcations + etc
```
#9 - tags - 2009-05-06 21:19:15 - closed
```
each item wants a list of the tags associated with it
```
#8 - mixed front page - 2009-05-06 21:19:15 - closed
```
need to impliment a mixed front page, and relivent sections.
```
#7 - editorials - 2009-09-08 17:37:43 - closed
```
like most things just needs finishing, basically just blogs thats have the is_ed flag set
```
#6 - improve side menu - 2009-05-06 21:19:15 - closed
```
Its bloated sql atm, needs stripping down
Also needs more details, no. comments, pic thumbnail, border, etc.

fancy log view javascript slider thing
```
#5 - log stuff - 2009-05-06 21:19:15 - closed
```
new users, new comments, new links/blogs/pics new promotions

```
#4 - finish profile page - 2009-05-06 21:19:15 - closed
```
should have list of submitted, plus, minus, comment etc
needs settings page so can set timezone, avatar othershit


mostly done, just needs submitted stuff, settings and links sorting, and htacces rewrites
```
#3 - set max font size - 2009-05-06 21:19:15 - closed
```
at the moment theres no limit on the max font size in comments. Needs to be fixed
```
#2 - make blogs more readable - 2009-05-06 21:19:15 - closed
```
add rounded section for blogs, perhaps with the title as well
```
#1 - test - 2008-11-24 00:35:02 - closed
```
test
```
