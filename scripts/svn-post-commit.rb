#!/usr/bin/ruby -w

BASECAMP_URL = 'myurl.clientsection.com'
BASECAMP_USER = ''
BASECAMP_PASSWORD = ''
BASECAMP_MESSAGE_CATEGORY = ''
BASECAMP_COMPANY_NAME = ''
BASECAMP_PROJECT_NAME = ''
SHOW_CODE_CHANGES = true
LOG_PREPEND = '\n-{2}'

begin
 require 'basecamp'
rescue LoadError
  %x{echo "repo:#{ARGV[0]} rev: #{ARGV[1]}" > /tmp/svn-hooks.log}
  %x{echo "Error: #{$!} trace:#{caller}" >> /tmp/svn-hooks.log}
end

def swap_word(abr)
	case abr
		when 85
			"Updated"
		when 65
			"Added"
		when 68
			"Deleted"
	end
end
	
def gather_and_post(repo_path, revision)
  
  svnlook = '/usr/local/bin/svnlook'

  commit_author = `#{svnlook} author #{repo_path} -r #{revision}`.chop
  commit_log = `#{svnlook} log #{repo_path} -r #{revision}`
  commit_diff = `#{svnlook} diff #{repo_path} -r #{revision}`
  commit_date = `#{svnlook} date #{repo_path} -r #{revision}`
  commit_changed = `#{svnlook} changed #{repo_path} -r #{revision}`


  message_title = 'Rev. ' + revision.to_s + '  [' + commit_log.split(/\n/)[0].gsub(/-/,'').strip.capitalize + ']'

  if message_title.length > 127
    message_title = message_title[0..127]
    message_title += ''
  end

  commit_log_textilized = ''

  commit_log.split(%r{#{LOG_PREPEND}}).collect do |log_item|
    commit_log_textilized << "* #{log_item.gsub(/-/,'').gsub(/\n/,'<br/>').capitalize}\n"
  end

  commit_changed_textilized = ''


    commit_changed.each do |line|
      matches = line.match(/^\w\s+(.*)/)
	    file_status = swap_word(matches[0][0])
      commit_changed_textilized << "* <small>*#{file_status}:*</small> <code>#{matches[1]}</code>\n"
    end

  if SHOW_CODE_CHANGES
    message_body = <<-END_MSG
h2. Summary:

#{commit_log_textilized}

h2. Changed files:

#{commit_changed_textilized}

END_MSG
  else
    message_body = <<-END_MSG
h2. Summary:

#{commit_log_textilized}

END_MSG
  end

  
  session = Basecamp.new(BASECAMP_URL,BASECAMP_USER,BASECAMP_PASSWORD)
  return unless session

  basecamp_project = session.projects.find do |bc_project|
   (bc_project['company']['name'] =~ %r{#{Regexp.escape BASECAMP_COMPANY_NAME}}i) && (bc_project['name'] =~ %r{#{Regexp.escape BASECAMP_PROJECT_NAME}}i)
  end

  if basecamp_project
    basecamp_category = session.message_categories(basecamp_project['id']).find do |bc_category|
      bc_category['name'] == BASECAMP_MESSAGE_CATEGORY
    end


    if basecamp_category
      msg = session.post_message(basecamp_project['id'], {:title => message_title,
                                          :body => message_body,
                                          :category_id => basecamp_category['id'],
										  :use_textile => 1})
    end
  end
end

#Log the repo passed in to test the file

begin
  gather_and_post(ARGV[0], ARGV[1])
rescue
  %x{echo "repo:#{ARGV[0]} rev: #{ARGV[1]}" > /tmp/svn-hooks.log}
  %x{echo "Error: #{$!} trace:#{caller}" >> /tmp/svn-hooks.log}
end
