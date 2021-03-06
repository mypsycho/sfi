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
set BASEDIR=%~dp0.\..\..

REM in batch, empty line are ignored by for
for /F "usebackq tokens=1,*" %%i in ( "%BASEDIR%\lib\lib.txt" ) do set %%i_HOME=%BASEDIR%\lib\%%j

if not exist %ANT_HOME% (
  echo ANT_HOME is not valid. Please update '%BASEDIR%\lib\lib.txt' file.
  echo Syntax : ANT ^<ApacheAnt-path-relativeTo-lib-folder^>
  exit /b 1
)

if not exist %JAVA_HOME% (
  echo JAVA_HOME is not valid. Please update '%BASEDIR%\lib\lib.txt' file.
  echo Syntax : JAVA ^<JDK-path-relativeTo-lib-folder^>
  exit /b 1
)

set sfi.option=
REM  -Dsfi.exec.mode=TEST

call "%ANT_HOME%\bin\ant.bat" -f "%BASEDIR%\bin\engine\engine.ant" -Dsfi.profile=win32 -Dcommand=%1 %sfi.option%

if errorlevel 1 pause
@endlocal
