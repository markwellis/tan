# TAN
Social news website/forum/cms that used to run at [thisaintnews.com](https://thisaintnews.com)

## Quick history of the code
TAN is written in Perl, using the [Catalyst MVC Framework](https://metacpan.org/pod/Catalyst::Manual) and the [DBIx::Class](https://metacpan.org/pod/DBIx::Class) ORM. It uses [Carton](https://metacpan.org/pod/Carton) for dependency management

It's something I knocked up over the years. It's good at the job it does, but it's over 10 years old.

The first commit was 10-Sep-2008 and this was PHP code.
I started the move to Perl a year later on 27-Sep-2009. That's the version that still runs today.

Hopefully the documentation below is enough to get started. It's a bit of a mess as I've hacked it up mostly from memory quite quickly.

# Archived assets
[Here's a link to download a db dump (personal info and usernames anonymised) and uploaded images.](https://web.tresorit.com/l#ZsDSVmFC6qzTuJ2vtg9QGw)
## To restore a db dump
```
vagrant ssh
sudo -iu postgres pg_restore -d tan -c /path/to/tan_db.psql
```

## To restore images
Put them in `root/static/user/pics`

## Rebuild search index
Run `carton exec -- perl -I lib/ bin/create_search_index.pl` to rebuild the search index

# Development
## Ticket numbers
In the git commit log you'll see commits that start with `#NUMBER` - these are ticket references. I've created a dump of the ticket db in [tickets.md](tickets.md)

## Running
There's a [vagrant](https://www.vagrantup.com/) setup to run locally.

Run `vagrant up` and go make a brew. That will download a linux vm, configure it and install the dependencies needed to run TAN.

Once that's done, run the following to start the TAN service.

```
vagrant ssh
pushd /vagrant
CATALYST_DEBUG=1 carton exec -- plackup -l 0.0.0.0:8081 -E development --no-default-middleware tan.psgi
```

site will be available at https://faketan.test/

## Running scripts
You'll have to run perl scripts with `carton exec -- perl -I lib/`. Otherwise you'll get missing library errors.

There's a bunch in `bin/` and some more in `script/`

### create_search_index.pl
creates the search index

### create_smilies_json.pl
creates json for the files in `root/static/smilies/`. json needs manually adding to `root/static/tiny_mce_plugins/smilies/smilies.html`

### db_manager.pl
manages the db migrations

### dbdump.pl
dumps the db schema to dbix

### deploy.pl
used to deploy the code to the servers

### mass_undelete.pl
undoes an admin mass undelete based on the admin_log.bulk db table contents

### update_triggers_scores.pl
rebuilds the scores for submitted content

## Connect to the DB
Database is postgres. Connect with these commands
```
vagrant ssh
sudo -iu postgres psql tan
```

## To register a user
get a recaptcha v2 key from http://www.google.com/recaptcha/admin

add the keys to `tan_local.yml` (see `tan_local.yml.example` for the correct format)

If the registration email doesn't arrive, you can get the confirmation link by doing the following

get the message id from
```
sudo mailq
```

and replace XXXXXXX with it here
```
sudo postcat -q XXXXXXX
```

see here for more info
http://www.tech-g.com/2012/07/15/inspecting-postfixs-email-queue/

## To give your user admin rights
connect to the db and run the following:

*replace _$USERNAME_ with you newly registered user's username*
```pgsql
insert into user_admin(user_id, admin_id) select user_id, unnest(array[1,2,3,4,6,9,11,12]) id from "user" where username = '$USERNAME';
```

there are currently a few roles defined. See the list with this query
```pgsql
select * from admin;
```

# How it all works
## Code
The code is in `lib/TAN/`.

The DB models are in `lib/TAN/Schema`

## Database
Database is postgres.

Migrations are in `migrations/`. They use a custom db migration manager, which is in `bin/db_manager.pl`/

There's a script `bin/dbdump.pl` that will dump the database schema to the DBIx::Class models

## Tests
There are some tests in the `t/` dir. Run with `prove -v t/`

## Sessions
Sessions are stored on disk. These days Redis would be the place to store them, but back then this made a lot of sense.

## Caching
The cache is memcached.

The strategy is to cache individual things, and not full pages. It means when an index page loads, it loads a list of things on that page, then the items in that list. both are cached. The index list cache is removed when something makes a change that would impact that page. This is done using a system of events and triggers.

## Users
Passwords are PBKDF2.

Salt is stored outside of the db in the `/var/www/vhosts/thisaintnews.com/share/salt/` directory. This is hardcoded in `lib/TAN/Schema/Result/User.pm`:101

## Search

Search uses [Lucy](https://metacpan.org/pod/release/CREAMYG/Lucy-0.4.2/lib/Lucy.pod). The search index is stored in `share/search_index` as defined by the config option `Model::Search.args.index_path`

Items are added to the index on submission asynchronously via a [gearman worker](#search-worker).

## Workers
There 3 workers in the `script/workers` directory.

Workers run via [gearman](http://gearman.org/).

There's a script to start a worker in `script/system/start_tan_worker.sh`. It takes 1 argument, the name of the worker to start.

### Search Worker
Adds things to the search index.

### Sitemap Worker
Pings search engines when the sitemap is updated.

### Twitter Worker
Spams twitter when something is promoted or something I forget. Doesn't seem to work anymore anyway.

## Directories of interest
Login salts are stored in the following dir. This is hardcoded and not a config option `/var/www/vhosts/thisaintnews.com/share/salt/`

Sessions are stored in `share/sessions` as defined by the config option `Plugin::Session.storage`

Static assets are stored in `root/static`

User uploaded pictures are stored in `root/static/user/pics`

User avatars are stored in `root/static/user/avatar`

Minified CSS & JS assets are cached in `root/static/cache/minify`

Picture thumbnails are cached in `root/static/cache/thumbs`

Workers are in `script/workers`
