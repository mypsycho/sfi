# Copyright (c) 2010 Martin Corino

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'dispatcher'
require 'redmine'

require 'java'
Dir[File.dirname(__FILE__) + "/lib/*.jar"].each { |jar| require jar }

Redmine::Plugin.register :redmine_svnkit do
  name 'Svnkit'
  author 'Martin Corino'
  description 'Use svnkit as backend to access Subversion repositories'
  url 'http://github.com/mcorino/redmine_svnkit_adapter'
  author_url 'http://www.remedy.nl'
  version '0.1.0'

  requires_redmine :version_or_higher => '0.9.0'
end

require_dependency 'repository/subversion'

class Repository::Subversion

  def scm_adapter_with_svnkit
    Redmine::Scm::Adapters::SubversionSvnkitAdapter
  end

  alias_method_chain :scm_adapter, :svnkit

end

Dispatcher.to_prepare do
  org.tmatesoft.svn.core.internal.io.dav.DAVRepositoryFactory.setup
  org.tmatesoft.svn.core.internal.io.svn.SVNRepositoryFactoryImpl.setup
  org.tmatesoft.svn.core.internal.io.fs.FSRepositoryFactory.setup
end