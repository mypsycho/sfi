--   Licensed to the Apache Software Foundation (ASF) under one or more
--   contributor license agreements.  See the NOTICE file distributed with
--   this work for additional information regarding copyright ownership.
--   The ASF licenses this file to You under the Apache License, Version 2.0
--   (the "License"); you may not use this file except in compliance with
--   the License.  You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.

insert into auth_sources (
id, type, name, host, port, account, account_password, 
base_dn, attr_login, attr_firstname, attr_lastname, attr_mail, onthefly_register, tls 
) select 
1, 'AuthSourceLdap', 'Embedded', '127.0.0.1', @ldap.port@, '@ldap.bind.dn@', '@ldap.bind.password@', 
'@ldap.user.base@', 'uid', 'gn', 'sn', 'mail', true, false
from dual where not exists (select 1 from auth_sources s where s.id = 1)