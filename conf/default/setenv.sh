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


# We are at <SFI_HOME>/deploy

export SFI_HOME=`dirname $0`

export M2_HOME=$SFI_HOME/deploy/@buildTool.install.tofile@
export RUBY_HOME=$SFI_HOME/deploy/@ruby.install.tofile@
export JAVA_HOME=$SFI_HOME/repository/@javaSDK.path@
export ANT_HOME=$SFI_HOME/repository/@ant.path@

export PATH=$M2_HOME/bin;$JAVA_HOME/bin;$RUBY_HOME/bin;$PATH

export RAILS_ENV=production

# utilisé par GEM
export HTTP_PROXY=http://proxy.mdp:3128

export mvn="M2_HOME/bin/mvn.bat" -s $M2_HOME/conf/maven-user-settings.xml
