@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ===== 附近自助加油站 一鍵更新到網站 =====

where git >nul 2>nul
if errorlevel 1 goto nogit

echo [1/3] 下載最新中油站點資料...
powershell -NoProfile -Command "try{Invoke-WebRequest -UseBasicParsing -TimeoutSec 60 -Uri 'https://vipmbr.cpc.com.tw/CPCSTN/STNWebService.asmx/getStationInfo_XML' -OutFile 'stations.tmp'; if((Get-Item 'stations.tmp').Length -gt 100000){Move-Item -Force 'stations.tmp' 'stations.xml'; exit 0}else{Remove-Item 'stations.tmp'; exit 1}}catch{exit 1}"
if errorlevel 1 (echo 下載失敗,沿用目前的 stations.xml) else (echo 已更新 stations.xml)

echo [2/3] 整理並提交...
if exist ".git" goto hasgit
git init -b main
git remote add origin https://github.com/fyhj08020711-lu/cpc-self-service.git
git fetch origin
git reset origin/main
:hasgit
git add -A
git diff --cached --quiet
if not errorlevel 1 goto nochange
git commit -m "update %date% %time%"

echo [3/3] 上傳到 GitHub...
git push origin main
if errorlevel 1 goto pushfail
echo.
echo 完成。約 1 分鐘後生效:
echo https://fyhj08020711-lu.github.io/cpc-self-service/
goto end

:nochange
echo 沒有需要更新的內容。
goto end

:nogit
echo 找不到 git,請先安裝 Git for Windows。
goto end

:pushfail
echo.
echo 上傳失敗,請把上面的錯誤訊息貼給我。

:end
echo.
pause
