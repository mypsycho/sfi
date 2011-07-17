/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.catalina.realm;

import java.io.IOException;
import javax.naming.CommunicationException;
import org.apache.catalina.LifecycleException;

/**
 * <p>This extension of JNDIRealm does not force the directory validation at 
 * start.</p>
 * Default implementation checks connection at start which is undesired when 
 * the directory is embedded. Moreover, requests will not be propagated unless
 * all applications are started: Connection does not need to be up until after
 * the host si fully started.
 *
 */

public class ExtendedJNDIRealm extends JNDIRealm {

    protected String validedStart = "true";
    
    /**
     * Return the connection password for this Realm.
     */
    public String getValidedStart() {
        return (this.validedStart);
    }


    /**
     * Set the connection password for this Realm.
     *
     * @param connectionPassword The new connection password
     */
    public void setValidedStart(String value) {
        this.validedStart = value;
    }

    
    /**
     * Prepare for active use of the public methods of this Component.
     *
     * @exception LifecycleException if this component detects a fatal error
     *  that prevents it from being started
     */
    public void start() throws LifecycleException {

        try {
            super.start();
        } catch (LifecycleException e) {
		
            if ( Boolean.parseBoolean( getValidedStart() ) ) {
                throw e;
            }
			
            Throwable cause = e.getThrowable();
            if ( !( cause instanceof CommunicationException ) ) {
                throw e;
            }
            // containerLog.warn( e.getMessage() , e );
        }

    }

}

