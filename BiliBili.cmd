 @(
	Echo off
	Color F0
	Chcp 65001 >nul
	If not "!OS!"=="%OS%" SetLocal EnableDelayedExpansion,EnableExtensions
	Set "UA=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4100.3 Safari/537.36"
	Set "Path=%~dp0Modules;%Path%"
	Cd "%~dp0"
)
For /f "usebackq delims=" %%a in ("%~dp0Modules\Language.pkg") do (
	Set "x%%a"
)

Title !xtitle1!

::创建文件夹，检查文件是否完全
For %%a in (Download,Temp) do (
	If not exist "%~dp0%%a\" (
		Md "%~dp0%%a\"
	)
) >nul 2>nul
If not "%~1"=="" Goto :%*
For %%a in (aria2c.exe,curl.exe,ffplay.exe,libcurl.dll,sed.exe,encode.js) do (
	If not exist "%~dp0Modules\%%a" (
		Goto :Error_3
	)
)

:Main
::主页
Call :UIShell
(
Cls
Echo.
Echo.  !xtitle1!
Echo.!UnLine!
Echo.
Echo.
Echo.	!x1!
Echo.
Echo.
Echo.	!x2!
Echo.
Echo.
Echo.	!x3!
Echo.
Echo.
Echo.	!x4!
Echo.
Echo.
Echo.
)
Choice /c SALC /n /m "!xc!"
Set "Choice=!ErrorLevel!"
For %%c in (1:Search,2:ISVideos,3:LocalPlay,4:Config) do (
	For /f "tokens=1,2 delims=:" %%a in ("%%~c") do (
		If "!Choice!"=="%%~a" (
			Call :%%b
		)
	)
)
Goto :Main

:ISVideos
::站内视频
Call :UIShell
(
Cls
Echo.
Echo.  !xtitle2!
Echo.!UnLine!
Echo.
Echo.
Echo.
Echo.
Echo.	!x5!

Echo.	!x6!

Echo.	!x7!
Echo.
Set "KW="
Set /p "KW=.	!xs!"
)
If "!KW!"=="" Goto :Eof
(
Cls
Echo.
Echo.  !xtitle2!
Echo.!UnLine!
Echo.
Echo.
Echo.	!x8!
Echo.
)
::判断是AV号还是BV号，然后获取视频相关数据
If /i "!KW:~0,2!"=="av" Set "KW=!KW:~2!"
Del /f /q "%~dp0Temp\VideoInfo.json" >nul 2>nul
For /l %%a in (1,1,9) do (
	If "!KW:~0,1!"=="%%a" (
		curl -A "!UA!" -e "https://www.bilibili.com/video/!KW!" -o "%~dp0Temp\VideoInfo.json" "https://api.bilibili.com/x/player/view?aid=!KW!"
		If not exist "%~dp0Temp\VideoInfo.json" Goto :Error_2
	) >nul 2>nul
)
If /i "!KW:~0,2!"=="BV" (
	curl -A "!UA!" -e "https://www.bilibili.com/video/!KW!" -o "%~dp0Temp\VideoInfo.json" "https://api.bilibili.com/x/player/view?bvid=!KW!"
	If not exist "%~dp0Temp\VideoInfo.json" Goto :Error_2
) >nul 2>nul
sed -i "s/},/},\n/g" "%~dp0Temp\VideoInfo.json"
sed -i "s/{/{\n/g" "%~dp0Temp\VideoInfo.json"
:Re1
Set /a R=0,NN=0
For /f "usebackq tokens=1-26 delims=:," %%a in ("%~dp0Temp\VideoInfo.json") do (
	If "%%~a"=="code" (
		If not "%%~b"=="0" Goto :Error_1
	) else If "%%~a"=="aid" (
		If "!R!"=="0" (
			Set "aid=%%~b"
			Set "videos=%%~d"
			Set "title=%%~o"
			Set "desc=%%~u"
			If not "%%~v"=="state" (
				Set "desc=!desc!:%%~v"
				If not "%%~w"=="state" (
					Set "desc=!desc!:%%~w"
					If not "%%~x"=="state" (
						Set "desc=!desc!:%%~x"
						If not "%%~y"=="state" Set "desc=!desc!:%%~y"
					)
				)
			)
			Set /a R+=1
		) else If "!R!"=="1" (
			Set "view=%%~d"			%=浏览量=%
			Set "danmaku=%%~f"		%=弹幕数量=%
			Set "reply=%%~h"		%=回复=%
			Set "favorite=%%~j"		%=收藏=%
			Set "coin=%%~l"			%=硬币=%
			Set "share=%%~n"		%=分享=%
			Set "like=%%~t"			%=喜欢=%
		)
	) else If "%%~a"=="mid" (
		Set /a NN+=1
		Set "name!NN!=%%~d"
	) else If "%%~a"=="bvid" (
		Set "bvid=%%~b"
	) else If "%%~a"=="attribute_v2" (
		Set "bvid=%%~d"
	) else If "%%~a"=="season_id" (
		Set "bvid=%%~d"
	) else If "%%~a"=="cid" (
		Set "page=%%~d"
		Set "cid!page!=%%~b"
		Set "part!page!=%%~h"
		Set "vid!page!=%%~l"
	)
)
::设CL=换行符
Set CL=^


::大于等于1万的数据以“万”作为单位
For %%a in (view,danmaku,reply,favorite,coin,share,like) do (
	If !%%a! GEQ 10000 (
		Set /a P=!%%a! / 1000
		Set "p1=!P:~0,-1!"
		Set "p2=!P:~-1!"
		Set "%%a=!p1!.!p2! 万"
	)
)
Goto :MoreAboutVideo

:MoreAboutVideo
Call :UIShell
(
Cls
Echo.
Echo.  !xtitle3!
Echo.!UnLine!
Echo.
Echo.    !title!
Echo.
Echo.	!x9!!videos!
Echo.	!x10!!name1!
If not "!NN!"=="1" (
	Set /a NNA=!NN!-1
	Echo.	      !x11! !NNA! !x12!
)
Echo.	!x38!
For %%a in ("!CL!") do (
	Set "desc=!desc:\n=%%a!"
	Echo.	!desc:"=	!
)
Echo.
Echo.	!view!!x13!!danmaku!!x14!!bvid!
Echo.
Echo.	!x15!!like!	!x16!!coin!
Echo.	!x17!!favorite!	!x18!!share!
Echo.
Echo.    !x19!
)
Set RA=0
Set "Ec="
For /l %%a in (1,1,!videos!) do (
	If !RA! LSS 4 (
		Set /a RA+=1
		Set "Ec=!Ec!%%a.!part%%a!	"
	) else (
		Set /a RA=0
		Set "Ec=!Ec!%%a.!part%%a!"
		Echo.	!Ec!
		Set "Ec="
	)
)
If not "!RA!"=="0" (
	Echo.	!EC!
)
Echo.
Echo.	!x20!
Echo.	!x21!
Echo.
Set "Episode="
Set /p "Episode=!xs!"
If "!Episode!"=="" Goto :MoreAboutVideo
If /i "!Episode!"=="B" Goto :ISVideos
::将数据进一步调整，然后调用解析引擎
For /l %%a in (1,1,!videos!) do (
	If "!Episode!"=="%%a" (
		Set "bangumi=False"
		Set "big_title=!title!"
		Set "cid=!cid%%a!"
		Set "epid="
		Set "long_title=!part%%a!"
		Set "suffix=_!Episode!"
		Set "title=!Episode!"
		Set "url=https://www.bilibili.com/video/!bvid!"
		Call :Normal_Run
	)
)
Goto :Re1

