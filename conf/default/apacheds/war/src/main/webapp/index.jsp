<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<%@ page import="org.apache.directory.server.core.DirectoryService" %>
<%@ page import="javax.naming.*" %>

<html>
<head>
<title>Apache Directory status</title>
</head>
<body>
<%
    DirectoryService dirService = (DirectoryService) application.getAttribute( DirectoryService.JNDI_KEY );
    String state = "started";
    if ( !dirService.isStarted() ) {
      state = "not started";
    }
    InitialContext ic = new InitialContext();
    int port = 10389; // Default LDAP
    try {
        port = (Integer) ic.lookup( "java:comp/env/port" );
    } catch ( NamingException ignore ) { }
%>

ApacheDS is <%= state %> at port <%= port %>.
</body>
</html>