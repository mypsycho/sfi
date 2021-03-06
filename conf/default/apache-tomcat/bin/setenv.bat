

REM Licensed to the Apache Software Foundation (ASF) under one or more
REM contributor license agreements.  See the NOTICE file distributed with
REM this work for additional information regarding copyright ownership.
REM The ASF licenses this file to You under the Apache License, Version 2.0
REM (the "License"); you may not use this file except in compliance with
REM the License.  You may obtain a copy of the License at
REM
REM     http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.


REM For copy-and-run reason, we do not generate this value the using ${java.home}
set JAVA_HOME=@jdk.home@

set MAVEN_HOME=@deploy.dir@\@buildTool.install.tofile@


REM We must avoid path from properties file for portability reason
set CATALINA_OPTS=-Xmx512m -XX:PermSize=256m
REM Jenkins requires awt.headless
set CATALINA_OPTS=%CATALINA_OPTS% -Djava.awt.headless=true 
set CATALINA_OPTS=%CATALINA_OPTS% "-DJENKINS_HOME=@deploy.java-dir@/@intContTool.name@"
set CATALINA_OPTS=%CATALINA_OPTS% "-Dplexus.nexus-work=@deploy.dir@\nexus"
set CATALINA_OPTS=%CATALINA_OPTS% "-Dscm.home=@deploy.dir@\scm"