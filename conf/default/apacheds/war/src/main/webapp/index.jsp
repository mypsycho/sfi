<%@ page import="org.apache.directory.server.core.DirectoryService" %>
<%@ page import="javax.naming.*" %>


<%
    DirectoryService dirService = (DirectoryService) application.getAttribute( DirectoryService.JNDI_KEY );
    String state = "started";
    if (!dirService.isStarted()) {
      state = "not started";
    }
    InitialContext ic = new InitialContext();
    int port = 10389; // Default LDAP
    try {
        port = (Integer) ic.lookup("java:comp/env/port");
    } catch ( NamingException ignore ) { }
%>

ApacheDS is <%= state %> at port <%= port %>.