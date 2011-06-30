#!/bin/sh

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# For copy-and-run reason, we do not generate this value the using ${java.home}
export JAVA_HOME=@jdk.home@

export MAVEN_HOME=@deploy.dir@/@buildTool.install.tofile@
export PLEXUS_NEXUS_WORK=@deploy.dir@/nexus


# We must avoid path from properties file for portability reason
export CATALINA_OPTS="-Xmx512m -XX:PermSize=256m"
# Jenkins options
export CATALINA_OPTS="${CATALINA_OPTS} -Djava.awt.headless=true -DJENKINS_HOME=@deploy.java-dir@/@intContTool.name@"
