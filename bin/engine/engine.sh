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


PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`
BASEDIR=`cd "$PRGDIR/../.." ; pwd`

# Note: Following approach ignores last line
# while read line; do echo $line; done < file

while true ; do
  # Reading input stream
  read -r i j
  eof=$?
  if [[ -n "${i}" ]] ; then 
    export ${i}_HOME="${BASEDIR}/lib/${j}"
  fi
  if [[ $eof != 0 ]] ; then 
    break
  fi
# Define the file as input stream
done < "${BASEDIR}/lib/lib.txt"


if [[ ! ( -d ${ANT_HOME} ) ]] ; then
  echo "ANT_HOME is not valid. Please update '${BASEDIR}/lib/lib.txt' file."
  echo "Syntax : ANT <ApacheAnt-path-relativeTo-lib-folder>"
  exit 1
fi
if [[ ! ( -d ${JAVA_HOME} ) ]] ; then
  echo "JAVA_HOME is not valid. Please update '${BASEDIR}/lib/lib.txt' file."
  echo "Syntax : JAVA <JDK-path-relativeTo-lib-folder>"
  exit 1
fi


chmod u+x "${ANT_HOME}/bin"/*


"${ANT_HOME}/bin/ant" -f "${BASEDIR}/bin/engine/engine.ant" -Dcommand=$1 engine
