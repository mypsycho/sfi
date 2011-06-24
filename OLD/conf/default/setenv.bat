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


REM We are at %SFINSTALL_HOME%\deploy
set SFI_HOME=%~dp0.\..

set M2_HOME=%SFI_HOME%\deploy\@buildTool.install.tofile@
set RUBY_HOME=%SFI_HOME%\deploy\@ruby.install.tofile@
set JAVA_HOME=%SFI_HOME%\repository\@javaSDK.path@
set ANT_HOME=%SFI_HOME%\repository\@ant.path@

set PATH=%M2_HOME%\bin;%JAVA_HOME%\bin;%RUBY_HOME%\bin;%PATH%

set RAILS_ENV=production

REM utilisé par GEM
set HTTP_PROXY=http://proxy.mdp:3128

set mvn=call "%M2_HOME%\bin\mvn.bat" -s %M2_HOME%\conf\maven-user-settings.xml
