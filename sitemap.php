<?php
/*
 * Created on 19 Oct 2008
 *
 * Sitemap.php 
 * Generates a google sitemap.xml
 */
  
define('MAGIC', null);
require_once("code/unified.php"); 
header ("content-type: text/xml");
?>

<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
<url>
<loc>http://thisaintnews.com/</loc>
<priority>1.00</priority>
<changefreq>daily</changefreq>
</url>
<url>
<loc>http://thisaintnews.com/link/0/1/0/</loc>
<priority>0.80</priority>
<changefreq>daily</changefreq>
</url>
<url>
<loc>http://thisaintnews.com/link/1/1/0/</loc>
<priority>0.80</priority>
<changefreq>daily</changefreq>
</url>
<url>
<loc>http://thisaintnews.com/blog/0/1/0/</loc>
<priority>0.80</priority>
<changefreq>daily</changefreq>
</url>
<url>
<loc>http://thisaintnews.com/blog/1/1/0/</loc>
<priority>0.80</priority>
<changefreq>daily</changefreq>
</url>
<url>
<loc>http://thisaintnews.com/picture/0/1/0/</loc>
<priority>0.80</priority>
<changefreq>daily</changefreq>
</url>
<url>
<loc>http://thisaintnews.com/picture/1/1/0/</loc>
<priority>0.80</priority>
<changefreq>daily</changefreq>
</url>

<?php
$links = unified::getAllObjects('link_details');
$pictures = unified::getAllObjects('picture_details');
$blogs = unified::getAllObjects('blog_details');
foreach ($links as $linkdetails){
    print "<url>
        <loc>http://thisaintnews.com/viewlink/{$linkdetails['link_id']}/".
        user::cleanTitle($linkdetails['title'])."/</loc>
        <priority>0.80</priority>
        <changefreq>always</changefreq>
        </url>";
}
foreach ($blogs as $blogdetails){
    print "<url>
        <loc>http://thisaintnews.com/viewblog/{$blogdetails['blog_id']}/".
        user::cleanTitle($blogdetails['title'])."/</loc>
        <priority>0.80</priority>
        <changefreq>always</changefreq>
        </url>";
}
foreach ($pictures as $picdetails){
    print "<url>
        <loc>http://thisaintnews.com/viewpic/{$picdetails['picture_id']}/".
        user::cleanTitle($picdetails['title'])."/</loc>
        <priority>0.80</priority>
        <changefreq>always</changefreq>
        </url>";
}
?>
</urlset>
