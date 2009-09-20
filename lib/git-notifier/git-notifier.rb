#!/usr/bin/env ruby
# == Synopsis
#   This is a sample description of the application.
#   Blah blah blah.
#
# == Examples
#   This command does blah blah blah.
#     ruby_cl_skeleton foo.txt
#
#   Other examples:
#     ruby_cl_skeleton -q bar.doc
#     ruby_cl_skeleton --verbose foo.html
#
# == Usage
#   git-notifier start uri
#
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#   -q, --quiet         Output as little as possible, overrides verbose
#   -V, --verbose       Verbose output
#   TO DO - add additional options
#
# == Author
#   Marco Campana <m.campana@gmail.com>
#
# == Copyright
#   Copyright (c) 2009 Marco Campana. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

# TODO
# 1) Error handling with notifications
# 4) check dependencies at startup
# 5) complete help() above

require 'rubygems'
require 'daemons'
require 'ruby-growl'
require 'digest/sha1'
require 'rdoc/usage'

# TODO remove this
require 'ruby-debug'

# Initialize the app while we're not a daemon
def init()
  repo_uri    = ARGV[1]
  @@branch    = ARGV[2] || 'master'
  @@repo_path = "/var/tmp/git_#{Digest::SHA1.hexdigest(repo_uri)}_#{@@branch}"

  if !File.exists?( @@repo_path )
    puts "Starting up notifier... (this might take a while)"
    `mkdir #{@@repo_path}; cd #{@@repo_path}; git clone #{uri} .`
  end
  puts "git-notifier is now active"
rescue
  RDoc::usage('usage')
end

def stop()
  puts "git-notifier is now stopped"
end

def clear()
end

init() if ARGV[0] == 'start'
stop() if ARGV[0] == 'stop'
clear() if ARGV[0] == 'clear'

Daemons.run_proc('git_notifier', :dir_mode => :normal, :dir => 'pids/' ) do
  g = Growl.new "localhost", "ruby-growl", ["git_notifier"]
  g.notify "git_notifier", "GIT Notifier", "Start watching\nrepo: #{ARGV[0]}\nbranch: #{@@branch}"

  loop do
    git_pull_output = `cd #{@@repo_path}; git checkout -b #{@@branch} >/dev/null 2>&1; git pull origin #{@@branch} 2>/dev/null`

    # TODO improve this, It doesn't work all the times
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
      # TODO increase sleep time
      sleep( 60 )
    end
  end
end