:Search
::番剧搜索
Call :UIShell
(
Cls
Echo.
Echo.  !xtitle4!
Echo.!UnLine!
Echo.
Echo.
Echo.
Echo.
Echo.
Echo.
Echo. 	!x7!
Echo.
Set "KW="
Set /p "KW=.	!xs!"
)
If "!KW!"=="" Goto :Eof
Set "R=False"
Call :UIShell
::提前判定部分内容的显示字数，配合窗口宽度
Set /a Col=%Cols%-6
Set /a Col1=%Col%/2-2
If exist "%~dp0Temp\Search.json" (
	For /f "usebackq tokens=1,* delims==" %%a in ("%~dp0Temp\Search.json") do (
		If "%%a"=="Download_Cache_Name" (
			If "%%b"=="!KW!" (
				Set "R=True"
			)
		) else If "!R!"=="True" (
			If "%%a"=="Download_Cache_Date" (
				If "%%b"=="!Date!" (
					Goto :CacheForSearch
				)
			)
		)
	)
)
Del /q "Temp\*" >nul 2>nul
::输入内容转Url编码
For /f %%a in ('cscript -nologo -e:jscript %~dp0Modules\encode.js "!KW!"') do Set UrlCode=%%a
Set /a Page=1
:Search_Begin
(
Cls
Echo.
Echo.  !xtitle4!
Echo.!UnLine!
Echo.
Echo.
Echo.	!x22!
Echo.
)
::调用搜索API，抓取相关数据
Del /q "%~dp0Temp\Search.json" >nul 2>nul
curl -A "!UA!" -e "https://search.bilibili.com/bangumi?keyword=!UrlCode!" -o "%~dp0Temp\Search.json" "https://api.bilibili.com/x/web-interface/search/type?context=&keyword=!UrlCode!&page=!Page!&search_type=media_bangumi&changing=id&__refresh__=true&__reload__=false&highlight=1&single_column=0&jsonp=jsonp&callback=__jp0" >nul 2>nul
If not exist "%~dp0Temp\Search.json" Goto :Error_2
sed -i "s/,/\n/g" "%~dp0Temp\Search.json"
sed -i "s/}/\n}/g" "%~dp0Temp\Search.json"
sed -i "s/{/{\n/g" "%~dp0Temp\Search.json"
:Wait
If exist "%~dp0Temp\sed*" (
	Timeout /t 1
	Goto :Wait
)
(
	Echo.
	Echo.Download_Cache_Name=!KW!
	Echo.Download_Cache_Date=!Date!
) >>"%~dp0Temp\Search.json"
:CacheForSearch
Set /a Num=0,R=0
For /l %%a in (1,1,20) do (
	Set "N%%a="
)
For /f "usebackq tokens=1,* delims=:" %%a in ("%~dp0Temp\Search.json") do (
	If "!R!"=="0" (
		If "%%~a"=="numPages" (
			Set "numPages=%%~b"
			Set /a R=1
		) else If "%%~a"=="numResults" (
			Set "numResults=%%~b"
		) else If "%%~a"=="page" (
			Set "pagefor=%%~b"
		)
	) else (
		If "%%~a"=="season_id" (
			Set "ss=%%~b"
			Set /a Num+=1
			Set "N!Num!=%%~b"
		) else If "%%~a"=="title" (
			If not defined title!ss! (
				Set "title.temp=%%~b"
				For %%c in ("\u003cem class=","\"keyword\"","\u003e","/em","\u003c") do (
					Set "title.temp=!title.temp:%%~c=!"
				)
				For /l %%c in (0,1,99) do (
					If "!title.temp:~%%c,1!"=="=" (
						Set /a c1=%%c+2
						For %%d in (!c1!) do (
							Set "title.temp=!title.temp:~0,%%c!!title.temp:~%%d!"
						)
					)
				)
				Set "title!ss!=!title.temp!"
			)
		) else (
			For %%c in (areas,styles,score,season_type_name,ep_size) do (
				If "%%~a"=="%%c" (
					Set "%%c!ss!=%%~b"
				)
			)
			For %%c in (cv,staff,desc) do (
				If "%%~a"=="%%c" (
					Set "%%c.temp=%%~b"
					Set "%%c.temp=!%%c.temp:\n= !"
					Set "%%c!ss!=!%%c.temp!"
					If "%%~a"=="desc" (
						If not "!%%c.temp:~%Col%,1!"=="" (
							Set "%%cr!ss!=!%%c.temp:~0,%Col%!…"
						) else Set "%%cr!ss!=!%%c.temp!"
					) else If "%%~a"=="cv" (
						If not "!%%c.temp:~%Col1%,1!"=="" (
							Set "%%cr!ss!=!%%c.temp:~0,%Col1%!…"
						) else Set "%%cr!ss!=!%%c.temp!"
					)
				)
			)
		)
	)
)

:Search_Results
Call :UIShell
(
Cls
Echo.
Echo.  !xtitle4!
Echo.!UnLine!
Echo.
)
If "!N1!"=="" (
	Echo.	!x23!
	Echo.
	Echo.!x24!
	Pause >nul
	Goto :Search
)
For /l %%a in (1,1,20) do (
	If not "!N%%a!"=="" (
		Set "N=%%a"
		Call :SR_Back !N%%a!
	)
)
Echo.
Echo.	!x25! !pagefor! !x26! !numPages! !x27!

Echo.	!x28! !numResults! !x29!

Echo.	!x30!
Echo.	!x31!	!x32!	!x33!
Echo.
Set ID=
Set /p "ID=!xs!"
If "!ID!"=="" Goto :Search_Results
If /i "!ID!"=="B" Goto :Search
If /i "!ID!"=="U" (
	If not "!page!"=="1" (
		Set /a page-=1
		Goto :Search_Begin
	) else Goto :Search_Results
)
If /i "!ID!"=="N" (
	If !page! LSS !numPages! (
		Set /a page+=1
		Goto :Search_Begin
	) else Goto :Search_Results
)
For /l %%a in (1,1,20) do (
	If "%%a"=="!ID!" (
		Goto :MoreAboutBangumi
	)
)
Goto :Search_Results
:SR_Back
(
Echo. !x34!!N!	ss%1
Echo. !season_type_name%1!：!title%1!
Echo.  !x9!!ep_size%1!
Echo.  !x35!!styles%1!	!x36!!areas%1!
Echo.  !x37!!cvr%1!
Echo.  !x38!!descr%1!
Echo.
)
Goto :Eof

:MoreAboutBangumi
(
Cls
Echo.
Echo.  !xtitle5!
Echo.!UnLine!
Echo.
Echo.
Echo.	!x8!
Echo.
)
Set "ssid=!N%ID%!"
Set /a R=0,Num1=0
For /l %%a in (1,1,!ep_size%ssid%!) do (
	For %%b in (aepid,at,alt,au,aid,bvid,bangumi,cid) do (
		Set "%%b%%a="
	)
)
::进一步抓取数据
For /f "usebackq tokens=1,* delims=:" %%a in ("%~dp0Temp\Search.json") do (
	If "!R!"=="0" (
		If "%%~a"=="season_id" (
			If "%%~b"=="!ssid!" (
				Set /a R+=1
			)
		)
	) else If "!R!"=="1" (
		If "%%~a"=="title" (
			Set /a R+=1
		)
	) else If "!R!"=="2" (
		If "%%~a"=="id" (
			Set /a Num1+=1
			Set "aepid!Num1!=%%~b"
		) else If "%%~a"=="title" (
			Set "at!Num1!=%%~b"
		) else If "%%~a"=="url" (
			Set "au!Num1!=%%~b"
		) else If "%%~a"=="long_title" (
			Set "alt!Num1!=%%~b"
		) else If "%%~a"=="media_id" (
			Goto :N
		)
	)
)
:N
Del /q "%~dp0Temp\Play.html" >nul 2>nul
aria2c -o "Temp\Play.html" "!au1!" >nul 2>nul
If not exist "%~dp0Temp\Play.html" Goto :Error_2
sed -i "s/\n/\r\n/g" "%~dp0Temp\Play.html"
sed -i "s/,/\n/g" "%~dp0Temp\Play.html"
sed -i "s/}/\n}/g" "%~dp0Temp\Play.html"
sed -i "s/{/{\n/g" "%~dp0Temp\Play.html"
Set /a R=0,ID=0
For /f "usebackq eol=< tokens=1,* delims=:" %%a in ("%~dp0Temp\Play.html") do (
	If "!R!"=="0" (
		If "%%~a"=="session" (
			Set "session=%%~b"
		) else If "%%~a"=="epList" (
			Set /a R+=1
		)
	) else If "!R!"=="1" (
		If "%%~a"=="id" (
			Set /a ID+=1
		) else If "%%~a"=="aid" (
			Set "aid!ID!=%%~b"
		) else If "%%~a"=="bvid" (
			Set "bvid!ID!=%%~b"
		) else If "%%~a"=="cid" (
			Set "cid!ID!=%%~b"
		) else If "%%~a"=="epInfo" (
			Set /a R+=1
			Goto :MAB_True
		)
	)
)

