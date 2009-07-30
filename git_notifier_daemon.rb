#!/usr/bin/env ruby

# TODO 
# 1) Error handling with notifications
# 2) demonization
# 3) Create gem




require 'rubygems'
require 'daemons'
require 'ruby-growl'
require 'digest/sha1'

# Initialize the app while we're not a daemon
def init()
  uri   = ARGV[0]
  @@branch = ARGV[1] || 'master'

  @@repo_path = "/var/tmp/git_#{Digest::SHA1.hexdigest(uri)}_#{@@branch}"
  if !File.exists?( @@repo_path )
    `mkdir #{@@repo_path}; cd #{@@repo_path}; git clone #{uri} . >/dev/null 2>&1`
  end
end

init()

# Daemons.run_proc('git_notifier') do
  g = Growl.new "localhost", "ruby-growl", ["git_notifier"]
  g.notify "git_notifier", "GIT Notifier", "Start watching\nrepo: #{ARGV[0]}\nbranch: #{@@branch}"

  loop do
    git_pull_output = `cd #{@@repo_path}; git checkout -b #{@@branch} >/dev/null 2>&1; git pull origin #{@@branch} 2>/dev/null`

    if git_pull_output =~ /Updating (.+)\.\.(.+)/
      from_commit = $1
      to_commit   = $2

      git_log_output = `cd #{@@repo_path}; git log -1 $1`

      notification_lines = git_log_output.split( "\n" )
      sha1 = notification_lines[ 0 ]
      author = notification_lines[ 1 ]
      date = notification_lines[ 2 ]
      body = notification_lines[ 3 .. notification_lines.size - 1 ].to_s.gsub( /\t/, '')
      # TODO truncate commit sha1 and author name stripping off email

      g.notify "git_notifier", sha1 + date, author + "\n" + body
      sleep( 60 )
    end
  end
# end