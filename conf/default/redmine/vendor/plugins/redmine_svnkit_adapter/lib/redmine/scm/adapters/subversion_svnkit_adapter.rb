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

module Redmine::Scm::Adapters
  class SubversionSvnkitAdapter < AbstractAdapter

    module Java
      module IO
        include_package 'org.tmatesoft.svn.core.io'
      end
      module Core
        include_package 'org.tmatesoft.svn.core'
      end
      module Util
        include_package 'org.tmatesoft.svn.util'
      end
      module API
        include_package 'org.tmatesoft.svn.core.wc'
      end
    end

    KIND = {
      Java::Core::SVNNodeKind::NONE => "none",
      Java::Core::SVNNodeKind::DIR => "dir",
      Java::Core::SVNNodeKind::FILE => "file",
      Java::Core::SVNNodeKind::UNKNOWN => "unknown"
    }

    class << self
      def client_version
        [Java::Util::Version.getMajorVersion.to_i,
         Java::Util::Version.getMinorVersion.to_i,
         Java::Util::Version.getMicroVersion.to_i]
      end
    end

    # Get info about the svn repository
    def info
      logger.debug("#{self.class.name}::info")
      info = nil
      begin
        with_wcclient() do |svncli, svnurl|
          svninfo = svncli.doInfo(svnurl, 
                                  Java::API::SVNRevision::HEAD,
                                  Java::API::SVNRevision::UNDEFINED)
          info = Info.new({:root_url => svninfo.getRepositoryRootURL.to_s,
                           :lastrev => Revision.new({
                             :identifier => svninfo.getCommittedRevision.getNumber.to_s,
                             :time => Time.parse(svninfo.getCommittedDate.toString).localtime,
                             :author => (svninfo.getAuthor ? svninfo.getAuthor : "")
                           })
                         })
        end
        logger.debug("#{self.class.name}::info - #{info.inspect}")
      rescue
        logger.error("#{$!}")
      end
      info
    end

    class EntryHandler
      include Java::Core::ISVNDirEntryHandler
      def initialize(path, entries)
        @path_pfx = path.empty? ? '' : "#{path}/"
        @entries = entries
      end
      def handleDirEntry(de)
        @entries.push(Entry.new({:name => de.getName,
                                 :path => "#{@path_pfx}#{de.getRelativePath}",
                                 :kind => KIND[de.getKind],
                                 :size => de.getSize,
                                 :lastrev =>
                                 Revision.new({ :identifier =>
                                                de.getRevision.to_s,
                                                :time => 
                                                Time.parse(de.getDate.toString).localtime,
                                                :author => de.getAuthor
                                              })
                               })) unless de.getRelativePath.blank?
      end
    end

    # Returns an Entries collection
    # or nil if the given path doesn't exist in the repository
    def entries(path=nil, identifier=nil)
      logger.debug("#{self.class.name}::entries(#{path}, #{identifier})")
      path ||= ''
      revision = (identifier and identifier.to_i > 0) ? 
        Java::API::SVNRevision.create(identifier.to_i) :
        Java::API::SVNRevision::HEAD
      entrylist = Entries.new
      begin
        with_logclient(path) do |svncli, svnurl|
          svncli.doList(svnurl,
                        revision, Java::API::SVNRevision::UNDEFINED,
                        true,
                        Java::Core::SVNDepth::IMMEDIATES,
                        Java::Core::SVNDirEntry::DIRENT_ALL,
                        EntryHandler.new(path, entrylist))
        end
        logger.debug("#{self.class.name}::entries - Found #{entrylist.size} entries in the repository for #{target(path)}")
      rescue
        logger.error("#{$!}")
      end
      entrylist.sort_by_name
      return entrylist
    end

    class PropertyHandler
      include Java::API::ISVNPropertyHandler
      def initialize(proplist)
        @properties = proplist
      end
      def handleProperty(url, property)
        @properties[property.getName] = property.getValue.to_s
      end
    end

    def properties(path, identifier=nil)
      logger.debug("#{self.class.name}::properties(#{path}, #{identifier})")
      revision = (identifier and identifier.to_i > 0) ?
        Java::API::SVNRevision.create(identifier.to_i) :
        Java::API::SVNRevision::HEAD
      proplist = {}
      begin
        with_wcclient(path) do |svncli, svnurl|
          svncli.doGetProperty(svnurl, nil, revision,
                               Java::API::SVNRevision::UNDEFINED,
                               Java::Core::SVNDepth::EMPTY,
                               PropertyHandler.new(proplist))
        end
      rescue
        logger.error("#{$!}")
      end
      proplist
    end

    class LogHandler
      include Java::Core::ISVNLogEntryHandler
      def initialize(revlist)
        @revisions = revlist
      end
      def handleLogEntry(le)
        begin
          paths = le.getChangedPaths.collect do |path, lepath|   ## path=String, lepath=SVNLogEntryPath
            { :action => lepath.getType.chr,
              :path => path,
              :from_path => lepath.getCopyPath,
              :from_revision => lepath.getCopyRevision.to_s }
          end
          paths.sort! { |x,y| x[:path] <=> y[:path] }
          @revisions << Revision.new({:identifier => le.getRevision.to_s,
                                      :author => le.getAuthor,
                                      :time => Time.parse(le.getDate.toString).localtime,
                                      :message => le.getMessage,
                                      :paths => paths
                                    })
        rescue
          logger.error("#{$!}\n#{$!.backtrace.join("\n")}")
          raise
        end
      end
    end

    def revisions(path=nil, identifier_from=nil, identifier_to=nil, options={})
      logger.debug("#{self.class.name}::revisions(#{path}, #{identifier_from}, #{identifier_to}, #{options})")
      path ||= ''
      revision_from = (identifier_from and identifier_from.to_i > 0) ?
        Java::API::SVNRevision.create(identifier_from.to_i) :
        Java::API::SVNRevision::HEAD
      revision_to = (identifier_to and identifier_to.to_i > 0) ?
        Java::API::SVNRevision.create(identifier_to.to_i) :
        Java::API::SVNRevision.create(0)
      revlist = Revisions.new
      begin
        with_logclient(path) do |svncli, svnurl|
          svncli.doLog(svnurl, [''].to_java(:string),
                       Java::API::SVNRevision::HEAD,
                       revision_from, revision_to,
                       false, # no stop-on-copy
                       options[:with_paths] || false,
                       options[:limit] || 0,
                       LogHandler.new(revlist))
        end
      rescue
        logger.error("#{$!}") unless Rails.configuration.environment =~ /production/
      end
      logger.debug("#{self.class.name}::revisions - Found #{revlist.size} revisions in the repository for #{target(path)} @ #{identifier_from}:#{identifier_to}")
      revlist
    end

    def diff(path, identifier_from, identifier_to=nil, type="inline")
      logger.debug("#{self.class.name}::diff(#{path}, #{identifier_from}, #{identifier_to}, #{type})")
      path ||= ''
      revision_from = (identifier_from and identifier_from.to_i > 0) ?
        Java::API::SVNRevision.create(identifier_from.to_i) :
        Java::API::SVNRevision::HEAD
      revision_to = (identifier_to and identifier_to.to_i > 0) ?
        Java::API::SVNRevision.create(identifier_to.to_i) :
        Java::API::SVNRevision.create(identifier_from.to_i-1)
      diff = []
      outfile = java.io.File.createTempFile('redmine', nil)
      begin
        output = java.io.FileOutputStream.new(outfile)
        with_diffclient(path) do |svncli, svnurl|
          svncli.doDiff(svnurl,
                        Java::API::SVNRevision::HEAD,
                        revision_from, revision_to,
                        Java::Core::SVNDepth::UNKNOWN,
                        false,
                        output)
        end
        output.flush
        output.close
        File.open(outfile.to_s) do |f|
          f.each_line {|line| diff << line}
        end
      rescue
        logger.error("#{$!}")
      end
      File.delete(outfile.to_s) rescue nil
      diff
    end

    def cat(path, identifier=nil)
      logger.debug("#{self.class.name}::cat(#{path}, #{identifier})")
      revision = (identifier and identifier.to_i > 0) ?
        Java::API::SVNRevision.create(identifier.to_i) :
        Java::API::SVNRevision::HEAD
      cat = nil
      begin
        output = java.io.ByteArrayOutputStream.new
        with_wcclient(path) do |svncli, svnurl|
          svncli.doGetFileContents(svnurl, revision,
                                   Java::API::SVNRevision::UNDEFINED,
                                   true,
                                   output)
        end
        output.flush
        cat = output.toString
      rescue
        logger.error("#{$!}")
      end
      cat
    end

    class AnnotateHandler
      include Java::API::ISVNAnnotateHandler
      def initialize(blame)
        @blame = blame
      end
      def handleLine(date, rev, author, line, mergedDate, mergedrev, mergedAuthor, mergedPath, linenr)
        @blame.add_line(line,
                        Revision.new(:identifier => rev.to_s,
                                     :author => author,
                                     :date => Time.parse(date.toString).localtime))
      end
      def handleRevision(*args)
        false
      end
      def handleEOF
      end
    end

    def annotate(path, identifier=nil)
      logger.debug("#{self.class.name}::annotate(#{path}, #{identifier})")
      revision = (identifier and identifier.to_i > 0) ?
        Java::API::SVNRevision.create(identifier.to_i) :
        Java::API::SVNRevision::HEAD
      blame = Annotate.new
      begin
        with_logclient(path) do |svncli, svnurl|
          svncli.doAnnotate(svnurl, revision,
                            Java::API::SVNRevision.create(1),
                            revision,
                            AnnotateHandler.new(blame))
        end
      rescue
        logger.error("#{$!}")
      end
      blame
    end

  private

    def client_manager
      options = Java::API::SVNWCUtil.createDefaultOptions(true)
      if @login.blank?
        Java::API::SVNClientManager.newInstance(options)
      else
        Java::API::SVNClientManager.newInstance(options, @login, @password.to_s)
      end
    end

    def with_wcclient(path = '')
      raise ArgumentError unless block_given?
      svncli = client_manager.getWCClient
      svnurl = Java::Core::SVNURL.parseURIDecoded(target(path))
      yield(svncli, svnurl)
    end

    def with_logclient(path = '')
      raise ArgumentError unless block_given?
      svncli = client_manager.getLogClient
      svnurl = Java::Core::SVNURL.parseURIDecoded(target(path))
      yield(svncli, svnurl)
    end

    def with_diffclient(path = '')
      raise ArgumentError unless block_given?
      svncli = client_manager.getDiffClient
      svnurl = Java::Core::SVNURL.parseURIDecoded(target(path))
      yield(svncli, svnurl)
    end

    def target(path = '')
      base = path.match(/^\//) ? root_url : url
      "#{base}/#{path}"
    end
  end
end