:MAB_True
Call :UIShell
(
Cls
Echo.
Echo.  !xtitle5!
Echo.!UnLine!
Echo.
Echo.    !title%ssid%!
Echo.
Echo.	!x9!!ep_size%ssid%!
Echo.	!x35!!styles%ssid%!	!x36!!areas%ssid%!
Echo.	!x39!!staff%ssid%!
Echo.	!x37!!cv%ssid%!
Echo.	!x38!!desc%ssid%!
Echo.
Echo.    !x19!
)
Set RA=0
Set "Ec="
For /l %%a in (1,1,!ep_size%ssid%!) do (
	If !RA! LSS 4 (
		Set /a RA+=1
		Set "Ec=!Ec!%%a.!at%%a!	"
	) else (
		Set /a RA=0
		Set "Ec=!Ec!%%a.!at%%a!"
		Echo.	!Ec!
		Set "Ec="
	)
)
If not "!RA!"=="0" (
	Echo.	!EC!
)
Echo.
Echo.	!x20!
Echo.	!x21!
Echo.
Set /p "Episode=!xs!"
If "!Episode!"=="" Goto :MA_True
If /i "!Episode!"=="B" Goto :Search_Results
::将数据进一步调整，然后调用解析引擎
For /l %%a in (1,1,!ep_size%ssid%!) do (
	If "!Episode!"=="%%a" (
		Set "bangumi=True"
		Set "aid=!aid%%a!"
		Set "bvid=!bvid%%a!"
		Set "big_title=!title%ssid%!"
		Set "cid=!cid%%a!"
		Set "epid=!aepid%%a!"
		Set "long_title=!alt%%a!"
		Set "title=!at%%a!"
		Set "suffix=_!Episode!"
		Call :Normal_Run
	)
)
Goto :MAB_True

:Normal_Run
::视频解析引擎（核心部分）
(
Cls
Echo.
Echo.  !xtitle6!
Echo.!UnLine!
Echo.
Echo.
Echo.	!title!：!long_title!
Echo.
Echo.	!x40!
Echo.
Echo.	!x41!
Echo.
Echo.	!x42!
Echo.
Echo.
)
Choice /c 123 /n /m "!xc!"
Set "Choice=!ErrorLevel!"
::判定是否播放视频
If "!Choice!"=="1" Set "DPlay=True"
If "!Choice!"=="2" Set "DPlay=False"
If "!Choice!"=="3" Goto :Eof
(
Cls
Echo.
Echo.  !xtitle6!
Echo.!UnLine!
Echo.
Echo.
Echo.	!title!：!long_title!
Echo.
)
:RunTrue
::获取用户配置
Set /p="!x63!" <nul
Call :ConfigGet Get
Echo.!x44!
Set /p="!x43!" <nul
Set /a NumV=0,NumAll=0,T=0,C=0,D=1,NV=0
Set "FromImo=False"
::文件名特殊字符剔除（比较麻烦，懒得枚举）
For %%a in (big,long) do (
	Set "%%a_title=!%%a_title: =-!"
	Set "%%a_title=!%%a_title:/=!"
	Set "%%a_title=!%%a_title:\=!"
	Set "%%a_title=!%%a_title:?=!"
	Set "%%a_title=!%%a_title:"=!"
	Set "%%a_title=!%%a_title:>=!"
	Set "%%a_title=!%%a_title:<=!"
	Set "%%a_title=!%%a_title:|=!"
	For /l %%c in (0,1,100) do (
		If "!%%a_title:~%%c,1!"==":" (
			Set /a b=%%c+1
			For %%b in (!b!) do (
				Set "%%a_title=!%%a_title:~0,%%c!：!%%a_title:~%%b!"
			)
		)
	)
)
Call :AR_DL
If "!ARDD!"=="True" (
	Goto :Next_2
)
::如果是番剧，调用番剧的视频链接爬取，否则调用站内视频的链接爬取
If "!bangumi!"=="True" (
	Call :BangumiGet
) else Call :ISVideosGet
If "!FromImo!"=="True" Goto :Eof
If "!session!"=="" Call :Get_Session session
::如果视频格式为flv，获取每个片段的视频长度
If "!VideoType!"=="flv" (
	For /f "usebackq tokens=1,6 delims=,:" %%a in ("%~dp0Temp\PlayUrl.json") do (
		If "%%~a"=="size" (
			Set /a NV+=1
			Set /a L!NV!=%%~b
		)
	)
)
Echo.!x44!
Set /p="!x45!!NumAll!!x46!" <nul
:Next_6
Call :AR_DL
If "!ARDD!"=="True" (
	Goto :Next_2
)
Set "ARDD=False"
::创建下载进程
Start /min "下载 - !big_title!!suffix:_= !" "%~f0" Download
Set Er=0
:RT1
::判定是否成功
If exist "%~dp0Download\!filename1!" (
	Echo.!x44!
	Goto :Next_2
) else If exist "%~dp0Download\!big_title!!suffix!.!x!" (
	Echo.!x44!
	Goto :Next_2
) else (
	Timeout /t 1 >nul
	If !Er! GEQ 60 (
		Echo.!x64!
		Goto :Error_2
	)
	Set /a Er+=1
)
Goto :RT1
:Next_2
::如果需要播放，创建播放进程，并判定是否成功
If "!DPlay!"=="True" (
	Set /p="!x47!" <nul
	(
		Start "播放 - !big_title!!suffix:_= !" "%~f0" Play
	) && Echo.!x44!
)
Timeout /t 3 >nul
Goto :Eof

:AR_DL
::如果要播放，检查是否已经下载了该视频，如果是，跳过下载步骤
Set "ARDD=False"
If "!DPlay!"=="True" (
	For %%a in (flv,mp4) do (
		If exist "%~dp0Download\!big_title!!suffix!.%%a" (
			Set "ARDD=True"
			Echo.!x44!
		)
	)
)
Goto :Eof

:BangumiGet
::番剧视频链接获取
If "!url!"=="" (
	Set "url=https://www.bilibili.com/bangumi/play/ep!epid!"
)
Del /q "%~dp0Temp\PlayUrl.json" >nul 2>nul
::模拟从视频相关界面获取视频链接
If exist "cookie.txt" (
	For /f "tokens=1 delims=" %%a in ("%~dp0cookie.txt") do (
		Set "Cookie=%%a"
	)
)
Set "Config=--max-tries=10 --retry-wait=3 -x16 -s16 --continue=true --auto-file-renaming=false --disk-cache=32M"
aria2c !Config! --referer="!url!" --header="Cookie: !Cookie!" --header="User-Agent: !UA!" -o "Temp\PlayUrl.json" "https://api.bilibili.com/pgc/player/web/playurl?avid=!aid!&cid=!cid!&qn=!VideoQuality!&type=&otype=json&ep_id=!epid!&fourk=1&fnver=0&fnval=16&session=!session!&module=bangumi&balh_ajax=1" >nul 2>nul
Pause
If not exist "%~dp0Temp\PlayUrl.json" Goto :Error_2
sed -i "s/],/],\n/g" "%~dp0Temp\PlayUrl.json"
sed -i "s/{/{\n/g" "%~dp0Temp\PlayUrl.json"
sed -i "s/}/\n}/g" "%~dp0Temp\PlayUrl.json"
::未成功调用则调用 港澳台地区 视频链接获取
For /f "usebackq tokens=1,2 delims=:," %%a in ("%~dp0Temp\PlayUrl.json") do (
	If "%%~a"=="code" (
		If not "%%~b"=="0" ( 
			Call :Cross
		)
	)
)
::判定视频格式
For /f "usebackq tokens=1,* delims=:" %%a in ("%~dp0Temp\PlayUrl.json") do (
	If "%%~a"=="url" (
		Set /a NumAll+=1
		Set "VideoType=flv"
		Set "x=flv"
	) else If "%%~a"=="codecs" (
		Set /a NumAll=2
		Set "VideoType=m4s"
		Set "x=mp4"
	)
)
For /l %%a in (1,1,!NumAll!) do (
	Set "FileName%%a="
	Set "Link%%a="
)
::抓取视频链接，赋值文件名
For /f "usebackq tokens=1,* delims=:" %%a in ("%~dp0Temp\PlayUrl.json") do (
	If "!VideoType!"=="flv" (
		If "%%~a"=="url" (
			Set "T=True"
			Set /a NumV+=1
			Set "FileName!NumV!=!big_title!!suffix!_!NumV!.!x!"
			Set "Link!NumV!=%%~b"
			Echo.%%b| Find "order" >nul 2>nul && (
				Set "Link=%%~b"
				Set "Link!NumV!=!Link:~0,-19!"
			)
		)
	) else If "!VideoType!"=="m4s" (
		If "!C!"=="0" (
			If "%%~a"=="codecs" (
				Set "TempLink=%%~b"
				Set R=False
				For /l %%c in (0,1,300) do (
					If not "!R!"=="True" (
						If "!TempLink:~%%c,4!"=="http" (
							Set "TempLink=!TempLink:~%%c!"
							Echo.!Link:~0,-19!
							Set "R=True"
						)
					)
				)
				Set R=False
				For /l %%c in (1500,-1,0) do (
					If not "!R!"=="True" (
						If "!TempLink:~%%c,10!"=="backup_url" (
							Set "TempLink=!TempLink:~0,%%c!"
							Set "R=True"
						)
					)
				)
				Set "Link!D!=!TempLink:~0,-3!"
				Set "FileName!D!=!big_title!!suffix!_!D!.m4s"
				Set "C=1"
				If "!D!"=="2" Goto :Next_1
			)
		)
		If "!C!"=="1" If "%%~a"=="audio" (
			Set /a C=0,D=2
		)
	)
)
:Next_1
If "!NumV!"=="1" Goto :TryByImo
Goto :Eof
:Cross
::获取港澳台地区限制的视频链接
Del /q "%~dp0Temp\PlayUrl.json" >nul 2>nul
::第三方API调用
curl -A "!UA!" -e "!url!" -o "%~dp0Temp\PlayUrl.json" "https://www.biliplus.com/BPplayurl.php?avid=!aid!&cid=!cid!&qn=!VideoQuality!&type=&otype=json&ep_id=!epid!&fourk=1&fnver=0&fnval=16&session=!session!&module=pgc" >nul 2>nul
If not exist "%~dp0Temp\PlayUrl.json" Goto :Error_2
sed -i "s/],/],\n/g" "%~dp0Temp\PlayUrl.json"
sed -i "s/{/{\n/g" "%~dp0Temp\PlayUrl.json"
sed -i "s/}/\n}/g" "%~dp0Temp\PlayUrl.json"
::仍然不行就说明是大会员限制，转到IMO线路
For /f "usebackq tokens=1,2 delims=:," %%a in ("%~dp0Temp\PlayUrl.json") do (
	If "%%~a"=="code" (
		If not "%%~b"=="0" (
			Echo.[失败]
			Goto :TryByImo
		)
	)
)
Goto :Eof

