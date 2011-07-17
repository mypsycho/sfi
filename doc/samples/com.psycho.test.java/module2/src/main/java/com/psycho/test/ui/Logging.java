package com.psycho.test.ui;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;

/**
 * Class for ...
 * <p>Details</p>
 *
 * @author nperansi
 *
 */
public class Logging {

    public static final String LOGS_DIR_PROPERTY = "logs.dir";
    public static final String LOGS_CONF_PROPERTY = "log4j.configuration";
    public static final String DEFAULT_CONF = "conf/log4j.properties";
    public static final String PATH_TO_ROOT = "../..";
    
    
    
    public static void init() {
        // location jar:file:/D:/work/airbus/test/lib/com.psycho.test.java/module2-0.0.1-SNAPSHOT.jar!/com/psycho/test/ui/Launch.class
        
        URL location = Launch.class.getResource(Launch.class.getSimpleName() + ".class");
        File basedir = new File(".");
        if ("file".equals(location.getProtocol())) {
            // assume we are in class
            String className = Launch.class.getName();
            String path = location.getPath();
            path = path.substring(0, path.length() - className.length());
            basedir = new File(path);
        } else if ("jar".equals(location.getProtocol())) {
            try {
                String path = new URI(location.getPath()).getPath();
                path = path.substring(0, path.lastIndexOf("!"));
                path = path.substring(0, path.lastIndexOf("/"));
                basedir = new File(path, PATH_TO_ROOT);
                
            } catch (URISyntaxException e) {
                throw new Error(e);
            }
            System.out.println("location " + location);
        }
        
        if (System.getProperty(LOGS_DIR_PROPERTY) == null) {
            File logDir = new File(basedir, "logs");
            System.setProperty(LOGS_DIR_PROPERTY, logDir.getAbsolutePath());
        }
        
        // try to create the directory if possible
        new File(System.getProperty(LOGS_DIR_PROPERTY)).mkdirs();
        
        if (System.getProperty(LOGS_CONF_PROPERTY) == null) {
            System.setProperty(LOGS_CONF_PROPERTY, new File(basedir, DEFAULT_CONF).toURI().toString());
        }
    }
}
