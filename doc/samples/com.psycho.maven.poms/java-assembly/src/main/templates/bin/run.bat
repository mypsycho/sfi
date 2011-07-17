@echo off
if "%OS%" == "Windows_NT" setlocal
rem ---------------------------------------------------------------------------
rem Entry point of ${project.artifactId}
rem
rem Environment Variable Prequisites ${undefined}
rem
rem
rem   ${project.scriptName}_OPTS   (Optional) Java runtime options used when 
rem                   command is executed.
rem
rem   JAVA_HOME       Must point at your Java Development Kit installation
rem                   or your Java Runtime Environment installation
rem
rem
rem ---------------------------------------------------------------------------

rem Identification of installation directory
set ${project.scriptName}_HOME=%~dp0.\..


rem Get standard environment variables
if exist "%${project.scriptName}_HOME%\bin\setenv.bat" call "%${project.scriptName}_HOME%\bin\setenv.bat"


rem Make sure prerequisite environment variables are set
if not "%JAVA_EXEC%" == "" goto run
if not "%JAVA_HOME%" == "" goto gotJavaHome
set JAVA_EXEC=java
goto run
:gotJavaHome
set JAVA_EXEC="%JAVA_HOME%\bin\java"
goto run
:run

%JAVA_EXEC% %${project.scriptName}_OPTS% -jar "%${project.scriptName}_HOME%\${project.build.jar-path}\${project.groupId}\${project.build.jar-finalName}.jar" %*
if errorlevel 1 pause

if "%OS%" == "Windows_NT" endlocal