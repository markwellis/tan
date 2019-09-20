#617 - broken gifs
```
http://i.imgur.com/PhkKp8y.gif
```
#616 - deploy remove js/css minifed cache
```
change it to not be a symlink, and add the version on the end as query param
```
#615 - case sensitive useranme
```
make sure to lc username when logging in, and when checking if it already exists
```
#614 - broken gif 500 error
```
https://thisaintnews.com/static/user/pics/1328745600/1329003111_WTF--.gif
```
#613 - replace TT html filter
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
#612 - sbmitted tags order changed
```
it got reversed, that's not cool
```
#611 - submit tags case sensitive
```
i think
```
#610 - remove nano seconds from timestamp display
```
because it's shit
```
#609 - external views are not being recorded
```
104880 | 2015-02-08 16:00:40

was the last one
```
#608 - get changes from server
```
there's loads to import
```
#607 - reCAPTCHA v2
```
perhaps do it as part of the formhandler thing
```
#606 - "+" is not valid in email address!
```
fix it
```
#605 - 500 error Could not open file /var/www/TAN/root/static/cache/thumbs/137000/137913: Is a directory
```
Caught exception in TAN::Controller::Thumb->index "write image  error Could not open file /var/www/TAN/root/static/cache/thumbs/137000/137913: Is a directory at /var/www/TAN/lib/TAN/Controller/Thumb.pm line 37."
```
#604 - 500 error - Could not open file /var/www/TAN/root/static/cache/ thumbs/67000/67102: Is a directory at
```
Error:
Caught exception in TAN::Controller::Thumb->index "write image  error Could not open file /var/www/TAN/root/static/cache/thumbs/67000/67102: Is a directory at /var/www/TAN/lib/TAN/Controller/Thumb.pm line 37."


URL:
https://thisaintnews.com/thumb/67000/67102/index.html

Referer:


Client IP:
98.165.96.8
```
#603 - image thumbnail is blurred
```
see https://thisaintnews.com/view/picture/137359/global-temperature-anomalies-averaged-from-2008-through-2012
```
#602 - redirect old recent comments url
```
RewriteRule ^/recent_comments/?$ /recent/comments [R=301,NE,L]
```
#601 - remove pagecache plugin
```
it's terrible, and because of the new stash thing it doesn't work properly
```
#600 - og data wrong
```
needs to be article, not website. and make the thumbnail bigger
```
#599 - recent comments on deleted objects still show
```
it's not checking object.deleted
```
#598 - convert image model to use imager
```
instead of shelling out to convert
```
#597 - hide quotes in recent comments
```
it's ugly
```
#596 - recent links etc
```
add it
```
#595 - convert to Path::Tiny
```
in places, like TAN::Model::ParseHTML
```
#594 - html video embed
```
add versions to all modules (good time to  switch to distzilla?)

only load modules with out version

add option for ssl, and disable url to embed for sites that don't support ssl (liveleak etc)
```
#593 - disable sslv3
```
it's already done on the server, but make it official

https://blog.cloudflare.com/sslv3-support-disabled-by-default-due-to-vulnerability/
```
#592 - change req->param(foo) to req->params->{foo}
```
because of the security problems, and other things
```
#591 - 302 redirect on /
```
it should be a 301, and it's not serving the whole hostname either
```
#590 - tweak score algorithm
```

```
#589 - 500 error on change password with length over 50
```
not a very helpful error!
```
#588 - upgrade ssl cert to sha256
```
https://shaaaaaaaaaaaaa.com/check/thisaintnews.com
```
#587 - views revisions
```
at the moment there's a update_or_create, which is 2 sql queries, it would be far more sensible to just insert a new view and use the created date as the revision number
```
#586 - remove profile pages from objects
```
it's stupid, make it a separate table
```
#585 - nsfw admin log items shouldn't show
```
coz that's not cool
```
#584 - Wide character in syswrite on poll vote
```
— I want to have cake and eat it too. (for Beelz) 
```
#583 - rename forigen keys in db and run dbicdump
```
the big problem when i ran this before was it renaming all the relationships. they might not be perfect, but for now it's a good idea to rename them in the db, run dbicdump and then work on the rest from there
```
#582 - tin tan comments
```
move plus_minus to 2 new tables, tin & tan.

add ability to tin/tan comments

comments that have a tan > $CUTOFF_AMOUNT should be hidden by default

something about user comment tin:tan ratio auto hiding?
```
#581 - cleanup code
```
remove profiler, whitespace etc 

lots of little things, make it tidier
```
#580 - tagthumbs doesn't check for deleted
```
you can have a deleted pic a tag thumb
```
#579 - change sslciphersuite
```
http://blog.cloudflare.com/killing-rc4-the-long-goodbye

EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
```
#578 - static cache-control public header
```
because it's better for caching apparently, especially mixed with ssl
```
#577 - move backups
```
shared hosting is expiring, move it back to tvc
```
#576 - switch back to openssl
```
since it's getting a lot more inspection now, it'll be safer. also tls 1.2
```
#575 - twitter worker not working
```
it's well out of date
```
#574 - bookmarklet blank page
```
if you submit one image, then another, the 2nd will be a blank page :/
```
#573 - comments not adding to search index
```
:|
```
#572 - http https urls don't duplicate detect
```
eg 

https://www.youtube.com/watch?v=5Krz-dyD-UQ

and 

http://www.youtube.com/watch?v=5Krz-dyD-UQ

can both be submitted
```
#571 - password change ability
```
add it
```
#570 - renew tan cert
```
because of heartblead, just make a new one
```
#569 - switch to nss instead of openssl
```
openssl is bad apparently, nss is much more betterer
```
#568 - update password storage salt etc
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
#567 - image doesn't upload :/
```
for some reason this is an invalid image, when it's not
```
#566 - backup scripts
```
db backup - don't backup views table data - might have to make it a 2 step backup, schema.sql + data.sql

remove encryption, as it's not going anywhere unsafe now
```
#565 - search nsfw
```
needs to set nsfw:0 instead of nsfw:n
```
#564 - embedded  videos ssl
```
Liveleak et 
```
#563 - dance smilie is wrong
```
there are 2 dance.gif and dance.png, rename and add an alias
```
#562 - video embed https
```
viemo etc
```
#561 - sitemap pinger worker
```
doesn't log the sitemap url, seems broken.

investigate

pinging http://submissions.ask.com/ping?sitemap=
pinging http://www.google.com/webmasters/sitemaps/ping?sitemap=
pinging http://search.yahooapis.com/SiteExplorerService/V1/updateNotification?appid=IRxERwfV34EV44V9LTrJsENRs0V4JlaxrmVCr93OXcpqgzdQqUVRjKIo0FrabG1g&url=
pinging http://webmaster.live.com/ping.aspx?siteMap=
pinging http://api.moreover.com/ping?u=
```
#560 - upgrade to ubuntu 13.10 (for apache 2.4)
```
use the mozilla recommended settings (requires apache 2.4)

https://wiki.mozilla.org/Security/Server_Side_TLS
```
#559 - reduce salt size
```
512 is massive, drop it to 32 instead
```
#558 - secure tan
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
#557 - recaptcha  use ssl
```
it's not being displayed on the login page because it's not ssl
```
#556 - exception simple accessor name
```
make sure name is a valid perlsub name

same for lucyx search result
```
#555 - ebaumsworld video embed fail
```
https://thisaintnews.com/view/video/130523/Otester-Found-in-South-Africa
```
#554 - gearman::xs
```
replace gearman with gearman::xs
```
#553 - replace json::xs with Cpanel::JSON::XS
```
it's more better init
```
#552 - perl 5.18.1
```
upgrade
```
#551 - ssl fixes
```
Enable forward secrecy

Ssllabs.com get rating up!
```
#550 - certificate www.this... instead of dev
```
Change it
```
#549 - max password input length
```
You could dos the site with a really long password
```
#548 - move modules to github
```
help perl a lil bit
```
#547 - Nielsen’s ten heuristics
```
Get it
```
#546 - mysql error in syslog
```
Jul 18 06:35:52 tan mysqld: 130718  6:35:52 [Warning] Unsafe statement written to the binary log using statement format since BINLOG_FORMAT = STATEMENT. Statement is unsafe because it invokes a trigger or a stored function that inserts into an AUTO_INCREMENT column. Inserted values cannot be logged correctly. Statement: INSERT INTO `views` ( `created`, `ip`, `object_id`, `session_id`, `type`, `user_id`) VALUES ( NOW(), '66.249.78.22', '90809', 'e9a72794ed40aedf579dc9f2bee1a20a584b37d6', 'internal', NULL )
```
#545 - apparmour or grsec, use one
```
probably apparmor as it's installed and ubuntu standard
```
#544 - ban probey ip's
```
they annoy me
```
#543 - warning in errorlog
```
Use of uninitialized value in concatenation (.) or string at /var/www/TAN/lib/TAN/Controller/Search.pm line 20.
```
#542 - rkhunter cron
```
Install it and add a cron job
```
#541 - twitter spammer broken
```
hmm
```
#540 - youtube timecode
```
it uses ?start= instead of #t= now
```
#539 - accesslogs in vhosts
```
some don't have them, some do. clean them up etc
```
#538 - leach protector
```
rewrite it in apache land

see https://trac.thisaintnews.com/thisaintnews/browser/tan/conf/varnish/tan.vcl?rev=b156b5eea1ad343b0555adfc9a27c40d6c68d3a7 for the rules
```
#537 - tan www.thisiantnews.com redirect
```
when you type thisaintnews.com into address it gets redirected to https://www.thisaintnews.com then https://thisaintnews.com/index/all/0/ change the redirect detect thing to have a condition for www.
```
#536 - trac vhost on ssl
```
get new ip, ssl cert (use cacert) etc
```
#535 - re2  - impliment and benchmark
```
find suitable use cases etc
```
#534 - unix socket for starman
```
i think it supports them, change the startup script and vhost config to use them instead
```
#533 - smilies.png (for tinymce icon) scale to 20x20
```
currently 24x24
```
#532 - resize comment icon to 15x15
```
currently 20x20 scaled to 15x15

check this wont mess anything up
```
#531 - resize twitter icon to 15x15px
```
it's currently 16x16 scaled to 15. 
```
#530 - url decode on submit bookmarklet
```
yeah
```
#529 - remove --limit-requestbody in startup script
```
it's not needed anymore for starman

also move apache limit request body outside of vhost 
```
#528 - admin delete coment failed
```
Error:
DBIx::Class::Storage::DBI::_dbh_execute(): DBI Exception: DBD::mysql::st execute failed: BIGINT UNSIGNED value is out of range in '(`tan`.`object`.`comments` - 1)' [for Statement "UPDATE `comments` SET `deleted` = ? WHERE ( `comment_id` = ? )" with ParamValues: 0=1, 1='308385'] at /var/www/TAN/lib/TAN/Controller/View/Comment.pm line 155

https://thisaintnews.com/view/link/115435/Turning-the-tables-on-Big-Brother--Now-internet-users-can-watch-who-is-spying-on-them-in-blow-against-Google-s-new-snooping-policy#comment308385
```
#527 - find slow sql queries
```
for example the page count isn't cached
```
#526 - ditch varnish, use spdy and ssl
```
not needed, just use apache and mod_cache for the tan app
```
#525 - sanitize input
```
Error:
DBIx::Class::Storage::DBI::_select_args(): A supplied offset attribute must be a non-negative integer at /var/www/TAN/lib/TAN/Schema/ResultSet/Object.pm line 77



URL:
http://thisaintnews.com/index/all/0/?page=6'%20or%201%3Dconvert(int%2Cchr(114)%7C%7Cchr(51)%7C%7Cchr(100)%7C%7Cchr(109)%7C%7Cchr(48)%7C%7Cchr(118)%7C%7Cchr(51)%7C%7Cchr(95)%7C%7Cchr(104)%7C%7Cchr(118)%7C%7Cchr(106)%7C%7Cchr(95)%7C%7Cchr(105)%7C%7Cchr(110)%7C%7Cchr(106)%7C%7Cchr(101)%7C%7Cchr(99)%7C%7Cchr(116)%7C%7Cchr(105)%7C%7Cchr(111)%7C%7Cchr(110))--
```
#524 - dev.thisaintnews.com not using custom module path
```
probably something wrong in start_tan.sh
```
#523 - css image sizer
```
instead of the js way it's done now, in comments, blogs forums etc

see mobile css for correct way to do it
```
#522 - http caching
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
#521 - youtube us nocookie site
```
Privacy
```
#520 - twitter spammer uses old api
```
upgrade
```
#519 - remove newlines for none mobile posts
```
Make it one giant blob of text, so when editing/quoting on mobile it doesn't get messed up
```
#518 - db_backup script not dumping triggers
```
it's a bitch
```
#517 - sns-structcadtech.com
```
add this
```
#516 - varnish redirect rule
```
redirect all unmatched to thisaintnews.com
```
#515 - aws
```
needs aws, don't forget it's patched
```
#514 - git commit hook new PYTHONPATTH
```
because it's not in system anymore
```
#513 - trac
```
setup trac vhost
```
#512 - dbix warning
```
Malformed UTF-8 character (unexpected non-continuation byte 0x20, immediately after start byte 0xff) in regexp compilation at /mnt/stuff/perl/perls/perl-5.18.0/lib/site_perl/5.18.0/DBIx/Class/Storage/DBIHacks.pm line 516.

caused by 

DBIx/Class/Storage/DBIHacks.pm:469:    $sql_maker->{quote_char} = ["\x00", "\xFF"];
```
#511 - accesslog
```
there's no accesslog in starman, apply this

http://search.cpan.org/~miyagawa/Plack-1.0028/lib/Plack/Middleware/AccessLog.pm
```
#510 - link rel="image_src"
```
for reddit, facebook etc
```
#509 - devel config not loading
```
add CATALYST_CONFIG_LOCAL_SUFFIX=devel to start_tan script
```
#508 - create tickets from markdev.new_install_list
```
exciting
```
#507 - exim
```
pretty sure that it's a standard install on current tan server. 

tandev has same standard install, test it
```
#506 - max file upload size
```
currently starman and varnish will allow w/e through.

fix that so the max size is like 8mb or something
```
#505 - gearmanx::simple::worker is now deprecated
```
add a note to the pod that it's now unmaintained, release
```
#504 - convert worker scripts to upstart
```
probably don't need to use app:daemon any more, or gearmanx::simple::worker for that matter
```
#503 - given/when is now experimental
```
given is experimental at /var/www/TAN/lib/TAN/Controller/Tcs.pm line 35.
when is experimental at /var/www/TAN/lib/TAN/Controller/Tcs.pm line 36

may be others lurking, find them!
```
#502 - catalyst 5.90040
```
http://search.cpan.org/~jjnapiork/Catalyst-Runtime-5.90040/lib/Catalyst/Upgrading.pod
```
#501 - starman upstart job
```
create a upstart job, have it respawn etc
```
#500 - new server
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
#499 - root redirect removes query params
```
eg /?show_minify becomes /index/all/0/
```
#498 - configs for varnish and apache
```
create them
```
#497 - don't detect mobile on thumb or minify
```
no point, since it goes through static and varnish will remove the cookie, so it'll be ran again and again...
```
#496 - disable debug on Plugin::Cache
```
prints a lot of memcached traces, not needed
```
#495 - static on seperate domain
```
static.thisaintnews.com

```
#494 - psgi
```
create tan.psgi for starman
```
#493 - autoconvert beaking img scr
```
the following

<img alt="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" src="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" height="659" width="490" />

becomes

<a href="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" height="659" src="http://s2.postimg.org/isc0q4cp5/Lucy_Pinder_Superman.jpg" width="490" /> 
```
#492 - facebook  video embed
```
Apperentlh facebook  videos are embeddable
```
#491 - o_0 smiley face not auto converting
```
o_0

And reversed
```
#490 - profile user page missing avatars
```
the page of all the users has no avatars
```
#489 - admins cant change type on own posts
```
Can't change own forum to poll etc
```
#488 - bookmarklet submit white page
```
not sure what it's all about, investigate.
```
#487 - proper bookmarklet support with quick add url
```
After #486

Add new url that takes url to submit as parameter and then redirects to submit

Auto detects type (image, video, link) and fetches metadata where possible so prefilled om submit page
```
#486 - submit auto complete
```
insert url, have it pull data automatically (where possible)

also check for repost etc

AJAX
```
#485 - facebook spammer
```
make one like the twitter spammer. 

make a facebook group
```
#484 - reddit spammer
```
make a reddit spammer like the twitter one
```
#483 - open graph tags
```
https://developers.facebook.com/tools/debug/og/object?q=http%3A%2F%2Fthisaintnews.com%2Fview%2Fpicture%2F128257%2FAt-the-click-of-a-button%23comment369128
```
#482 - liveleak fullscreen doesn't go full screen
```
Check the embed code
```
#481 - auto embed failures
```
Video embed failed without tags on

http://thisaintnews.com/view/blog/127926/The-Shock-of-the-Shite

Look at code, strip video tags and add to tests
```
#480 - submit upload custom picture
```
How about a "upload other picture for post" button that would have a popup streamlined picture upload, and when you hit done the popup closes and the main post uses that picture. Sure you'd still havento enter title + tags, but that's not too bad is it?
```
#479 - facebook world thing
```
Show objects that have comments newer than last view, limited to 20 or so
```
#478 - recent comments upgrade
```
Recent viewed, recent tined, recent tanned, recent posted, recent promoted. Add those
```
#477 - chrome citing render error
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
#476 - Use of uninitialized value in substitution
```
Use of uninitialized value in substitution (s///) at /var/www/thisaintnews.com/htdocs2/lib/TAN/Model/Submit.pm line 55.
Use of uninitialized value in string eq at /var/www/thisaintnews.com/htdocs2/lib/TAN/Model/Submit.pm line 56.

```
#475 - youtube playlist
```
add support for the above
```
#474 - teweet embed
```
https://dev.twitter.com/docs/embedded-tweets
```
#473 - who's online mobile
```
At the top of the page maybe?
```
#472 - update faq video support
```
Lists video sites that are no longer suppoted
```
#471 - youtube video timeselector #t=
```
should be easy, e.g.

http://www.youtube.com/watch?v=5t99bpilCKw#t=00m08s
```
#470 - mobile order by
```
Add order by sort box thing on indexes for mobile pages
```
#469 - password salting
```
http://crackstation.net/hashing-security.htm

Do it, find a way to do it without requiring useres passwords, eg sha password, salt sha, hash sha + salt
```
#468 - catalyst::plugin::email uses email::send which is depricated
```
email::send uses return::value which is depricated.

update catalyst::plugin::email to use email::sender

send patches
```
#467 - db script to convert smiley images to :smilies
```
split from #461 since I don't have a proper test setup on this netbook

Script to go through db and convert smilie imgs into plaintext
```
#466 - add flock around delete old js versions
```
So only one person gets to delete, stop the errors in the error_log
```
#465 - nsfw filter disables itself on mobile site
```
Why? Cookie maybe? Cache checker?
```
#464 - mobile tan profile link
```
At top of page
```
#463 - ajax comment edit mobile site
```
Ajaxinate
```
#462 - better nl2br for mobile
```
It doesn't work for blogs anyway.

Make it so that if you submit and then edit it doesn't double nl2br.

Tests
```
#461 - smilies, urls and auto embed
```
First up, better be test driven.

Second, use the bbcode module

Auto convert urls into hyperlinks, if they're not already, and not in embed iframes, or are not embeddable

Smilies, both ;-)  and ;) should be the same. Smilie inserter should just insert plaintext instead of image.

Script to go through db and convert smilie imgs into plaintext
```
#460 - video urls
```
Vimeo puts a /m in the url if on mobile

Ebuamsworl doesnt have to end in a /

Check others
```
#459 - edit object submit button says "submit $type" instead of "Edit $type"
```
fix
```
#458 - edit comment on mobile textarea is TINY!!!
```
make it normal sized!
```
#457 - write mass_undelete script
```
pass in mass delete arg, have it decode the json and update deleted=>0
```
#456 - new users can't upload avatar
```
coz it's set to NULL in the db.

change template where it does replace to pass in avatar, change user result avatar to take avatar filename
```
#455 - mobile site tune ups
```
add padding under comment box, as the keyboard on android covers it.

add hr under menu on recent comments page

make page buttons bigger
```
#454 - mobile site is shit on touch
```
add some padding around things, make hyperlink font slightly bigger
```
#453 - Error opening file for reading: Permission denied
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
#452 - nl2br nor working in comment submit for mobile
```
but it is working on comment edit. fix
```
#451 - tinymce 3.5.8
```
upgrade
```
#450 - broken menu
```
go to upcoming or promoted page then go to the same page, menu broken. some javascript error about split
```
#449 - broken tin/tan buttons on ff 18
```
change them to be more simple
```
#448 - object revisions
```
split up #333
```
#447 - comment revisions
```
split up ticket #333
```
#446 - 500 error mobile template
```
it's showing the normal template
```
#445 - 500 error
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
#444 - ssh to tan.pl
```
can't ssh from tan.com
```
#443 - 500 error
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
#442 - date joined wrong on profile page
```
it's showing like this:
Joined 2012-12-03T08:30:53 ago

probably missing the _accessor in the db schema
```
#441 - avatar upload
```
pre_crop page needs a ?t=$time adding to the url so it sees the correct image, also all the old avatars are still there, maybe add a user old avatar thing
```
#440 - blank 404 page for minify
```
no point serving up a huge 404 page when a blank page will do
```
#439 - db cleanup
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
#438 - javascript frontend
```
after #420
```
#437 - terms and conditions
```
make it so they have to be accepted to use tan

rewrite t&cs

use cms to write t&cs, but use custom template to display them with accept (update user.tcs to tcs.rev) or decline (log user out)
```
#436 - cms admin missing
```
link is missing
```
#435 - comment delete missing
```
for some reason it's not there anymore, fix it
```
#434 - domains at zonedit
```
move none tan domains to new account.

move seans to own account.

perhaps same for lymehurst

remove howmanykillings.com
```
#433 - backup git
```
adjust backup script
```
#432 - test 2
```
hook close test
```
#431 - test 1
```
hook test
```
#430 - test git hooks
```
close this with hook
```
#429 - tidy up
```
there's a lot of old scripts and things hanging around that needn't be. cleanup time!
```
#428 - consolidate templates
```
lots of duplicates in view, move to shared. check other places
```
#427 - add no_bbcode to comment, use in quote
```
so instead of quoting the output html, quote the bbcode etc
```
#426 - Parse::TAN
```
make it into a model?

write tests

make quote tag nestable

remove youtube tag, write script to update database

make video tag remove hyperlinks
```
#425 - move TAN::Submit into modules
```
move it, update things as required, test etc
```
#424 - add pseudo class support
```

```
#423 - Image::Magick over `convert`
```
switch because using `convert` is a lil backwards
```
#422 - Model::Image flocking
```
flocking hell!
```
#421 - Mobile view animated gif truncated
```
Make it show the whole image
```
#420 - new design
```
new design 
```
#419 - data::validate::image fails on tiff
```
due to convert error

/www/majesticmodules/Data-Validate-Image-0.006/t/test_data/images/image.tiff
TIFF 46x46 46x46+0+0 8-bit TrueColor DirectClass 908B 0.000u 0:00.000
convert: Error writing data for field "DocumentName". `/dev/null' @
error/tiff.c/TIFFErrors/496.

