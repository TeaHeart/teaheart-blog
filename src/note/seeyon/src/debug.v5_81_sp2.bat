@echo off
cd "%~dp0"
set CATALINA_OPTS=-server -Xdebug -Djava.compiler=NONE
set A8_HOME=D:\Seeyon\v5_81_sp2
set JAVA_HOME=%A8_HOME%\jdk
set CATALINA_HOME=%A8_HOME%\ApacheJetspeed
copy /Y partaletindev.js "%CATALINA_HOME%\webapps\seeyon\common\js\ui"
cd "%CATALINA_HOME%\bin"
catalina.bat jpda start