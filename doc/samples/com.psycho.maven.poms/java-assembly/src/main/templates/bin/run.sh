#!/bin/sh

# ---------------------------------------------------------------------------
# Entry point of ${project.artifactId}
#
# Environment Variable Prequisites
#
#
#   ${project.scriptName}_OPTS   (Optional) Java runtime options used when 
#                   command is executed.
#
#   JAVA_HOME       Must point at your Java Development Kit installation.
#                   or your Java Runtime Environment installation
#
#
# ---------------------------------------------------------------------------

# Identification of installation directory
#   resolve links - $0 may be a softlink
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
${project.scriptName}_HOME=`dirname "$PRG"`/..


# Get standard environment variables
if [ -r "$$${project.scriptName}_HOME/bin/setenv.sh" ]; then
  chmod u+x "$$${project.scriptName}_HOME/bin/setenv.sh"
  . "$$${project.scriptName}_HOME/bin/setenv.sh"
fi


# Make sure prerequisite environment variables are set
if [ -z "$JAVA_EXEC" ]; then
  if [ -z "$JAVA_HOME" ]; then
    JAVA_EXEC=java
  else
    JAVA_EXEC="$JAVA_HOME/bin/java"
  fi
fi

$JAVA_EXEC $$${project.scriptName}_OPTS -jar "$$${project.scriptName}_HOME/${project.build.jar-path}/${project.groupId}/${project.build.jar-finalName}.jar" %*