```
#418 - mobile site tin/tan ajx
```
or make it return to referer
```
#417 - edit comment font wierd
```
it's wrong on edit comment via ajax, dunno about on edit comment page
```
#416 - quote is missing an extra line break
```
after the [/quote] there should be another line break
```
#415 - more missing on tag thumbs
```
it's goned!
```
#414 - xss vun in recent_comments page
```
fix it!
```
#413 - Filter not working
```

```
#412 - Add marin bottom to TAN-bottom
```

```
#411 - emoticons plugin not working
```
check the original vs new emoticons.htm
```
#410 - use tags stems in twitter
```

```
#409 - move session cache
```
so that users don't get logged out on restart
```
#408 - menu javascript
```
make it so the menu changes on click
```
#407 - change HTML::Video::Embed to take a class instead of height/width
```
test works properly etc
```
#406 - edit page
```

```
#405 - profile page
```

```
#404 - remove menu items
```
home, admin log, chat etc
```
#403 - up/down link
```
top and bottom of page
```
#402 - duplicate username?
```
DBIx::Class::ResultSet::find_or_create(): Query returned more than one row.  SQL that returns multiple rows is DEPRECATED for ->find and ->single at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Profile/User.pm line 49
```
#401 - quick tag edit page
```
make a page with 
{{{
title
  tags
}}}

