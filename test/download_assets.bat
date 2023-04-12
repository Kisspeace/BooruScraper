@ECHO OFF
SET download_dir=temp\
@MKDIR %download_dir% 

call :add dbbepismoe "https://db.bepis.moe/koikatsu" "https://db.bepis.moe/koikatsu/view/303101"
call :add bleachbooru "https://bleachbooru.org/posts?page=1" "https://bleachbooru.org/posts/68270"
call :add rule34pahealnet "https://rule34.paheal.net/post/list/1" "https://rule34.paheal.net/post/view/5519344"
call :add danbooru "https://danbooru.donmai.us/posts?page=1" "https://danbooru.donmai.us/posts/6086433?q=order%%3Arank"
call :add r34xxx "https://rule34.xxx/index.php?page=post&s=list&tags=all" "https://rule34.xxx/index.php?page=post&s=view&id=7160782"
call :add gelbooru "https://gelbooru.com/index.php?page=post&s=list&tags=all" "https://gelbooru.com/index.php?page=post&s=view&id=6543942"
call :add realbooru "https://realbooru.com/index.php?page=post&s=list" "https://realbooru.com/index.php?page=post&s=view&id=818083"
call :add rule34us "https://rule34.us/index.php?r=posts/index&q=all" "https://rule34.us/index.php?r=posts/view&id=4308147"

EXIT /B 0

:add
    
    SET name=%1
    SET url_list=%2
	SET url_post=%3
    echo "-- DOWNLOADING %name%"

    curl -fo "%download_dir%%name%_list.html" %url_list%
	curl -fo "%download_dir%%name%_post.html" %url_post%

EXIT /B 0