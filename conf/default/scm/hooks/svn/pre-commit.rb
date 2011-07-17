 #!/usr/local/bin/ruby
 
 repo_path = ARGV[0]
 transaction = ARGV[1]
 svnlook = 'C:\Program Files\CollabNet Subversion Server\svnlook.exe'
 database = 'C:\ruby\bin\sqlite3.exe C:\Data\redmine\db\production.db'
 
 commit_log = `#{svnlook} log #{repo_path} -t #{transaction}`
 
 if (commit_log == nil || commit_log.length < 2)
   STDERR.puts("Log message cannot be empty.")
   exit(1)
 end
 
 if (commit_log =~ /^(refs|references|IssueID|fixes|closes)\s*#(\d+)/i)
   issue_number = $2
   sql = "SELECT COUNT(*) AS result FROM issues I INNER JOIN issue_statuses S ON S.id = I.status_id WHERE S.is_closed = 'f' AND I.id = #{issue_number};" 
   redmine_issue_open = `echo #{sql} | #{database}`.strip()
   if (redmine_issue_open.eql?("0"))
     STDERR.puts("Redmine issue #{issue_number} is not in an open state.")
     exit(1)
   end
 else
   STDERR.puts("You didn't specify a Redmine issue number on the first line, e.g.:
     Refs #1234
     Your message goes here...")
   exit(1)
 end