where tags is editable, then a save button, maybe hidden fields to say if tags have been changed on object or not
```
#400 - edit comment page missing reason box for admin edit
```
add it in
```
#399 - smiley leach protection
```
make it so
```
#398 - tinymce upgrade
```
tinymce on tan is well outdated, upgrade
```
#397 - mobile site
```
create mobile site
```
#396 - unmatched regex operator
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
#395 - triggers in db backup script
```
they're not there
```
#394 - use 5.014
```
add this to TAN.pm get new features

change number matching regex to use /a modifyer
other changes
```
#393 - share this
```
button on things
```
#392 - update tan server
```
run do-release-upgrade
```
#391 - workers script
```
add cd /tmp into restart and start script
```
#390 - leach protection not workign in chrome
```
for some reason i can go straight to pics, http://thisaintnews.com/static/user/pics/1335398400/1335465180_Best-Craigslist-car-ad-of-all-time.jpg
```
#389 - new version of lucy
```
update lucyx::simple and reindex, see also #387
```
#388 - admin log page title
```
^
```
#387 - replace indexes with search
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
#386 - new smiley
```

http://thisaintnews.com/view/picture/114672/Jerk
```
#385 - js/css minifier
```
make it so the cached version url is like

/static/cache/$VERSION/(js|css)/filename

