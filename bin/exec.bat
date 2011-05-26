@echo off

REM   Licensed to the Apache Software Foundation (ASF) under one or more
REM   contributor license agreements.  See the NOTICE file distributed with
REM   this work for additional information regarding copyright ownership.
REM   The ASF licenses this file to You under the Apache License, Version 2.0
REM   (the "License"); you may not use this file except in compliance with
REM   the License.  You may obtain a copy of the License at
REM
REM       http://www.apache.org/licenses/LICENSE-2.0
REM
REM   Unless required by applicable law or agreed to in writing, software
REM   distributed under the License is distributed on an "AS IS" BASIS,
REM   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM   See the License for the specific language governing permissions and
REM   limitations under the License.

@setlocal
set BASEDIR=%~dp0.\..
set JAVA_HOME=%BASEDIR%\repository\jdk1.6.0_10_win32
set ANT_HOME=%BASEDIR%\repository\apache-ant-1.8.1

set sfi.exec=call "%ANT_HOME%\bin\ant.bat" -f "%BASEDIR%\bin\engine.ant" testModule 
set sfi.option=
REM set sfi.option=%sfi.option% -Dsfi.exec.mode=TEST

%sfi.exec% %sfi.option% "-Dmodules=%*"
REM exemple: test  config.install issueTool.init issueApp.install server.startup

@endlocal
