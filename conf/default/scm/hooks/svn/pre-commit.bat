set JAVA_HOME=@jdk.home@
set ANT_HOME=@ant.home@

call "%ANT_HOME%\bin\ant.bat" -f "%~dp0.\svn-hook.ant" "-Drepository=%1" "-Dtransaction=%2" pre-commit 1>&2