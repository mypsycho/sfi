/*
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
package org.apache.directory.webapp;

import java.io.File;
import java.util.List;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.log4j.Logger;

import org.apache.directory.shared.ldap.schema.SchemaManager;
import org.apache.directory.shared.ldap.schema.ldif.extractor.SchemaLdifExtractor;
import org.apache.directory.shared.ldap.schema.ldif.extractor.impl.ClAwareSchemaLdifExtractor;
import org.apache.directory.shared.ldap.schema.loader.ldif.LdifSchemaLoader;
import org.apache.directory.shared.ldap.schema.manager.impl.DefaultSchemaManager;
import org.apache.directory.shared.ldap.schema.registries.SchemaLoader;

import org.apache.directory.server.constants.ServerDNConstants;
import org.apache.directory.server.core.DefaultDirectoryService;
import org.apache.directory.server.core.DirectoryService;
import org.apache.directory.server.core.schema.SchemaPartition;
import org.apache.directory.server.core.partition.Partition;
import org.apache.directory.server.core.partition.impl.btree.jdbm.JdbmIndex;
import org.apache.directory.server.core.partition.impl.btree.jdbm.JdbmPartition;
import org.apache.directory.server.core.partition.ldif.LdifPartition;
import org.apache.directory.server.ldap.LdapServer;
import org.apache.directory.server.protocol.shared.transport.TcpTransport;




/**
 * A Servlet context listener to start and stop ApacheDS.
 * <p>
 * This class is derivated from an example provided by 'Apache Directory Project'.
 * It introduces the selvet parameters 'port' and 'data'.
 * </p>
 * 
 * @author <a href="mailto:dev@directory.apache.org">Apache Directory Project</a>
 */
public class StartStopListener implements ServletContextListener
{

    public static final String SERVLET_ENV_PREFIX = "java:comp/env/";
    
    public static final String PORT_ENV = SERVLET_ENV_PREFIX + "port";
    
    public static final String DATA_ENV = SERVLET_ENV_PREFIX + "data";
    
    public static final String DN_ENV = SERVLET_ENV_PREFIX + "partitionDn";

    protected static final Logger LOGGER = Logger.getLogger( StartStopListener.class );
    
    private DirectoryService dirService;

    private LdapServer ldapServer;

    /**
     * Startup ApacheDS embedded.
     */
    public void contextInitialized( ServletContextEvent evt )
    {
        try
        {
            dirService = new DefaultDirectoryService();
            dirService.setShutdownHookEnabled( true );

            ldapServer = new LdapServer();
            ldapServer.setDirectoryService( dirService );
            ldapServer.setAllowAnonymousAccess( false );

            // Set LDAP port to 10389
            InitialContext ic = new InitialContext();
            int port = 10389; // Default LDAP
            try {
                port = ( Integer ) ic.lookup( PORT_ENV );
            } catch ( NamingException ignore ) {
                warnInvalidProperty(PORT_ENV, port, ignore);
            }
            
            TcpTransport ldapTransport = new TcpTransport( port );
            ldapServer.setTransports( ldapTransport );

            // Determine an appropriate working directory
            ServletContext servletContext = evt.getServletContext();
            File workingDir = ( File ) servletContext.getAttribute( "javax.servlet.context.tempdir" );
            try {
                workingDir = new File( ( String ) ic.lookup( DATA_ENV ) );
            } catch ( NamingException ignore ) {
                warnInvalidProperty(DATA_ENV, workingDir, ignore);
            }
            
            
            dirService.setWorkingDirectory( workingDir );

            // first load the schema
            initSchemaPartition();
        
            // then the system partition
            // this is a MANDATORY partition
            String partitionDn =  ServerDNConstants.SYSTEM_DN;
            try {
                partitionDn = ( String ) ic.lookup(DN_ENV);
            } catch ( NamingException ignore ) {
                warnInvalidProperty(DN_ENV, partitionDn, ignore);        
            }
            
            Partition systemPartition = addPartition( "system", partitionDn );
            dirService.setSystemPartition( systemPartition );
            
            dirService.startup();
            ldapServer.start();

            // Store directoryService in context to provide it to servlets etc.
            servletContext.setAttribute( DirectoryService.JNDI_KEY, dirService );
        }
        catch ( Exception e )
        {
            throw new RuntimeException( e );
        }
    }

    protected void warnInvalidProperty( String property , Object defaultValue, Exception cause) {
        String name = property.substring( SERVLET_ENV_PREFIX.length() );
        LOGGER.warn("Property '" + name + "' is invalid, "
            + "using default value = " + defaultValue + ".", cause);
    }
    
    
    /**
     * Add a new partition to the server
     *
     * @param partitionId The partition Id
     * @param partitionDn The partition DN
     * @return The newly added partition
     * @throws Exception If the partition can't be added
     */
    private Partition addPartition( String partitionId, String partitionDn ) throws Exception
    {
        // Create a new partition named 'foo'.
        JdbmPartition partition = new JdbmPartition();
        partition.setId( partitionId );
        partition.setPartitionDir( new File( dirService.getWorkingDirectory(), partitionId ) );
        partition.setSuffix( partitionDn );
        dirService.addPartition( partition );

        return partition;
    }
    
    /**
     * initialize the schema manager and add the schema partition to directory service
     *
     * @throws Exception if the schema LDIF files are not found on the classpath
     */
    private void initSchemaPartition() throws Exception
    {
        SchemaPartition schemaPartition = dirService.getSchemaService().getSchemaPartition();

        // Init the LdifPartition
        LdifPartition ldifPartition = new LdifPartition();
        String workingDirectory = dirService.getWorkingDirectory().getPath();
        ldifPartition.setWorkingDirectory( workingDirectory + "/schema" );

        // Extract the schema on disk (a brand new one) and load the registries
        SchemaLdifExtractor extractor = new ClAwareSchemaLdifExtractor( new File( workingDirectory ) );
        extractor.extractOrCopy( true );

        schemaPartition.setWrappedPartition( ldifPartition );

        SchemaLoader loader = new LdifSchemaLoader( new File( workingDirectory, "schema" ) );
        SchemaManager schemaManager = new DefaultSchemaManager( loader );
        dirService.setSchemaManager( schemaManager );

        // We have to load the schema now, otherwise we won't be able
        // to initialize the Partitions, as we won't be able to parse 
        // and normalize their suffix DN
        schemaManager.loadAllEnabled();

        schemaPartition.setSchemaManager( schemaManager );

        List<Throwable> errors = schemaManager.getErrors();

        if ( !errors.isEmpty() )
        {
            throw new Exception( "Schema load failed : " + errors );
        }
    }
    
    
    /**
     * Shutdown ApacheDS embedded.
     */
    public void contextDestroyed( ServletContextEvent evt )
    {
        try
        {
            ldapServer.stop();
            dirService.shutdown();
        }
        catch ( Exception e )
        {
            throw new RuntimeException( e );
        }
    }
}