and then make sure old versions of cached files are removed.
```
#384 - change avatar location
```
put them in folders like the rewrite, username/upload_time and add a field to the user table in the db that contains the avatar filename. make sure on upload old avatars are removed.
```
#383 - 500 error
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
#382 - replace profile links with search link
```
eg comments to username:foo type:comments etc
```
#381 - submit broken on ipad.... probably
```
coz of tiny mce, so atleast for blog|forum. investigate
```
#380 - can't comment on ipad
```
coz the comment.js unload is only looking for iPhone|Android, not iPad
```
#379 - twitter hash tags
```
in twitter script, not sure how, maybe based on word lookup in tag db and hashtag the most popular word, exclude words like 'the' 'and' etc
```
#378 - quote link missing on new comment on ajax comment post
```
^
```
#377 - add vote count next to poll
```
see title
```
#376 - add votes column to poll table
```
and change object.score to be an int
```
#375 - search faq
```
write it
```
#374 - lotto
```
make it
```
#373 - first 2 comments of new user show as comment #1
```
see title
```
#372 - change server in backup sync script
```
from thisaintnews.pl to ftp.thisaintnews.pl

done on live, just not in svn
```
#371 - rss profile/comment and search
```
check it, make it work
```
#370 - ajax comment post missing hr
```
at top
```
#369 - new things not being added to search index
```
for some reason.
```
#368 - things that point to /search should point to /search/
```
iirc it's only the tag links, but check
```
#367 - warning
```
Use of uninitialized value in concatenation (.) or string at /var/www/thisaintnews.com/htdocs2/root/templates/classic/view/video.tt line 7.
```
#366 - html::video::embed add youtu.be
```
youtu.be
```
#365 - number format on profile page
```
so it doesn't say things like 
 links: 302020202

instead it says

 links: 302,020,202
```
#364 - nsfw in page title
```
^
```
#363 - ip ban table
```
for deleted users
```
#362 - deleted images need to delete image
```
see title
```
#361 - object description looks indented
```
first line, add a margin-top or something to it
```
#360 - remove /var/log/* in backups?
```
experiment on markdev, see if the folder is emptied that the log files are remade and there's no errors
```
#359 - check old backup delete script is working(after february)
```
check there's no old files left over, and too much hasn't been deleted
```
#358 - 500 error
```
DBIx::Class::ResultSet::update_or_create(): DBI Exception: DBD::mysql::st execute failed: Deadlock found when trying to get lock; try restarting transaction [for Statement "INSERT INTO views ( created, ip, object_id, session_id, type, user_id) VALUES ( NOW(), ?, ?, ?, ?, ? )" with ParamValues: 0='99.224.236.112', 1="110828", 2='530df24660d537feef432c13f92c4ad81118dc6c', 3='external', 4=undef] at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Redirect.pm line 75
```
#357 - change scor column
```
change it from float to int or something
```
#356 - scripts
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
#355 - deleted items still in search index
```
^
```
#354 - tag edit broken
```
i think it's a permissions problem
```
#353 - plus minus box
```
change to arrows up and down, show tins and tans again.

make fade on change.

make so can only tin or tan.
```
#352 - break view controller into sub components
```
make it not so big
```
#351 - change plus minus to show score
```
and not plus + minus
```
#350 - cms page content type and noeditor options
```
add them
```
#349 - sitemap content-type
```
it's being served as text/html when it should be application/xml
```
#348 - not updating score if new score < old score is dumb
```
coz tans don't work, comment deletions don't lower score. thinking about it, it was a very bad idea in the first place, since scores are organic, so fix

also change age penalty to 60 days instead of 50
```
#347 - css js multilevel include not working right
```
they're not getting the mtime for things like Submit@tags
```
#346 - input validation
```
Error:
Couldn't render template "profile/user/comments.tt: undef error - DBIx::Class::ResultSet::all(): A supplied offset attribute must be a non-negative integer at /var/www/thisaintnews.com/htdocs2/root/templates/classic/profile/user/comments.tt line 13
"

```
#345 - admins own edits appearing in admin log
```
they shouldn't
```
#344 - url encode submit tag thumbs
```
so people can do things like /b or 9/11. 

 /tagthumbs/anonymous%204chan%20/b//?noCach
```
#343 - cant edit profile
```
or change avatar, probably only works for admins, im guessing it's the role checkin code blocking normal users
```
#342 - deadlock when updating score
```
Error:
DBIx::Class::Relationship::CascadeActions::update(): DBI Exception: DBD::mysql::st execute failed: Deadlock found when trying to get lock; try restarting transaction [for Statement "UPDATE object SET score = ? WHERE ( object_id = ? )" with ParamValues: 0=1.220, 1='108193'] at /var/www/thisaintnews.com/htdocs2/lib/TAN/Schema/Result/Object.pm line 203

```
#341 - 500 error on delete all user content
```
something to do with the scoring system

Caught exception in TAN::Controller::View->update_score "Can't call method "object" on unblessed reference at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/View.pm line 37."


```
#340 - find undef value in cache in cms result
```
im pretty sure it's in the menu since it errors on every page
```
#339 - posted date on promoted objects
```
^
```
#338 - threaded comments
```
make comments threaded

 * make quote button apply to active editor
 * quote should thread
 * how far should comments thread over?