:ISVideosGet
::站内视频链接获取
If "!bvid!"=="" Set "bvid=!KW!"
If "!bvid!"=="" Goto :Error_4
::模拟从视频相关界面获取视频链接
Call :Get_Session session
curl -A "!UA!" -e "https://www.bilibili.com/video/!KW!" -o "%~dp0Temp\PlayUrl.json" "https://api.bilibili.com/x/player/playurl?cid=!cid!&bvid=!bvid!&qn=!VideoQuality!&type=&otype=json&fnver=0&fnval=16&session=!session!" >nul 2>nul
If not exist "%~dp0Temp\PlayUrl.json" Goto :Error_2
sed -i "s/],/],\n/g" "%~dp0Temp\PlayUrl.json"
sed -i "s/{/{\n/g" "%~dp0Temp\PlayUrl.json"
sed -i "s/}/\n}/g" "%~dp0Temp\PlayUrl.json"
Set E=0
:Retry_a
::调用失败就报错
If "!E!"=="4" Goto :Error_1
For /f "usebackq tokens=1,2 delims=:," %%a in ("%~dp0Temp\PlayUrl.json") do (
	If "%%~a"=="code" (
		If not "%%~b"=="0" (
			Del /q "%~dp0Temp\PlayUrl.json" >nul 2>nul
			curl -A "!UA!" -e "https://www.bilibili.com/video/!KW!" -o "%~dp0Temp\PlayUrl.json" "https://api.bilibili.com/x/player/playurl?cid=!cid!&bvid=!bvid!&qn=!VideoQuality!&type=&otype=json&fourk=1&fnver=0&fnval=80&session=!session!" >nul 2>nul
			If exist "%~dp0Temp\PlayUrl.json" (
				Set /a E+=1
				Goto :Retry_a
			)
		)
	)
::判定视频格式
For /f "usebackq tokens=1,* delims=:" %%a in ("%~dp0Temp\PlayUrl.json") do (
	If "%%~a"=="order" (
		Set /a NumAll+=1
		Set "VideoType=flv"
		Set "x=flv"
	) else If "%%~a"=="id" (
		Set /a NumAll=2
		Set "VideoType=m4s"
		Set "x=mp4"
	)
)
For /l %%a in (1,1,!NumAll!) do (
	Set "FileName%%a="
	Set "Link%%a="
)
::抓取视频链接，赋值文件名
For /f "usebackq tokens=1,3,4,5,7,8,9 delims=:" %%a in ("%~dp0Temp\PlayUrl.json") do (
	If "!VideoType!"=="flv" (
		If "%%~a"=="order" (
			Set "T=True"
			Set /a NumV+=1
			Set "FileName!NumV!=!big_title!!suffix!_!NumV!.flv"
			Set "Link.Temp=%%e:%%f"
			If "!Link.Temp:~-17!"=="mcdn.bilivideo.cn" (
				Set "Link.Temp=%%e:%%f:%%g"
			)
			Set "Link.Temp=!Link.Temp:\u0026=&!"
			Set "Link!NumV!=!Link.Temp:~1,-14!"
		)
	) else If "!VideoType!"=="m4s" (
		If "!C!"=="0" (
			If "%%~a"=="id" (
				Set "Link.Temp=%%b:%%c"
				If "!Link.Temp:~-17!"=="mcdn.bilivideo.cn" (
					Set "Link.Temp=%%b:%%c:%%d"
				)
				Set "Link.Temp=!Link.Temp:\u0026=&!"
				Set "Link!D!=!Link.Temp:~1,-12!"
				Set "FileName!D!=!big_title!!suffix!_!D!.m4s"
				Set "C=1"
				If "!D!"=="2" Goto :Next_1
			)
		)
		If "!C!"=="1" If "%%~a"=="audio" (
			Set /a C=0,D=2
		)
	)
)
Goto :Eof

:Download
::下载进程
::判断视频来源
If "!FromImo!"=="True" Goto :D_Imo
::如果启用了预加载，判定后台是否正在下载当前的视频
Set RSS=0
For /f "delims=" %%a in ('Tasklist /v /fo csv /fi "IMAGENAME eq cmd.exe" ^| Find "!big_title!!suffix:_= !" ^| Findstr "下载"') do (
	Set /a RSS+=1
)
::如果有则退出
If not "!RSS!"=="0" Exit
Title 下载 - !big_title!!suffix:_= !
::如果只有一个文件，则重新赋值文件名，去除其视频编号
If "!NumAll!"=="1" (
	Set "FileName1=!big_title!!suffix!.flv"
) >nul 2>nul
Set /p="!x48!" <nul
::枚举所有的视频链接、文件名，提交给 下载函数
For /l %%a in (1,1,!NumAll!) do (
	Set NVC=%%a
	Call :DR
)
Set "ARTD=0"
::循环判定是否下载完成
:RT2
Tasklist /v /fo csv /fi "IMAGENAME eq aria2c.exe" | Find "DLThread" >nul 2>nul || (
	Goto :Next_3
)
Timeout /t 1 >nul
Goto :RT2
:Next_3
If "!ARTD!"=="5" Goto :Next_4
::只有一个文件且下载完成就关闭下载进程
If "!NumAll!"=="1" (
	If exist "%~dp0Download\!big_title!!suffix!.flv" (
		Exit
	) else (
		Set /a NVC=1
		Call :DR
		Goto :RT2
	)
)
::如果出现未成功下载的就重试
Set "FRTD=0"
For /l %%a in (1,1,!NumAll!) do (
	Set "NVC=%%a"
	If not exist "%~dp0Download\!FileName%NVC%!" (
		Call :DR
		Set /a FRTD=1,ARTD+=1
	)
)
If "!FRTD!"=="1" Goto :RT2
Echo.!x44!
:Next_4
Set /p="!x49!" <nul
::下载完成后，开始合并视频片段
If "!VideoType!"=="flv" (
	(For %%a in ("%~dp0Download\!big_title!!suffix!_*.flv") do (
		Set TempN=%%a
		Echo.file !TempN:\=\\!
	)) >"%~dp0Temp\VideoList.tmp"
	ffmpeg -safe 0 -f concat -i "%~dp0Temp\VideoList.tmp" -c copy "%~dp0Download\!big_title!!suffix!.flv" >nul 2>nul
	If exist "%~dp0Download\!big_title!!suffix!.flv" (
		Del /f /q "%~dp0Download\!big_title!!suffix!_*.flv" "%~dp0Download\!big_title!!suffix!_*.aria2" >nul 2>nul
	)
) else If "!VideoType!"=="m4s" (
	ffmpeg.exe -i "%~dp0Download\!big_title!!suffix!_1.m4s" -i "%~dp0Download\!big_title!!suffix!_2.m4s" -codec copy "%~dp0Download\!big_title!!suffix!.mp4" >nul 2>nul
	Del /f /q "%~dp0Download\!big_title!!suffix!_*.m4s" "%~dp0Download\!big_title!!suffix!_*.aria2" >nul 2>nul
)
Echo.!x44!
::如果启用了预加载，就开始下载下一集（调用 ReRun函数）
If "!Pre-loading!"=="1" (
	If "!PL_ARD!"=="True" Exit
	Set "PL_ARD=True"
	Call :ReRun False
)
Exit
:D_Imo
Set /p="!x48!" <nul
aria2c --max-tries=10 --retry-wait=3 -x4 -s4 --continue=true --auto-file-renaming=false --disk-cache=32M --header="User-Agent: !UA!" -o "Download\!big_title!!suffix!.mp4" "!PlayLink!"
Echo.!x44!
If "!Pre-loading!"=="1" (
	If "!PL_ARD!"=="True" Exit
	Set "PL_ARD=True"
	Call :ReRun False
)
Exit
:DR
::下载函数
(
	Set "ThreadNum=0"
	If "!VideoType!"=="m4s" (
		Set "axc=6"
	) else Set "axc=1"
	For /f "tokens=2 delims=," %%a in ('Tasklist /v /fo csv /fi "IMAGENAME eq aria2c.exe" ^| Findstr "DLThread"') do (
		Set /a ThreadNum+=1
	)
	Set /a R_Thread=!ConcurrentLoads!-!ThreadNum!
	If !R_Thread! GEQ 1 (
		%=之所以启用磁盘缓存，是为了加快下载速度，且不容易出现下载失败问题；之所以将每个文件的下载线程设为一，是为了提升播放流畅度=%
		Start /min "DLThread-%NVC%" aria2c --max-tries=10 --retry-wait=3 -x!axc! -s!axc! --continue=true --auto-file-renaming=false --disk-cache=32M --referer="!url!" --header="User-Agent: !UA!" -o "Download\!FileName%NVC%!" "!Link%NVC%!"
		Timeout /t 2 >nul
		Goto :Eof
	) else (
		Timeout /t 2 >nul
		Goto :DR
	)
)
Goto :DR

:Play
::播放进程
Title 播放 - !big_title!!suffix:_= !
If "!FromImo!"=="True" Goto :P_Imo
Mode con COLS=80 LINES=11
If "!ARDD!"=="True" (
	Goto :RP
)
:PlayRe
::由于aria2c需要创建磁盘缓存，期间不会下载视频，此处用于判定并等待其创建完成
Set "ThreadNum=0"
For /f "tokens=2 delims=," %%a in ('Tasklist /v /fo csv /fi "IMAGENAME eq aria2c.exe" ^| Findstr "DLThread"') do (
	Set /a ThreadNum+=1
)
If not "!ThreadNum!"=="0" (
	If not "!NumAll!"=="1" (
		If exist "%~dp0Download\!big_title!!suffix!_1.!x!" (
			If not exist "%~dp0Download\!big_title!!suffix!_1.!x!.aria2" (
				Timeout /t 1 >nul
				Goto :PlayRe
			)
		)
	) else (
		If exist "%~dp0Download\!big_title!!suffix!.flv" (
			If not exist "%~dp0Download\!big_title!!suffix!.flv.aria2" (
				Timeout /t 1 >nul
				Goto :PlayRe
			)
		)
	)
)
:RP
::按照视频格式执行操作，以及各种人性化判定，尽可能让播放更加流畅
Set NV=0,L=0,s=0
If "!ARDD!"=="True" (		%=解决缓存后跳过“链接获取”步骤，导致视频后缀变量未定义的问题=%
	If exist "%~dp0Download\!big_title!!suffix!.mp4" (
		Set "VideoType=m4s"
	) else If exist "%~dp0Download\!big_title!!suffix!.flv" (
		Set "VideoType=flv"
	)
)
If "!VideoType!"=="flv" (
	If exist "%~dp0Download\!big_title!!suffix!_*.flv" (
		For /l %%l in (1,1,!NumAll!) do (
			Set "pv=%%l"
			Set "s=0"
			Call :PlayR
		)
		Exit
	) else If exist "%~dp0Download\!big_title!!suffix!.flv" (
		If not exist "%~dp0Download\!big_title!!suffix!_!NumAll!.flv" (
			Call :PE
			ffplay -fs !playctrl! -hide_banner -window_title "!big_title!!suffix:_= !" -protocol_whitelist "file,http,https,rtp,udp,tcp,tls" "%~dp0Download\!big_title!!suffix!.flv" >nul 2>nul
			If "!PlayMode!"=="1" (
				Call :ReRun True
			)
		)
		Exit
	) else Goto :RP
) else If "!VideoType!"=="m4s" (
	If exist "%~dp0Download\!big_title!!suffix!.mp4" (
		If not exist "%~dp0Download\!big_title!!suffix!_!NumAll!.m4s" (
			Call :PE
			ffplay -fs !playctrl! -hide_banner -window_title "!big_title!!suffix:_= !" -protocol_whitelist "file,http,https,rtp,udp,tcp,tls" -i "%~dp0Download\!big_title!!suffix!.mp4" >nul 2>nul
			If "!PlayMode!"=="1" (
				Call :ReRun True
			)
			Exit
		)
	) else (
		(
		Call :UIShell
		Cls
		Echo.
		Echo.  !xtitle6!
		Echo.!UnLine!
		Echo.
		Echo.
		Echo.!x50!
		)
		Choice /C NR /T 3 /D R /M "!x51!" /N
		Set "Choice=!ErrorLevel!"
		If "!Choice!"=="1" Exit
	)
)
Goto :RP
:PlayR
Call :PE
(
	If "!s!"=="" Set /a s=0
	Set /a L=0
	If exist "%~dp0Download\!big_title!!suffix!.flv" (
		If not exist "%~dp0Download\!big_title!!suffix!_!NumAll!.flv" (
			For /l %%a in (1,1,!pv!) do (
				Set /a L=!L!+!L%%a:~0,-3!
				Set /a BL=!L%%a:~0,-3!
			)  2>nul
			Set /a "L=!L!-!BL!+!s!" 2>nul
			ffplay -ss !L! -fs !playctrl! -hide_banner -window_title "!big_title!!suffix:_= !" -protocol_whitelist "file,http,https,rtp,udp,tcp,tls" "%~dp0Download\!big_title!!suffix!.flv" >nul 2>nul
			If "!PlayMode!"=="1" (
				Call :ReRun True
			)
			Exit
		)
	)
	If "!pv!"=="1" Timeout /t 3 >nul
	ffplay -ss !s! -fs !playctrl! -hide_banner -window_title "!big_title!!suffix:_= !" -protocol_whitelist "file,http,https,rtp,udp,tcp,tls" -i "%~dp0Download\!big_title!!suffix!_!pv!.flv" 2>"%~dp0Temp\ffplay.log"
	sed -i "s/\r/\r\n/g" "%~dp0Temp\ffplay.log"
	For /f "tokens=1 delims= " %%a in (' Type "%~dp0Temp\ffplay.log" ^| Find /v "nan" ') do (
		Set "B1=!B0!"
		If not "!B0!"=="%%a" Set "B0=%%a"
	)
	Set "B0=!B0: =!" 
	Set "B1=!B1: =!"
	Set "bs=!s!"
	Set "s=!B1!"
	Set /a "PR=!L%pv%:~0,-3!-!s:~0,-3!" 2>nul
	If !PR! LSS 10 (
		If !PR! GTR -10 (
			Goto :Eof
		)
	)
	If not "!B0!"=="nan" (
		If not "!bs!"=="!s!" (
			Set /a Rtry+=1
			If !Rtry! GEQ 10 (

				Choice /c YN /m "!x52!" /t 10 /d Y

				Set "Choice=!ErrorLevel!"
				If "!Choice!"=="2" Exit
				Set "Rtry=0"
			)
			Goto :PlayR
		) else Goto :Eof
	)
	If "!pv!"=="!NumAll!" (
		If "!PlayMode!"=="1" (
			Call :ReRun True
		)
		Exit
	)
)
Goto :PlayR
:P_Imo
Set s=0
If "!Type!"=="m3u8" (
	Mode con COLS=80 LINES=12
	Call :PE
	Echo.	!x68!
) else (
	Mode con COLS=80 LINES=11
	Call :PE
)
If "!ARDD!"=="True" (
	ffplay -ss !s! -fs !playctrl! -hide_banner -window_title "!big_title!!suffix:_= !" -protocol_whitelist "file,http,https,rtp,udp,tcp,tls" "%~dp0Download\!big_title!!suffix!.mp4" >nul 2>nul
) else ffplay -ss !s! -fs !playctrl! -hide_banner -window_title "!big_title!!suffix:_= !" -protocol_whitelist "file,http,https,rtp,udp,tcp,tls" "!PlayLink!" >nul 2>nul
Exit

:PE
(
Call :UIShell
Cls
Echo.
Echo.  !xtitle6!
Echo.!UnLine!
Echo.
Echo.
Echo.	!title!：!long_title!
Echo.
Echo.	!x53!     !x54!    !x55!     !x56!     !x57!

Echo.	!x58!

)
Goto :Eof

:ReRun
::提交下一话的信息，然后退出
Set "DPlay=%~1"
If "!bangumi!"=="True" (
	If !Episode! LSS !ep_size%ssid%! (
		Set /a Episode+=1
		For %%a in (!Episode!) do (
			Set "bangumi=True"
			Set "aid=!aid%%a!"
			Set "bvid=!bvid%%a!"
			Set "big_title=!title%ssid%!"
			Set "cid=!cid%%a!"
			Set "epid=!aepid%%a!"
			Set "long_title=!alt%%a!"
			Set "title=!at%%a!"
			Set "suffix=_!Episode!"
		)
		Call :RunTrue
	)
) else If !Episode! LSS !ep_size%ssid%! (
	Set /a Episode+=1
	For %%a in (!Episode!) do (
		Set "bangumi=False"
		Set "big_title=!title!"
		Set "cid=!cid%%a!"
		Set "epid="
		Set "long_title=!part%%a!"
		Set "suffix=_!Episode!"
		Set "title=!Episode!"
		Set "url=https://www.bilibili.com/video/!bvid!"
	)
	Call :RunTrue
)
Goto :Eof

:LocalPlay
::检查是否正在下载视频，如果没有，则删除所有未下载完成的片段
Tasklist /v /fo csv /fi "IMAGENAME eq aria2c.exe" | Find "DLThread" >nul 2>nul || (
	Del /f /q "%~dp0Download\*_*_*" >nul 2>nul
)
Set "Name="
:RLP
(
Call :UIShell
Cls
Echo.
Echo.  !xtitle8!
Echo.!UnLine!
Echo.
Echo.
Echo.	!x65!
Echo.
)
Set /a FNum=0
For /l %%a in (1,1,15) do (
	Set "File%%a="
)
If "!Name!"=="" (
	Set "PRT="
) else Set "PRT=*"
For %%a in ("%~dp0Download\*!Name!!PRT!.*") do (
	If "!FNum!"=="15" Goto :LPP1
	Set /a FNum+=1
	Set "File!FNum!=%%~na"
	Echo.	!FNum!.  %%~na
)
:LPP1
Echo.
If "FNum"=="15" Echo.	!x66!
Echo.	!x67!
Echo.	!x21!
Echo.
Set /p "Name=!xs!"
If "!Name!"=="" Goto :RLP
If /i "!Name!"=="B" Goto :Eof
For /l %%a in (1,1,15) do (
	If "!Name!"=="%%a" (
		If "!File%%a!"=="" Goto :RLP
		Set "Name=!File%%a!"
	)
)
If exist "%~dp0Download\!Name!.flv" (
	Start /min "!Name!" ffplay -fs -autoexit -hide_banner -window_title "!Name!" -protocol_whitelist "file,http,https,rtp,udp,tcp,tls" "%~dp0Download\!Name!.flv" >nul 2>nul
	Set "Name="
	Timeout /t 3 >nul
) else If exist "%~dp0Download\!Name!.mp4" (
	Start /min "!Name!" ffplay -fs -autoexit -hide_banner -window_title "!Name!" -protocol_whitelist "file,http,https,rtp,udp,tcp,tls" "%~dp0Download\!Name!.mp4" >nul 2>nul
	Set "Name="
	Timeout /t 3 >nul
)
Goto :RLP

:Config
::播放设置
Call :ConfigGet UI
(
Call :UIShell
Cls
Echo.
Echo.  !xtitle7!
Echo.!UnLine!
Echo.
Echo.
Echo.	!x59!		!C.PlayMode!
Echo.				!C.PlayMode.Info!
Echo.
Echo.	!x60!		!C.Pre-loading!
Echo.				!C.Pre-loading.Info!
Echo.
Echo.	!x61!		!C.VideoQuality!
Echo.				!C.VideoQuality.Info!
Echo.
Echo.	!x62!		!C.ConcurrentLoads!
Echo.				!C.ConcurrentLoads.Info!
Echo.
Echo.	!x70!
Echo.
Echo.!x21!
)
Choice /c 1234B /n /m "!xc!"
Set "Choice=!ErrorLevel!"
If "!Choice!"=="1" (
	If "!PlayMode!"=="2" (
		Set /p="0" <nul >"%~dp0Modules\Config\PlayMode.ini"
	) else (
		Set /a PlayMode+=1
		Set /p="!PlayMode!" <nul >"%~dp0Modules\Config\PlayMode.ini"
	)
) else If "!Choice!"=="2" (
	If "!Pre-loading!"=="1" (
		Set /p="0" <nul >"%~dp0Modules\Config\Pre-loading.ini"
	) else (
		Set /p="1" <nul >"%~dp0Modules\Config\Pre-loading.ini"
	)
) else If "!Choice!"=="3" (
	For %%c in (112:80,80:64,64:32,32:16,16:112) do (
		For /f "tokens=1,2 delims=:" %%a in ("%%~c") do (
			If "!VideoQuality!"=="%%~a" (
				Set /p="%%~b" <nul >"%~dp0Modules\Config\VideoQuality.ini"
			)
		)
	)
) else If "!Choice!"=="4" (
	Choice /c 12345678 /n /m "!xc2!"
	Set /p="!ErrorLevel!" <nul >"%~dp0Modules\Config\ConcurrentLoads.ini"
) else If "!Choice!"=="5" (
	Goto :Eof
)
Goto :Config

:ConfigGet
For %%a in (PlayMode,Pre-loading,VideoQuality,ConcurrentLoads) do (
	Set /p "%%a=" <"%~dp0Modules\Config\%%a.ini"
)
If "%~1"=="UI" (
	For %%e in (
		PlayMode:0:默认:播放完后关闭窗口,PlayMode:1:自动切P:跳转到下一集,PlayMode:2:播放完暂停:保持窗口开启,
		Pre-loading:0:关闭:仅加载当前视频,Pre-loading:1:启用:提前加载下一集视频,
		VideoQuality:112:1080P+:最高画质,VideoQuality:80:1080P:1920x1080,VideoQuality:64:720P:1080x720,
		VideoQuality:32:480P:848x480,VideoQuality:16:360P:640x360,
	) do (
		For /f "tokens=1,2,3,4 delims=:" %%a in ("%%~e") do (
			If "!%%a!"=="%%b" (
				Set "C.%%a=%%c"
				Set "C.%%a.Info=%%d"
			)
		)
	)
	Set "C.ConcurrentLoads=!ConcurrentLoads!"
	Set "C.ConcurrentLoads.Info=同时加载!ConcurrentLoads!个视频，默认为2"
) else If "%~1"=="Get" (
	For %%d in (
		PlayMode:0:-autoexit,PlayMode:1:-autoexit,PlayMode:2:
	) do (
		For /f "tokens=1,2,3 delims=:" %%a in ("%%~d") do (
			If "!%%a!"=="%%b" (
				Set "playctrl=%%c"
			)
		)
	)
)
Goto :Eof

:TryByImo
Del /q "*.strvar" >nul 2>nul
Echo. >"%~dp0Temp\Big_Title-!Big_title!.strvar"
Echo. >"%~dp0Temp\Long_Title-!Long_title!.strvar"
Chcp 936 >nul
For /f "usebackq delims=" %%a in ("%~dp0Modules\LanguageANSI.pkg") do (
	Set "y%%a"
)
For %%c in ("%~dp0Temp\*-*.strvar") do (
	Set "name.temp=%%~nc"
	For /f "tokens=1,* delims=-" %%a in ("!name.temp!") do (
		Set "%%a_ANSI=%%b"
	)
)
Del /q "*.strvar" >nul 2>nul
(
Cls
Echo.
Echo.  !ytitle6!
Echo.!UnLine!
Echo.
Echo.
Echo.	!title!!y7!!long_title_ANSI!
Echo.
Echo.!y1!
Echo.!y2!
)
Set /p="!y3!" <nul
Set "FromImo=True"
Set "N=1"& Set "SendStr="
If exist "%~dp0Temp\VideoLink.js" (
	Find "::FileFor!Big_Title_ANSI!#!Date!" "%~dp0Temp\VideoLink.js" >nul 2>nul && Goto :Pass_1
)
Set "Big_title_ANSI=!Big_title_ANSI:-= !"
::GBK直接转Url编码（非UTF-8）
>"%~dp0Temp\TempStr.tmp"  Set /p="!Big_title_ANSI:-= !" <nul
Certutil -encodehex -f "%~dp0Temp\TempStr.tmp" "%~dp0Temp\TempStr.tmp" >nul 2>nul
For /f "usebackq tokens=2-17 delims=	 " %%a in ("%~dp0Temp\TempStr.tmp") do (
	Set "s1=%%a"& Set "s2=%%b"& Set "s3=%%c"& Set "s4=%%d"& Set "s5=%%e"& Set "s6=%%f"& Set "s7=%%g"& Set "s8=%%h"
	Set "s9=%%i"& Set "s10=%%j"& Set "s11=%%k"& Set "s12=%%l"& Set "s13=%%m"& Set "s14=%%n"& Set "s15=%%o"& Set "s16=%%p"
	Call :ASCII_R
)
If "!SendStr!"=="" Goto :Error_1
::重置变量
Set "RN=False"& Set "Start=False"&Set "Num=-1"
For /l %%l in (0,1,9) do (
		Set "Name%%l="
		Set "G%%l="
		Set "Link%%l="
	)
)
Del /q "%~dp0Temp\Search.html" >nul 2>nul
::获取搜索结果（GET）
aria2c.exe -o "Temp\Search.html" --header="User-Agent: !UA!" --referer="http://www.imomoe.ai/" "http://www.imomoe.ai/search.asp?page=%N%&searchword=!SendStr!&searchtype=-1" >nul 2>nul
If not exist "%~dp0Temp\Search.html" Goto :Error_1
::对Html的需要部分进行提取
For /f "usebackq skip=95 tokens=1-23,* delims==<> " %%a in ("%~dp0Temp\Search.html") do (
	If "%%a"=="ul" Set "Start=True"
	If "!Start!"=="True" (
		If "%%a"=="h2" (
			Set /a "Num+=1"
			Set "Link!Num!=%%~d"
			Set "Name=%%i %%j %%k %%l %%m %%n %%o %%p %%q"
			Set "Name=!Name:"='!"
			For /l %%l in (1,1,200) do (
				If "!Name:~%%l,1!"=="'" (
					Set "Name=!Name:~%%l!"
					Set "Name=!Name:~1!"
				)
			)
			Set "Name!Num!=!Name:/a /h2=!"
			For /l %%l in (200,-1,0) do (
				If not "!RN!"=="True" If not "!Name:~%%l,1!"==" " (
					Set "NGS1=!G:~0,%%l!"
					Set "NGS2=!G:~%%l,1!"
					Set "Name=!NGS1!!NGS2!"
					Set "RN=True"
				)
			)
		) else If "%%a"=="span" (
			Set "G=%%b %%c %%d %%e %%f %%g %%h %%i %%j %%k %%l %%m %%n %%o %%p %%q"
			Set "G=!G:"='!"
			For /l %%l in (1,1,200) do (
				If "!G:~%%l,1!"=="'" (
					Set "G=!G:~%%l!"
					Set "G=!G:~1!"
				)
			)
			Set "G=!G:/span=!"
			Set "G!Num!=!G:span=　!"
		) else If "%%a"=="p" (
			Set "Information!Num!=%%b"
		)
	)
	If "%%a"=="/ul" (
		Set "Start=False"
		Goto :Imo_N1
	)
)
:Imo_N1
If "!Name0!"=="" Goto :Error_1
For /l %%a in (0,1,!Num!) do (
	If "%%a"=="0" (
		Set "Imo_P=%%a"
	)
	If "!Name%%a: =!"=="!Big_title_ANSI: =!" (
		Set "Imo_P=%%a"
		Goto :Imo_N2
	) else For /f "tokens=1,2,3,4 delims=/　" %%b in ("!G%%a!") do (
		If "%%b"=="!Big_title_ANSI!" (
			Set "Imo_P=%%a"
			Goto :Imo_N2
		) else If "%%c"=="!Big_title_ANSI!" (
			Set "Imo_P=%%a"
			Goto :Imo_N2
		) else If "%%d"=="!Big_title_ANSI!" (
			Set "Imo_P=%%a"
			Goto :Imo_N2
		) else If "%%e"=="!Big_title_ANSI!" (
			Set "Imo_P=%%a"
			Goto :Imo_N2
		)
	)
)
:Imo_N2
Echo.!y44!
Set /p="!y4!" <nul
Set "Imo_Url=!Link%imo_P%:/view/=!"
Set "Imo_Url=!Imo_Url:.html=!"
Del /q "%~dp0Temp\Player.html" >nul 2>nul
aria2c.exe -o "Temp\Player.html" --header="User-Agent: !UA!" --referer="http://www.imomoe.ai/search.asp?page=%N%&searchword=!KW!&searchtype=-1" "http://www.imomoe.ai/Player/!Imo_Url!-0-0.html" >nul 2>nul
If not exist "%~dp0Temp\Player.html" Goto :Error_1
::找到关键行，获取视频链接列表
Set "TrueLink="
For /f "tokens=1-23,* delims==<> " %%a in ('Find "/playdata/" "%~dp0Temp\Player.html"') do (
	Set "TrueLink=%%~f"
)
Del /q "%~dp0Temp\VideoLink.js" >nul 2>nul
If "!TrueLink!"=="" Goto :Error_1
::下载视频链接列表（GET）
aria2c.exe -o "Temp\VideoLink.js" --header="User-Agent: !UA!" --referer="http://www.imomoe.ai/Player/!Imo_Url!-0-0.html" "http://www.imomoe.ai!TrueLink!" >nul 2>nul
If not exist "%~dp0Temp\VideoLink.js" Goto :Error_1
Echo.::FileFor!Big_Title_ANSI!#!Date!>>"%~dp0Temp\VideoLink.js"
::自动换行，格式化json
sed -i "s/',/\n/g" "Temp\VideoLink.js"
sed -i "s/],/\n/g" "Temp\VideoLink.js"
:Pass_1
Set "SetR=!Episode!"
Set "Str="
Set "PlayLink="
Set /a "RanAdr=!Random! & 4"
For %%a in (0:GuangDong_GuangZhou,1:XinJiang_LaSa,2:HuNan_ChangSha,3:HuBei_WuHan,4:JiangSu_NanJing) do (
	For /f "tokens=1,2 delims=:" %%b in ("%%a") do (
		If "!RanAdr!"=="%%b" Set "Adr=%%c"
	)
)
:Line_flv
::主线路（百度）
Find "$flv" "%~dp0Temp\VideoLink.js" >nul 2>nul || Goto :Line_iQiYi
Set "SetNum=0"
::找到对应的集数，播放即可
For /f "skip=2 tokens=1,2,3 delims=$" %%a in ('Find "$flv"  "%~dp0Temp\VideoLink.js"') do (
	Set /a "SetNum+=1"
	If "!SetNum!"=="!SetR!" (
		Set "PlayLink=%%b"
		Set "Type=mp4"
		Goto :Next_5
	)
)
Goto :Error_1
:Line_iQiYi
::主线路不可用时，加载爱奇艺线路
Find "$qiyi" "%~dp0Temp\VideoLink.js" >nul 2>nul || Goto :Line_Qvod
Set "SetNum=0"
::先读取参数
For /f "tokens=1,2,3,4,5 delims=$" %%a in ('Find "$"  "%~dp0Temp\VideoLink.js" ^| Findstr "qiyi"') do (
	Set /a "SetNum+=1"
	If "!SetNum!"=="!SetR!" (
		Set "LinkD2a=%%b"
		Goto :iQiYi_Get
	)
)
:Line_Qvod
::爱奇艺线路（无法抓取的部分）
Find "$qqy" "%~dp0Temp\VideoLink.js" >nul 2>nul || Goto :Line_YouKu
Set "SetNum=0"
For /f "tokens=1,2,3,4,5 delims=$" %%a in ('Find "$"  "%~dp0Temp\VideoLink.js" ^| Findstr "qqy"') do (
	Set /a "SetNum+=1"
	If "!SetNum!"=="!SetR!" (
		Set "Link=%%b"
		Goto :Line_Qvod_Get
	)
)
:Line_Qvod_Get
Echo.!y5!
Set /p="!y6!" <nul
curl -A "!UA!" -e "https://www.iqiyi.com/v_!Link!.html" -o "%~dp0Temp\IQiYi_PlayUrl.html" "https://www.iqiyi.com/v_!Link!.html"  >nul 2>nul
If not exist "%~dp0Temp\IQiYi_PlayUrl.html" Goto :Error_2
For /f "usebackq eol=< tokens=1,* delims==" %%a in ("%~dp0Temp\IQiYi_PlayUrl.html") do (
	Set "a=%%~a"&Set "b=%%~b"
	If "!a: =!"=="param['tvid']" (
		Set "tvid=!b: =!"
		Set "tvid=!tvid:"=!"
		Set "tvid=!tvid:;=!"
	) else If "!a: =!"=="param['vid']" (
		Set "vid=!b: =!"
		Set "vid=!vid:"=!"
		Set "vid=!vid:;=!"
	)
)
Set "LinkD2a=!vid!,!tvid!"
If "!LinkD2a!"=="," Goto :Error_1
Echo.!y44!
Set /p="!y4!" <nul
:iQiYi_Get
Set "SetNum=0"
::获取播放器内的真实视频链接包（此处用到随机地址）
Del /q "Temp\IQiYi_LinkTemp.html" "Temp\IQiYi_LinkTemp.json" "%~dp0Temp\IQiYi_NewTemp.tmp" >nul 2>nul
aria2c.exe --file-allocation=none --referer="http://www.imomoe.ai/player/1%Random%-0-0.html" -o "Temp\IQiYi_LinkTemp.html" "https://saas.jialingmm.net/code.php?type=qiyi&vid=!LinkD2a!&userlink=http%3A%2F%2Fwww.imomoe.ai%2Fplayer%2F1%Random%-1-0.html&adress=!Adr!" >nul 2>nul
If not exist "%~dp0Temp\IQiYi_LinkTemp.html" Goto :Error_2
For /f "skip=2 tokens=1-23,* delims==<> " %%a in ('Find "http://cache.m.iqiyi.com/" "%~dp0Temp\IQiYi_LinkTemp.html"') do (
	Set "LinkD2=%%c=%%d=%%e=%%f"
	Set "LinkD2=!LinkD2:~1,-1!"
)
::下载真实的视频链接包
aria2c.exe --file-allocation=none -o "Temp\IQiYi_LinkTemp.json" "!LinkD2!" >nul 2>nul
::格式化文本
sed -i "s/,/\n/g" "Temp\IQiYi_LinkTemp.json"
Del /q "%~dp0Temp\IQiYi_TrueLink.tmp" >nul 2>nul
For /f "usebackq tokens=1 delims=" %%a in ("%~dp0Temp\IQiYi_LinkTemp.json") do (
	Set "Str=%%a"
	(
		Set "Str=!Str:var VideoListJson=!"
		Set "Str=!Str:\/=/!"
		Set "Str=!Str:"=!"
	)
	For /f "delims=" %%i in ("!Str!") do Echo %%i
) >>"%~dp0Temp\IQiYi_TrueLink.tmp"
:;读取视频列表，选择最高画质的（720P/1080P）、可用的m3u8，然后播放
Del /q "%~dp0Temp\IQiYi_Video.m3u8" >nul 2>nul
Set "MNum=0"& Set "RStr="&Set "HaSL=False"
For /f "usebackq tokens=1,* delims=:" %%a in ("%~dp0Temp\IQiYi_TrueLink.tmp") do (
	If "%%a"=="screenSize" (
		Set "IQiYi_Size=%%b"
		Set "IQiYi_Size=!IQiYi_Size:~0,4!"
		Set "IQiYi_Size=!IQiYi_Size:x=!"
		If !IQiYi_Size! GEQ 1280 (
			Set "HaSL=True"
		) else Set "HaSL=False"
	)
	If "!HaSL!"=="True" If "%%a"=="m3u" (
		Del /q "Temp\IQiYi_Video.m3u8" >nul 2>nul
		aria2c.exe -s16 -x16 --referer="https://www.iqiyi.com/v_!Link!.html" --file-allocation=none -o "Temp\IQiYi_Video.m3u8" "%%~b" >nul 2>nul
		If exist "Temp\IQiYi_Video.m3u8" (
			For %%f in ("Temp\IQiYi_Video.m3u8") do (
				If not "%%~zf"=="0" (
					Set "Type=m3u8"
					Set "PlayLink=%%b"
					Set "HaSL=True"
					Goto :Next_5
				)
			)
		)
	)
)
Goto :Eof
:Line_YouKu
Goto :Error_1
:Next_5
Echo.!y44!
Chcp 65001 >nul
(
	Cls
	Echo.
	Echo.  !xtitle6!
	Echo.!UnLine!
	Echo.
	Echo.
	Echo.	!title!：!long_title!
	Echo.
	Echo.!x63!!x44!
	Echo.!x43!!x44!
	Set /p="!x69!" <nul
)
If "!Type!"=="m3u8" (
	Goto :Next_2
) else (
	Goto :Next_6
)
Goto :Error_1

