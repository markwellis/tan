USER=www-data
LIB="-I /mnt/stuff/perl_lib/lib/perl5"

#perl $LIB /var/www/thisaintnews.com/htdocs2/script/workers/search/search.pl stop > /dev/null 2>&1
#perl $LIB /var/www/thisaintnews.com/htdocs2/script/workers/search/search.pl start -u $USER > /dev/null 2>&1

perl $LIB /var/www/thisaintnews.com/htdocs2/script/workers/sitemap/sitemap.pl stop > /dev/null 2>&1
perl $LIB /var/www/thisaintnews.com/htdocs2/script/workers/sitemap/sitemap.pl start -u $USER > /dev/null 2>&1

perl $LIB /var/www/thisaintnews.com/htdocs2/script/workers/twitter/twitter.pl stop -u $USER > /dev/null 2>&1
perl $LIB /var/www/thisaintnews.com/htdocs2/script/workers/twitter/twitter.pl start -u $USER > /dev/null 2>&1