```
#337 - don;t update score if new score < old score
```
^
```
#336 - cant edit polls
```
answers are missing
```
#335 - update score on comment delete
```
see title
```
#334 - pagination last page 404
```
in more place than 1 the last page on the pager links to a 404 page. 
```
#333 - revisions
```
use the cms page style revisions on objects and comments, do away with the json shit in the admin log
```
#332 - stemmed tags
```
http://search.cpan.org/~creamyg/Lingua-Stem-Snowball-0.952/lib/Lingua/Stem/Snowball.pm
```
#331 - edit change types
```
^
```
#330 - page meta tages
```
http://www.paperstreet.com/blog/1341
```
#329 - uri encode url on remote image upload
```
^
```
#328 - tins and tans on profile
```
see title
```
#327 - uninitialized value warnings
```
Use of uninitialized value $tag in substitution (s///) at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Submit/Edit.pm line 192.

Use of uninitialized value in pattern match (m//) at /var/www/thisaintnews.com/htdocs2/lib/TAN.pm line 85.
```
#326 - undef value in cache
```
probably in cms

Use of uninitialized value in subroutine entry at (eval 389) line 15
```
#325 - subqueries
```
http://search.cpan.org/~abraxxa/DBIx-Class-0.08195/lib/DBIx/Class/Manual/Cookbook.pod#Subqueries
```
#324 - tags in page meta keywords
```
put the tags in the page meta keywords
```
#323 - nsfw blog/comment cache
```
~~make it so forums pages are cached the same way as blog pages.~~

then again, why do they even need to be cached different? nsfw is a cookie attr now, so surely the pages are the same, just on one the boob blocker runs. 

investigate
```
#322 - comments on nsfw threads showing in profile with filter on
```
erm, see title?
```
#321 - avatars
```
remove ?m=timestamp, make a rewrite rule instead, proxy servers aint caching
```
#320 - page width
```
make less wide
```
#319 - sns-structcadtech robots.txt
```
robots.txt
```
#318 - cms
```
make a cms system
```
#317 - xml error
```
on submit comment with a video
```
#316 - link doesn't work
```
this link should work: /view/video/104358/
```
#315 - xss recent comments
```
on preview you can insert things
```
#314 - nsfw image filter in forums
```
not working
```
#313 - forum section
```
make forum section
```
#312 - poll votes not showing
```
the % isnt showing
```
#311 - 500 error in rss
```
Error:
Caught exception in TAN::View::RSS->process "Can't locate object method "is_video" via package "TAN::View::TT" at /var/www/thisaintnews.com/htdocs2/lib/TAN/View/RSS.pm line 37."


URL:
http://thisaintnews.com/index/all/0/?rss=1

```
#310 - tempalate toolkit
```
convert templates to TT
```
#309 - edit lock
```
make it lock for edits after admin edits something

add link back to admin_log
```
#308 - profile pagination 404 error
```
http://thisaintnews.com/static/user/pics/1306368000/1306375881_New-Discovery-EdRoberts-Lives-Inside-TAN-Server.jpg
```
#307 - edit_object_nsfw role
```
allow edit nsfw and picture_id only
```
#306 - logger frontend
```
make a frontend for it
```
#305 - error 410
```
simply error page template
make 410 gone error
return this error for a deleted object view
```
#304 - add url method to user
```
url for users profile
```
#303 - rename css/js files
```
so they match controller/template names
```
#302 - code cleaning
```
lots of times there's references to $location, which should be $type

so it's $object->type and not $object->location, which is dumb

also there's eval's dotted around for this kind of thing find and remove

find and fix
```
#301 - bookmarklet for images
```
update it

document.contentType
[http://en.wikipedia.org/wiki/Internet_media_type#Type_image]
```
#300 - chat in own window
```
why it no work anymore
```
#299 - object thumbs not centred
```
change css to match > a >
```
#298 - meta description is wrong on all pages
```
says social news for internet pirates :/
```
#297 - add no error for bookmarklet
```
created bookmarklet, make it show no error, other than repost error
```
#296 - add <a> around object thumb picture
```
so can click and see picture in full
```
#295 - link/blog/poll picture relation ship called "image"
```
wtf is the consistancy?
```
#294 - report
```
users can report things
 * objects
 * comments
 * users
 * admins

reports can be read but not deleted
```
#293 - object delete
```
 * add object delete via flag in db
 * enable only for user role delete_object
```
#292 - access denied page
```
make an access denied page
```
#291 - new smiley
```
http://thisaintnews.com/view/picture/100652/mohammed-trollface
```
#290 - add db tables etc
```
many_to_many 

user => user_admin => admin
```
#289 - contact user
```
make it so admins can contact user
```
#288 - admin levels
```
 * ~~edit_object~~
 * ~~delete_object~~
 * ~~edit_user~~
 * ~~delete_user~~
 * ~~edit_comment~~
 * ~~admin_user~~
 * god
```
#287 - fullscreen youtube videos
```
enable it
```
#286 - index nwo trackerings
```
record index views so nwo tracker is more accurate
```
#285 - recent comments using wrong index
```
needs an index hint
```
#284 - deadlock
```
mark@tan:~$ [error] Caught exception in engine "DBIx::Class::ResultSet::update_or_create(): DBI Exception: DBD::mysql::st execute failed: Deadlock found when trying to get lock; try restarting transaction [for Statement "INSERT INTO views ( created, ip, object_id, session_id, type, user_id) VALUES ( NOW(), ?, ?, ?, ?, ? )" with ParamValues: 0='38.113.234.181', 1='100408', 2='d66cd57af4bb8ac6211ea379c0eeac7379be6169', 3='internal', 4=undef] at /var/www/thisaintnews.com/htdocs2/lib/TAN.pm line 58"

http://stackoverflow.com/questions/2596005/working-around-mysql-error-deadlock-found-when-trying-to-get-lock-try-restartin
```
#283 - convert db to innodb
```
 * convert to innodb
 * tune mysql config
 * flatten data {object => [view, plus, minus, comments], poll_answers => [votes]}
 * triggers
 * foreign keys
 * backup script
```
#282 - twitter worker bombed out
```
something about duplicate status, add eval around submit stuff
```
#281 - nsfw filter making images bigger
```
its not right

[http://thisaintnews.com/view/link/100046/CodeCogs---Online-LaTeX-Equation-Editor#comment233053]
```
#280 - poll title is a url
```
it tries to go to the external redirect /pollid url :/
```
#279 - gearman
```
do it
```
#278 - picture edit caching
```
(index) cache isnt being invalidated after edit
```
#277 - submit description nl2br
```
see title
```
#276 - Lucy
```
upgrade to Lucy
```
#275 - 500 error no such column plus
```
DBIx::Class::Row::get_column(): No such column 'plus' at /var/www/thisaintnews.com/htdocs2/lib/TAN/View/Template/Classic/Lib/PlusMinus.pm line 12

DBIx::Class::Row::get_column(): No such column 'comments' at /var/www/thisaintnews.com/htdocs2/lib/TAN/View/Template/Classic/Lib/Object.pm line 53
```
#274 - 500 error showing monkey not borris
```
fix it
```
#273 - blank submissions
```
dickheads just putting in spaces
```
#272 - are views being recorded for none logged in users
```
varnish + page cache = no tan. page views not being recorded (potentially) investigate
```
#271 - fail2ban
```
ssh fail2ban
```
#270 - top ad
```
remove the bottom one
```
#269 - rss content-type is wrong
```
change it to be application/xml
```
#268 - sumbit is slow
```
see why
```
#267 - project wonderful
```
make it load in a Asset?
```
#266 - twitter
```
make on promotion event that submits to twitter
```
#265 - dupliate profile for user
```
DBIx::Class::ResultSet::find_or_create(): Query returned more than one row.  SQL that returns multiple rows is DEPRECATED for ->find and ->single at /var/www/thisaintnews.com/htdocs2/lib/TAN/Controller/Profile.pm line 66
```
#264 - Use of uninitialized value in subroutine entry at (eval 466) line 15.
```
this url causes the above

http://thisaintnews.com/view/picture/93335/SFFFFFFxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
#263 - add index to robots.txt
```
there's no need for google to index the index, they have the sitemaps
```
#262 - reddit nsfw
```
for some reason the images aint showing, check the referrer and update the leech protector accordingly
```
#261 - remove 'no Moose'
```
stops strict working, remove it
```
#260 - you muppet - test after enabling strict!
```
broken 1.6.1 by not even restarting devbox. fix strict errors. p.s. shame on you
```
#259 - submit modules not using strict
```
they unload Moose, which also unloads strict + warnings. remove Moose unloading
```
#258 - thumb controller try{} around resize
```
resize has been updated to throw an exception on failure, and they aint being caught!
```
#257 - image upload failed no image file but added to db
```
caused a flood of 500 errors
```
#256 - floor week for image thumbs
```
1297296000.05847 is wrong
```
#255 - motools convert $ to document.id
```
should be pretty easy
```
#254 - remove video detection from templates
```
currently the template does video detection, this will be done at submit time now. remove it
```
#253 - edit link submit validators to return type => video
```
make it so that video use's the link submit schema + validators but it returns the correct type
```
#252 - convert existing links to videos
```
write script to go through current links and convert to video
```
#251 - create video table
```
create table and db schema and add relationships to object
```
#250 - 500 error for none numeric page no
```
getting 500 from google for urls like

URL:
http://thisaintnews.com/index/all/1/?page=avqcaopjlpu

Error:
DBIx::Class::ResultSet::pager(): Can't create pager for non-paged rs at /var/www/thisaintnews.com/htdocs2/lib/TAN/Schema/ResultSet/Object.pm line 132
```
#249 - validate thumb
```
make sure tag thumbs is validated
```
#248 - convert search model to use catalyst model factory perrequest
```
coz it doesnt like being a long lived module
```
#247 - resize problem
```
one of these files (govenator) doesn't resize correctly 
```
#246 - make images scalable
```
 * maybe store in db
 * set image domain for future proofing (static server)
 * flock thumb generation
```
#245 - menu click too fast
```
change it so if you click it too fast, it just goes to upcoming that section
```
#244 - picture desccription
```
make it optional
```
#243 - write tests for model::image
```
there's a lot of code in there, and not a single test!
```
#242 - fix avatar upload page
```
its broken coz of the new submit stuff.

depends on #241
```
#241 - update model('thumb') to use exception::simple
```
make it work damnit! returning 'error' is just not acceptable. not now, not never
```
#240 - mootols 1.3
```
check all js for mootools 1.3 incompatibilities
```
#239 - change namespace for submit templates
```
they're in ::Submit::Type:: and should just be in ::Submit::
```
#238 - smilies
```
http://i122.photobucket.com/albums/o241/Trouble1st/emotes/ComputerSmash-1.gif

http://i122.photobucket.com/albums/o241/Trouble1st/emotes/aintsaying.png

http://i122.photobucket.com/albums/o241/Trouble1st/emotes/computernerd.gif

http://www.babyandbump.com/images/smilies/ignore.gif
```
#237 - allow class on a elements
```
make it so
```
#236 - auto comment refresh
```
make view page poll for new comments
```
#235 - edit
```
make edit work with new submit system
```
#234 - flash params on fail
```
save params, load them in template
```
#233 - nsfw
```
enable nsfw for everything.

code should mostly be in place, needs checkbox in template
```
#232 - javascript
```
make client side js

 * ajax submit?
 * validation
 * rework tag browser
```
#231 - poll sumbit
```
make submit work
```
#230 - http 303
```
redirect with 303 after post
```
#229 - kinosearchx::simple improvements
```
fix update_or_create failing to delete 

make entries per page an option to search
```
#228 - release KinoSearch::Simple
```
convert it to use KinoSearch1 and be called KinoSearchX. Release on cpan and github.

make tan work with new KinoSearchX module, install from cpan on live site.
```
#227 - make editor grow
```
make it grow when ppl type things
```
#226 - delay ad loading
```
put them in a onload event wrapper
```
#225 - disable tinymce for incomptable broswers
```
iphone and android
```
#224 - delete comment code is broken
```
doesn't let you delete if you don't have a js enabled browser
```
#223 - fetcher should use File::Temp
```
save to a File::Temp and return it instead of requiring a save_to param
```
#222 - project wonderful
```
change ads to project wonderful
```
#221 - remove google
```
ads and analytics
```
#220 - nsfw filter is mashin image sizes
```
http://thisaintnews.com/view/blog/94016/Special-Report--Rally-Against-The-Cuts#
```
#219 - remove ads on nsfw stuff
```
google done bitched, so fix it so theres no ads on indexes with the nsfw filter off, and no ads on nsfw content.

perhaps enable nsfw options on other objects, should be relatively simple
```
#218 - user messaging
```
we should be able to pm each other, although with the option to ignore pm's or something i dunno
```
#217 - auto rotate images
```
  -auto-orient         automagically orient (rotate) image
```
#216 - new smiley
```
http://www.homebrewtalk.com/images/smilies/occasion14.gif
```
#215 - favourite button
```
add a favourite button so people can bookmark stuff or w/e
```
#214 - pingback, trackback
```
add them, maybe just pingback, but do both is possible

 [http://search.cpan.org/~rjray/RPC-XML-0.73/lib/RPC/XML.pm]
 [http://search.cpan.org/~tima/Net-Trackback-1.01/lib/Net/Trackback.pm]
```
#213 - move videos to own place
```
write script to move links to videos keep object_id.

dunno how submit should work coz its really just the same as a link
```
#212 - create module system
```
something jsony that defines how tan works, so that submit, view, random, menu, profile etc function automated(ish).

make appropriate code function as independent as possible for rapid future feature addition.
```
#211 - who's online
```
select distinct(user.username) from views join user on (views.user_id = user.user_id) where created > date_sub(now(), interval 5 minute)

should cut it
```
#210 - profiles
```
polls are missing from user page

make index page of all users, sorted by something or other, dunno

add messaging
```
#209 - backup rotation
```
make script to delete old backups so all hdd space doesnt get eaten 
```
#208 - strip uploaded images
```
as long as they're not animated
```
#207 - google analytics
```
functiono
```
#206 - add votes to poll object comment bar thingy
```
erm ^
```
#205 - change poll colour
```
make it royal blue #002366
```
#204 - paginate tag thumbs submit
```
paginate em
```
#203 - poll edit caching
```
edit an answer, it shows the edit on the view page, on the edit page though its the old answer still :\
```
#202 - stop using date_ago
```
replace it with w/e it is that does it for the poll count down, although it might be a lil long. either way figure it oot
```
#201 - perl templating system
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
#200 - search select page broken
```
it just stays on page 1
```
#199 - comedy central [video]
```
http://www.comedycentral.com/videos/index.jhtml?videoId=147895&title=nixons-back
```
#198 - comment count
```
its weird, for first comment says #2, and also counts deleted comments
```
#197 - clean code
```
move logic from controllers to models where applicable
```
#196 - edit tagthumbs
```
it seems broken, too many tags and duplicates
```
#195 - moose convert catalyst::plugin::event
```
there's one varible should be an accessor, accessor already created
```
#194 - clean code
```
view controller and submit controller contain a lot of logic that should be in a model.

refactor
```
#193 - common regex
```
split common used regex into own model
```
#192 - avatar uploader help
```
theres no info on the crop avatar page, its really confusing to n00bs
```
#191 - trim tags
```
remove extra whitespace
```
#190 - convert kinosearch::tan into kinosearch::simple
```
convert it, make it more generic and pluggable
```
#189 - spawn hooks into events plugin/dispatch type
```
which ever one is better is the bets one
```
#188 - change hooks
```
change them to use a sub ref instead of a forward call. log for debug
```
#187 - stash submit stuff
```
flash it on failure so don't has to retype it all
```
#186 - switch to google ads
```
they're better than adjug, only 3 per page though
```
#185 - namespace::autoclean
```
use this in all modules
```
#184 - add kontraband video support
```
add support for the following video site

[http://www.kontraband.com/videos/23216/Americas-Path-To-Socialism/]
```
#183 - menu bug
```
when you click location then come back to current without changing upcoming, current upcoming isnt highligted
```
#182 - page titles
```
lots of pages don't have titles, fix it yo
```
#181 - plus_minus
```
fix it 

if you +/- thenopen thing and +/- it works backwards
```
#180 - new tiny mce
```
upgrade from 3.2.7 to 3.3.7 [http://tinymce.moxiecode.com/js/tinymce/changelog.txt]


[https://sourceforge.net/projects/tinymce/files/TinyMCE/3.3.7/tinymce_3_3_7.zip/download]




```
#179 - stike-through doesn't work
```
the html filter is clobbering it
```
#178 - add animated gif detection
```
''convert -identify animated.gif /dev/null''

should do it
```
#177 - search
```
lucene search engine thingy

http://lucene.apache.org/
```
#176 - clear  index caches
```
use hooks #174
```
#175 - check user saved comment
```
sometimes it throws a 500 error, improve it so it doesn't
```
#174 - hooks
```
add hooks for

 * object->submit
 * object->edit
 * object->plus_minus
 * ????
 * profit

use hooks to clear caches, have them hook in at compile time
```
#173 - polls
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
#172 - clean code
```
improve tagthumbs.pm, its not nice.

refactor index.pm to use profile style index template
```
#171 - animated gifs on preview page
```
hack it so it shows the original image for size 600.
```
#170 - google video broken
```
for 
http://video.google.com/videoplay?docid=-678466363224520614

```
#169 - add domain to links + extrernal views
```
see title
```
#168 - nsfw image filter
```
isnt functioning on blogs, make it fixed
```
#167 - Parse::BBCode updated, remove local copy
```
Its been updated, no longer any need to have a local modified copy
```
#166 - cache blog
```
blog aint cached, do it like comments
```
#165 - add profile page
```
add in profiles
```
#164 - entity encoding in tinymce breaking chrome
```
change entity_encoding to numeric in tinymce config
```
#163 - tag thumbs
```
some are coming up with '''0''' as the id. remove them
```
#162 - add megavideo embed
```
http://www.megavideo.com/?v=37ZFO2UR

<object width="640" height="418"><param name="movie" value="http://www.megavideo.com/v/37ZFO2URf1d88b806d04aefb182f1348b3988510"></param><param name="allowFullScreen" value="true"></param><embed src="http://www.megavideo.com/v/37ZFO2URf1d88b806d04aefb182f1348b3988510" type="application/x-shockwave-flash" allowfullscreen="true" width="640" height="418"></embed></object>
```
#161 - move all system script in project
```
all system scripts backups, sitemap, tor blocker, etc to be moved in project
```
#160 - update faq
```
 * add a bit about avatars must be sfw.
 * update NSFW text to link to http://en.wikipedia.org/wiki/Not_safe_for_work
 * add a bit about how to connect to irc via chatzilla/mirc

```
#159 - order by
```
when changing the order to idnews etc, it orders by oldest first.
```
#158 - change doc type to transitional
```
due to &nbsp; not being valid in xhtml strict
```
#157 - db backup script
```
syntax error at /etc/cron.daily/tan_backup line 143, near "1) "
```
#156 - general errors
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
#155 - urls in comments can't be over 100 chars long
```
fix it, provide a new filter, use Data::Validate::URI
```
#154 - add vimeo video support
```
http://vimeo.com/12429821

<object width="400" height="225"><param name="allowfullscreen" value="true" /><param name="allowscriptaccess" value="always" /><param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=12429821&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" /><embed src="http://vimeo.com/moogaloop.swf?clip_id=12429821&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="400" height="225"></embed></object><p><a href="http://vimeo.com/12429821">Israeli Attack on the Mavi Marmara, May 31st 2010 // 15 min.</a> from <a href="http://vimeo.com/culturesofresist">Cultures of Resistance</a> on <a href="http://vimeo.com">Vimeo</a>.</p>
```
#153 - nsfw filter doesnt stay off
```
the cookie its in is a session cookie, make it last longer.
```
#152 - make a faq
```
make a faq
```
#151 - banned users
```
make sure they can't log in
```
#150 - move irc
```
its now irc.mibbit.com
```
#149 - header wrong in safari
```
its all over the show
```
#148 - rework old images redirect
```
for thumbs and for image files coz they're moved.

perhaps make leech proofer work more better with old images/thumbs
```
#147 - DBIx::Class::UTF8Columns is deprecated
```
http://search.cpan.org/~frew/DBIx-Class-0.08122/lib/DBIx/Class/UTF8Columns.pm

remove it and replace with ''mysql_enable_utf8'' connect flag
```
#146 - sitemap
```
remake sitemap generator
```
#145 - username is missing from pic on index
```
theres no username, but there is a avatar
```
#144 - page cache fucks up with utf8 data
```
damn it to hell!!!!
```
#143 - [video] bbcode
```
make it accept a hyperlink as well as plaintext url. i.e. make it tard proof :p
```
#142 - fix render die
```
they've changed the way it works, need to remove the renderclass end function and trap the exception and some other shit.

[http://search.cpan.org/~bobtfish/Catalyst-View-TT-0.34/lib/Catalyst/View/TT.pm#render%28$c,_$template,_\%args%29]

[http://search.cpan.org/~abw/Template-Toolkit-2.22/lib/Template/Exception.pm]
```
#141 - add sha512 for pictures
```
update convert script, add new field in db. update submit controller and redirect to pic if sha512 matches.
```
#140 - convert script
```
make it move images into a sub dir % time shit or something.

make old/new avatar, and old/new image dir env varible
```
#139 - remove links to user profile
```
since it doesn't exist yet
```
#138 - make convert script ordered
```
its not pulling records out in any order and it could be causing some missing pictures. fix
```
#137 - .htaccess
```
add .htaccess
```
#136 - image redirect
```
make anti-leech controller
```
#135 - seo confirm shizzle
```
add the confirm stuff for the search engines.
```
#134 - old article redirect
```
create controller for redirecting old articles to the new ones. 301 or w/e is best, i forget.
```
#133 - check all code
```
see what can be speeded up, refined, refactored etc etc
```
#132 - move registration into sub of login
```
move it from Login.pm to login/Registration.pm
```
#131 - create new js alert popup overlay thing
```
make it real simple like - but real obvious
```
#130 - forgot mail controller
```
make a password reset controller
```
#129 - up upload limit
```
3-4mb should do
```
#128 - sort by
```
make sort by bar ?order=
```
#127 - videos
```
live site supports more than just youtube links, upgrade new tan

possibly add new bbcode [video] tag (maybe not if timewise)
```
#126 - sql indexes
```
nothing is indexed

index as much as possible, like sort by, page numbers, comments, tin tans.

bassically just figure it all out
```
#125 - nsfw safe random image search
```
make it respect nsfw settings
```
#124 - picture bar
```
add the picture bar back
```
#123 - nsfw filter
```
update it to ignore the new smileys
```
#122 - thumb images look wrong
```
they dont look right, detect if image is a gif or not and convert accordingly
```
#121 - back to main
```
add bac kto main link somewhere
```
#120 - embedded videos
```
make more things embed with generic [video] bbcode
```
#119 - tin/tan comments
```
comments tin/tan
```
#118 - add notifaction area
```
use something existing
```
#117 - javascript
```
TAN class, add proper logger alert thingy, and a confirm thingy for somethign, i forget what, im tired but pretty sure its needed
```
#116 - add stats link
```
add link to stats
```
#115 - donation button
```
add donation button
```
#114 - css min thing
```
like whats there for the js
```
#113 - comments need more user info
```
like
 * comment number (figure this out)
 * joined etc
```
#112 - recent comments are xss'able
```
if you make a comment of <a href="blah blah" /> it will be a link in the preview. although, should the preview not be the actual comment?
```
#111 - promotion system
```
currently things don't get promoted
```
#110 - commenting broken
```
it reports it was made 40 days ago when posting via ajax
```
#109 - tags
```
make a tags index page
```
#108 - redirect controller
```
make redirect controller
```
#107 - XSS protection
```
currently the comments page is XSS vunerable

use HTML::StripScripts::Parser ( http://tinymce.moxiecode.com/punbb/viewtopic.php?id=6495 )


```
#106 - BBCode
```
Use Parse::BBCode to build a new BBCode module

blocks #42
```
#105 - ubuntu server
```
coz of the ubuntu on the live server, make a new dev box based on ubuntu, possibly from a backup of the live one
```
#104 - pod
```
write pod
```
#103 - user registration
```
rewrite the user registration stuff.
```
#102 - create image validator
```
 * blocks #38
 * Data::Validate::Image
 * use Image::Info
 * tests


```
#101 - fix db schema
```
old_lookup needs a type

plus_minus is mia
```
#100 - image caching
```
group it by `id - (id % 1000)`
```
#99 - images
```
make images go into a sub dir, split every 100 or so.
```
#98 - sitemap generator
```
update it
```
#97 - rate limit posting
```
make some kind of anti flood protection
```
#96 - add rewrite rules for old urls
```
things like pictures, smileys, anything else?
```
#95 - change dispatcher to use strpos
```
add a key string to the map, then to the preg_match if the strpos matches, should be much faster
```
#94 - smarter js inclusion
```
 * make it automatically adjust the revison
 * make it minify and cache
 * make cherokee rule to handle if cache exists
```
#93 - remote image upload
```
seems to be letting me put a link to the html page in, then dying coz its not an image. I guess the error handling shit aint working too good...

this was the link it dowloaded - http://img476.imageshack.us/i/banhammer15gq9.jpg/
```
#92 - ougoing link tracker
```
make an outgoing link tracker, and display it on the object
```
#91 - photo albums
```
photo albums, work just like indexes
```
#90 - logger
```
add open events logger
```
#89 - bulk content management
```
make all in one content management page
```
#88 - user management
```
add user management pages

 * ~~Delete Content~~
 * ~~Delete Avatar~~
 * ~~Delete~~

skipped

 * Change Username
 * Contact
```
#87 - rss feeds
```
everypage needs an rss feed
```
#86 - caching
```
cache as much as possible, also clear caches when needed
```
#85 - super cache
```
make a static html output cache for non-logged in users
```
#84 - error handler
```
write a proper error handling function

have it send emails to somekind of address (needs setting up)
```
#83 - tinymce
```
new fckeditor, ckeditor 3 - http://ckeditor.com/

 * reduce toolbar clutter when upgrade in progess
 * add some more smileys, including burger etc.
```
#82 - new htmlpurifier
```
upgrade to version 4 - http://htmlpurifier.org/
```
#81 - edit comment controller
```
make edit controller controller, should be simplish
```
#80 - chat controller
```
for none js users
```
#79 - random controller
```
make random controller
```
#78 - plus/minus
```
make plus minus controller and js
```
#77 - comments
```
comment system

make it post with ajax
```
#76 - nsfw filter
```
make nsfw filter
```
#75 - create f object
```
create it
```
#74 - dubstep
```

```
#73 - Carrot Cake
```
Refreshments

I'm thinking we should have more cakes, these meetings suck.


Also, fuck you
```
#72 - javascript
```
 * rewrite all the current javascript with moo.
 * remove all inline script, where possible
 * make comment posting work via ajax
```
#71 - Change database schema
```
 * make all things in the same table, requires some kind of old id field
 * write conversion tool
 * port existing code
 * add category support
```
#70 - categories
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
#69 - new indexes
```
create new index pages
```
#68 - tag_thumbs controller
```
blocks #38

submit tag thumb browser, make it paginated
```
#67 - youtube links should embed
```
use the bbcode code
```
#66 - page impressions
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
#65 - animated gifs in thumbs
```
make animated thumbs work. 
```
#64 - removed nsfw ads
```
they're slow and look really really really spammy.
```
#63 - strip all uploaded images
```
run strip on them

http://www.php.net/manual/en/function.imagick-stripimage.php
```
#62 - hide nsfw images in comments
```
 * hide all images in comments if filter is off
 * dont  hide smileys, perhaps add a class to them?
```
#61 - fix image leaching
```
a lot of images are being leached, fix it with mod rewrite.
```
#60 - upgrade edit_comment
```
its kind of a bastard child at the moment, get it fixed.
```
#59 - fix youtube
```
youtube is broken, replace the html output of the bbcode. also add [video] bbcode
```
#58 - edit submissions
```
write it
```
#57 - edit comments
```
rewrite it to use new code design
```
#56 - avatar uploader
```
make it use the new code layout
```
#55 - image resizer
```
rewrite it to use the new code stuff (model, controller) etc
```
#54 - remove forums
```
kill them good.
```
#53 - change promotion system
```
make it maths, score based

unique views, comments, tins, tans
compare for the previous 2 days

perhaps use submission date?

dont put live yet, just scores only.

add system of page views, unique ip only, xforwarded_for, user_id, date, referer
```
#52 - picture description cutoff on submit
```
its because its named pdescription on pics
```
#51 - fix "Invalid multibyte sequence in argument" in recent comments
```
its annoying
```
#50 - tag model
```
create tests for tag model
```
#49 - reduce page load time
```
its mostly coz of the ads.
causing javascript loading to be delayed
perhaps wrap in a on domready event thingy.
```
#48 - ad thing for tom
```
make widgit thing


```
#47 - remote image upload
```
write tests
```
#46 - switch to lighttpd
```
its about 2x faster than apache, and can use aio for turbo sends.

http://www.cyberciti.biz/tips/howto-increase-lighttpd-performance-with-linux-aio.html
dev-libs/libaio

Will need to use the dispatcher for this to work properly, and safely. as a side effect, this will also mean switching to fastcgi
```
#45 - block tor
```
''you can obtain the list in plain txt format updated every 5 minutes from Tor Network Status sites located in

the US
http://torstatus.kgprog.com/ip_list_exit.php

or

the Old Europe
http://torstatus.blutmagie.de/ip_list_exit.php''

write a perl script
```
#44 - investigate moving all code to dispatcher
```
see if its easy or not.
```
#43 - add more ads
```
yep.
```
#42 - new article pages
```
tags on page

new controller that redirects to link

edit box for non logged in users => login/registration

other shit

```
#41 - sql clone_db_for_testing
```
part of #40 really, make a function that clones every table in the db.

create temporary table log_t like log;
alter table log_t rename log;
```
#40 - unit tests
```
Make unit tests for the models
```
#39 - new index pages
```
break up into MVC, include all menu option
```
#38 - new submit pages
```
the submissions pages need cleaning up and templating etc
```
#37 - new shit
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
#36 - create new cache model
```
basic interface to memcache
```
#35 - create basic object model
```
called
 m_object
needs several functions:

 * get_page_list
 * get_object_details
 * get_meplusminus

```
#34 - Add lightwindow
```
Add it for login/registration page, probably other stuff, but dunno what.
```
#33 - add comment box for non logged in users
```
Allow the comment box on the page for non logged in users, then mark the comment as hidden in the db (add column) and change upon login/registration.

 * add hidden, date_hidden columns to comments table
 * make hidden comments not show
 * add code to docomment.php
 * add registration complete comment code 
 * add cron job that deletes old hidden comments (+72 hours)

Sit back and relax!
```
#32 - backup trac
```
use rsync, its pretty easy
```
#31 - system upgrades
```
Upgrade the servers/desktops etc
```
#30 - install nagios
```
could do with being on all the servers since its enterprise class, maybe [ http://beginlinux.com/blog/2008/11/install-nagios-3-on-ubuntu-810/ this ] will be of use 
```
#29 - impliment object caching
```
depends on #27, #28

 * use [ http://uk3.php.net/memcache this ] and cache as much as possible
 * make content page cached untill more comments in the cache, use name scheme like {{{ {$type}{$id}{$comment_count} }}}
 * default cache time for 5 mins (perhaps more, test and find out)

```
#28 - add edit_time column to most table's
```
need a edit_time column to pretty much all the tables (all the ones that need it anyway).
```
#27 - install memcached
```
needs to be installed
```
#26 - move page order around
```
look at the site in links, its not nice, and thats what google sees! reorder.
```
#25 - etags
```
should be based on the file mtime and some other shit. md5 is slow
```
#24 - pagination
```
needs to only show +- 5 pages
```
#23 - log is fucked.
```
its not puttin comment_id in the db, and the link_id its putting in is wrong, so the others might be too.
```
#22 - fix titles in article page + add goto url
```
 * add url that redircts to the story
  * counts the view 
  * perhaps opens the page in some kind of frame

 * make the title in the article <h1> rather than a link back to the article
```
#21 - clamav + spamassisin for email
```
get it set up
```
#20 - email2trac
```
set this up, or something similar

https://subtrac.sara.nl/oss/email2trac
```
#19 - comments
```
when theres no comments and your not logged in it looks shit
```
#18 - add scriptaculous
```
will require .htaccess mod rewrite stuff + code/script.php changes
```
#17 - shells comp
```
'''
== fix shells comp! ==
'''
```
#16 - add phpdoc to trac
```
get the plugin and get it done
```
#15 - plus_minus tracker
```
ppl need to be able to see who plus'd what
```
#14 - fix pagination
```
its broken, fix it
```
#13 - edit page
```
make a page so things can be edited
```
#12 - impliment session flash
```
or similar, then improve messages everywhere, eg, submit, login, login fail, logout etc
```
#11 - email verifaction
```
impliment email verifaction with a  long random number  + new db table.
```
#10 - add user setting page
```
wghere can upload avatar, set timezone, email, password, notifcations + etc
```
#9 - tags
```
each item wants a list of the tags associated with it
```
#8 - mixed front page
```
need to impliment a mixed front page, and relivent sections.
```
#7 - editorials
```
like most things just needs finishing, basically just blogs thats have the is_ed flag set
```
#6 - improve side menu
```
Its bloated sql atm, needs stripping down
Also needs more details, no. comments, pic thumbnail, border, etc.

fancy log view javascript slider thing
```
#5 - log stuff
```
new users, new comments, new links/blogs/pics new promotions

```
#4 - finish profile page
```
should have list of submitted, plus, minus, comment etc
needs settings page so can set timezone, avatar othershit


mostly done, just needs submitted stuff, settings and links sorting, and htacces rewrites
```
#3 - set max font size
```
at the moment theres no limit on the max font size in comments. Needs to be fixed
```
#2 - make blogs more readable
```
add rounded section for blogs, perhaps with the title as well
```
#1 - test
```
test
```
