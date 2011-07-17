set JAVA_HOME=@java.home@
set ANT_HOME=@ant.home@

call %ANT_HOME%\bin\ant -f "~dp0.\svn-hook.ant" "-Drepository=%1" "-Dtransaction=%2" pre-commit