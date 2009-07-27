#!/usr/bin/env ruby
require 'rubygems'        # if you use RubyGems
require 'daemons'
require 'ruby-growl'

# Initialize the app while we're not a daemon
# init()

path   = ARGV[0]
branch = ARGV[1]

# Daemons.run_proc('git_notifier') do
  g = Growl.new "localhost", "ruby-growl", ["git-notifier"]

  loop do
    git_pull_output = `git pull`

    if git_pull_output =~ /Updating (.+)\.\.(.+)/
      from_commit = $1
      to_commit   = $2

      git_log_output = `git log -1 $1`

      notification_lines = git_log_output.split( "\n" )
      sha1 = notification_lines[ 0 ]
      author = notification_lines[ 1 ]
      date = notification_lines[ 2 ]
      body = notification_lines[ 3 .. notification_lines.size - 1 ].to_s.gsub( /\t/, '')
      # TODO truncate commit sha1 and author name stripping off email

      g.notify "git-notifier", sha1 + date, author + "\n" + body
      sleep( 60 )
    end
  end
# end