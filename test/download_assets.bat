@ECHO OFF
SET download_dir=temp\
SET useragent="Mozilla/5.0 (Windows NT 10.0; rv:114.0) Gecko/20100101 Firefox/114.0"
SET timeouts=3
@MKDIR %download_dir%

call :add e621 "https://e621.net/posts?tags=equine_penis+female" "https://e621.net/posts/4131064?q=equine_penis+female" ""
call :add kenzatouk "https://kenzato.uk/booru/explore/recent" "https://kenzato.uk/booru/image/GdhwKa" "AGREE_CONSENT=1; CHV_COOKIE_LAW_DISPLAY=0;"
call :add dbbepismoe "https://db.bepis.moe/koikatsu?orderby=popularity" "https://db.bepis.moe/koikatsu/view/303101" ""
call :add bleachbooru "https://bleachbooru.org/posts?page=1" "https://bleachbooru.org/posts/68270" ""
call :add rule34pahealnet "https://rule34.paheal.net/post/list/1" "https://rule34.paheal.net/post/view/5519344" ""
call :add danbooru "https://danbooru.donmai.us/posts?page=1" "https://danbooru.donmai.us/posts/6086433?q=order%%3Arank" ""
call :add r34xxx "https://rule34.xxx/index.php?page=post&s=list&tags=all" "https://rule34.xxx/index.php?page=post&s=view&id=7160782" ""
call :add gelbooru "https://gelbooru.com/index.php?page=post&s=list&tags=all" "https://gelbooru.com/index.php?page=post&s=view&id=6543942" ""
call :add realbooru "https://realbooru.com/index.php?page=post&s=list" "https://realbooru.com/index.php?page=post&s=view&id=818083" ""
call :add rule34us "https://rule34.us/index.php?r=posts/index&q=all" "https://rule34.us/index.php?r=posts/view&id=4308147" ""

EXIT /B 0

:add
    
    SET name=%1
    SET url_list=%2
	SET url_post=%3
	SET cookie=%4
    echo "-- DOWNLOADING %name%"

    curl -# -fo "%download_dir%%name%_list.html" %url_list% --cookie %cookie% --user-agent %useragent% --connect-timeout %timeouts%
	curl -# -fo "%download_dir%%name%_post.html" %url_post% --cookie %cookie% --user-agent %useragent% --connect-timeout %timeouts%

EXIT /B 0