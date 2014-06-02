@echo off
SETLOCAL

set DATAPATH=%~dp0
IF %DATAPATH:~-1%==\ SET DATAPATH=%DATAPATH:~0,-1%

echo Setting jetty base to match  %DATAPATH%

set SERVICE_NAME=SolrService
set JETTY_HOME=%DATAPATH%
set JETTY_BASE=%DATAPATH%
set STOPKEY=secret
set STOPPORT=50001
 
set PR_INSTALL=%DATAPATH%\SolrService.exe

 
@REM Finding JAVA_HOME
IF NOT DEFINED JAVA_HOME goto findjava
:javafound
IF NOT DEFINED JAVA_HOME goto errored

@REM Service Log Configuration
set PR_LOGPREFIX=%SERVICE_NAME%
set PR_LOGPATH=%DATAPATH%\logs
set PR_STDOUTPUT=auto
set PR_STDERROR=auto
set PR_LOGLEVEL=Debug
 
@REM Path to Java Installation
set PR_JVM=%JAVA_HOME%\jre\bin\server\jvm.dll
set PR_CLASSPATH=%JETTY_HOME%\start.jar;%JAVA_HOME%\lib\tools.jar
 
@REM JVM Configuration
set PR_JVMMS=128
set PR_JVMMX=512
set PR_JVMSS=4000
set PR_JVMOPTIONS=-Duser.dir="%JETTY_BASE%";-Djava.io.tmpdir="%DATAPATH%\temp";-Djetty.home="%JETTY_HOME%";-Djetty.base="%JETTY_BASE%"
@REM Startup Configuration
set JETTY_START_CLASS=org.eclipse.jetty.start.Main
 
set PR_STARTUP=auto
set PR_STARTMODE=java
set PR_STARTCLASS=%JETTY_START_CLASS%
set PR_STARTPARAMS=-DSTOP.KEY="%STOPKEY%";-DSTOP.PORT=%STOPPORT%
 
@REM Shutdown Configuration
set PR_STOPMODE=java
set PR_STOPCLASS=%JETTY_START_CLASS%
set PR_STOPPARAMS=-DSTOP.KEY="%STOPKEY%";-DSTOP.PORT=%STOPPORT%;-DSTOP.WAIT=10;--stop;
 
"%PR_INSTALL%" //IS/%SERVICE_NAME% ^
  --DisplayName="%SERVICE_NAME%" ^
  --Install="%PR_INSTALL%" ^
  --Startup="%PR_STARTUP%" ^
  --LogPath="%PR_LOGPATH%" ^
  --LogPrefix="%PR_LOGPREFIX%" ^
  --LogLevel="%PR_LOGLEVEL%" ^
  --StdOutput="%PR_STDOUTPUT%" ^
  --StdError="%PR_STDERROR%" ^
  --JavaHome="%JAVA_HOME%" ^
  --Jvm="%PR_JVM%" ^
  --JvmMs="%PR_JVMMS%" ^
  --JvmMx="%PR_JVMMX%" ^
  --JvmSs="%PR_JVMSS%" ^
  --JvmOptions="%PR_JVMOPTIONS%" ^
  --Classpath="%PR_CLASSPATH%" ^
  --StartMode="%PR_STARTMODE%" ^
  --StartClass="%JETTY_START_CLASS%" ^
  --StartParams="%PR_STARTPARAMS%" ^
  --StopMode="%PR_STOPMODE%" ^
  --StopClass="%PR_STOPCLASS%" ^
  --StopParams="%PR_STOPPARAMS%"
 
if not errorlevel 1 goto installed
:errored
echo Failed to install "%SERVICE_NAME%" service.  Refer to log in %PR_LOGPATH%
exit /B 1
goto end


:findjava
echo Inspecting registry for Java versiona and JAVA_HOME
FOR /F "tokens=2*" %%a IN ('REG QUERY "HKLM\Software\JavaSoft\Java Runtime Environment" /v CurrentVersion') DO set "CurVer=%%b"
ECHO Found version %CurVer%
FOR /F "tokens=2*" %%a IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment\%CurVer%" /v JavaHome') DO set "JAVA_HOME=%%b"
ECHO Setting JAVA_HOME=%JAVA_HOME%
goto javafound

:installed
echo The Service "%SERVICE_NAME%" has been installed

:end