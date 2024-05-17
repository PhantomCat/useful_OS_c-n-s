@echo off
REM ротация резервных копий base_ut

D:
CD D:\Backups

if NOT EXIST S: net use S: \\10.10.10.19\backup

set BDIR=S:\SQL_Backup
set YEAR=%DATE:~6%
set MONTH=%DATE:~3,2%
set DAY=%DATE:~0,2%
set BDAY=Sunday
set PREFIX=daily
REM Присвоить переменной текущего дня значение дня
for /f %%i in ('powershell ^(get-date^).DayOfWeek') do set DOW=%%i
set LOGFILE=%BDIR%\_LOGS\log_%YEAR%-%MONTH%-%DAY%.log
echo ------------------------------- >> %LOGFILE%

if %DAY% == 01 ( 
		REM Если первое число месяца - перемещаем в папку с номером месяца и префиксом monthly
		set PREFIX=monthly
		set EXPIRE=183
		echo Сегодня 1 число, нужно сделать ежемесячную резервную копию >> %LOGFILE%
	) else if %DOW%==%BDAY% (
		REM Если Воскресенье, то переместить бекап с префиксом weekly
		set PREFIX=weekly
		set EXPIRE=16
		echo Сегодня %BDAY%, нужно сделать еженедельную резервную копию >> %LOGFILE%
	) else (
		REM Производим ежедневную работу ротации, префикс daily
		set PREFIX=daily
		set EXPIRE=7
		echo Перемещаем .bak в папку  текущего месяца >> %LOGFILE%
	)
	
echo ------------------------- >> %LOGFILE%
echo prefix: %PREFIX% >> %LOGFILE%
echo expiration days: %EXPIRE% >> %LOGFILE%
echo ------------------------- >> %LOGFILE%

call :filesProcess
copy %LOGFILE% E:\Backup_LOGS\
net use /d S:
goto :eof

:filesProcess
REM если мы НЕ в корневой папке бекапов - делаем бекапы
if %cd% NEQ D:\Backups (
	echo ОТЛАДКА: %basedir% >> %LOGFILE%

	
	for %%z in (*.bak) do (
		if not exist %BDIR%\%basedir%\%YEAR%\%MONTH%\monthly_%%z (
			if not exist %BDIR%\%basedir%\%YEAR%\%MONTH%\weekly_%%z (
				if not exist %BDIR%\%basedir%\%YEAR%\%MONTH%\daily_%%z (
					certutil -hashfile %%z MD5 >> %BDIR%\%basedir%\%YEAR%\%MONTH%\%PREFIX%_%%z.md5
					copy "%%z" "%BDIR%\%basedir%\%YEAR%\%MONTH%\%PREFIX%_%%z" >> %LOGFILE%
				) else echo Файл %%z уже имеет резервную копию, пропускаю >> %LOGFILE%
			) else echo Файл %%z уже имеет резервную копию, пропускаю >> %LOGFILE%
		) else echo Файл %%z уже имеет резервную копию, пропускаю >> %LOGFILE%
			
	)
	forfiles -p "%BDIR%\%basedir%" -s -m %PREFIX%_*.* -d -%EXPIRE% -c "cmd /c del /q @path" >> %LOGFILE%

	:delstep
	echo Удаляем .trn и .bak файлы старше одного дня в папке %basedir% >> %LOGFILE%
	forfiles /P "." /M *.trn /D -1 /C "cmd /c del /q @file" >> %LOGFILE%
	forfiles /P "." /M *.bak -d -1 /C "cmd /c del /q @path" >> %LOGFILE%
	
	echo -  >> %LOGFILE%
	echo ------------------------------- >> %LOGFILE%
	echo Закончили с базой %basedir% >> %LOGFILE%
	echo ------------------------------- >> %LOGFILE%
	echo -  >> %LOGFILE%
	)
)

for /D %%d in (*) do (
	REM Если нет папки года-месяца - нужно их создать
	if NOT EXIST "%BDIR%\%%d\%YEAR%\%MONTH%" mkdir "%BDIR%\%%d\%YEAR%\%MONTH%"
	echo ----------------- I'm in %%d -------------- >> %LOGFILE%
	cd %%d
	set basedir=%%d
	call :filesProcess
	cd ..
)