:ASCII_R
Set "NextOne=False"
For /l %%z in (1,1,16) do (
	For %%l in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do (
		If "!s%%z:~0,1!"=="%%l" (
			Set "NextOne=True"
		) 
		If not "!s%%z:~3,1!"=="" (
			Goto :Eof
		)
	)
	If not "!NextOne!"=="True" Goto :Eof
	Set "NextOne=False"
	Set "s%%z=%%!s%%z!"
	Set "SendStr=!SendStr!!s%%z!"
)
Goto :Eof

:Get_Session
Set "fullSession="
For /L %%n in (1,1,32) do ( 
	Set /a "currentDigit=!random! %% 16" 

	For %%a in (10:a,11:b,12:c,13:d,14:e,15:f) do (
		For /f "tokens=1,2 delims=:" %%b in ("%%~a") do (
			If "!currentDigit!"=="%%~b" set "currentDigit=%%~c"
		)
	)

	Set "fullSession=!fullSession!!currentDigit!"
) 
If not "%~1"=="" Set "%~1=%fullSession%"
Goto :Eof

:UIShell
::UI函数
Set "System.Ex="
For /f "skip=3 tokens=2 delims=:" %%a in ('Mode con') do (
	If "!System.Ex!"=="" (
		Set "Lines=%%a"
		Set "Lines=!Lines: =!"
		Set "System.Ex=1"
	) else (
		(
			Set "Cols=%%a"
			Set "Cols=!Cols: =!"
			Set "System.Ex="
			Set "UnLine= "
		)
		For /l %%n in (3,1,!Cols!) do (
			Set "UnLine=!UnLine!_"
		)
		Goto :Eof
	)
)
Goto :Eof

:Error_1
Chcp 65001 >nul
(
Cls
Echo.
Echo.
Echo.	!xe1!
Echo.
Echo.		!xe2!
Echo.
Echo.
Echo.
Pause>nul
Goto :Eof
)

:Error_2
Chcp 65001 >nul
(
Cls
Echo.
Echo.
Echo.	!xe3!
Echo.
Echo.		!xe4!
Echo.
Echo.
Echo.
Pause>nul
Goto :Eof
)

:Error_3
(
Cls
Echo.
Echo.
Echo.	!xe5!
Echo.
Echo.		!xe6!
Echo.
Echo.
Echo.
Pause>nul
Goto :Exit
)

:Error_4
(
Cls
Echo.
Echo.
Echo.	!xe7!
Echo.
Echo.		!xe8!
Echo.
Echo.
Echo.
Pause>nul
Goto :Exit
)