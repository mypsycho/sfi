@echo off

#   Licensed to the Apache Software Foundation (ASF) under one or more
#   contributor license agreements.  See the NOTICE file distributed with
#   this work for additional information regarding copyright ownership.
#   The ASF licenses this file to You under the Apache License, Version 2.0
#   (the "License"); you may not use this file except in compliance with
#   the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

export M2_HOME=@deploy.dir@/@buildTool.install.tofile@
export RUBY_HOME=@deploy.dir@/@ruby.install.tofile@
export JAVA_HOME=@jdk.home@
export ANT_HOME=@ant.home@
export JGIT_HOME=@deploy.dir@\jgit

export PATH=$JGIT_HOME/bin;$M2_HOME/bin;$JAVA_HOME/bin;$RUBY_HOME/bin;$ANT_HOME/bin;$PATH

export RAILS_ENV=production

# utilisé par GEM
export HTTP_PROXY=http://@proxy.host@:@proxy.port@

export mvn="M2_HOME/bin/mvn -s $M2_HOME/conf/maven-user-settings.xml"
