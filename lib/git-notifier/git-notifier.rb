#!/usr/bin/env ruby
# == Synopsis
#   This is a sample description of the application.
#   Blah blah blah.
#
# == Usage
#   git-notifier start|stop|add|clear|status
#
#   Start the notifier:
#     git-notifier start
# 
#   Stop the notifier:
#     git-notifier stop
#
#   Add a repository to the watch list:
#     git-notifier add <repo_uri> <branch>
#     Example: git-notifier add git@github.com:marcocampana/git-notifier.git master
# 
#   Remove all watched repositories from the watch list
#     git-notifier clear
# 
#   Show all the watched repositories
#     git-notifier status
# 
# == Author
#   Marco Campana <m.campana@gmail.com>
#   http://xterm.it/blog
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

def add_repo
  (RDoc::usage('usage') and return) if ARGV.size < 2
  repo_uri        = ARGV[1]
  branch          = ARGV[2] || 'master'
  repo_name       = repo_uri.split("/").last
  repo_local_path = "/var/tmp/git-notifier_#{Digest::SHA1.hexdigest(repo_uri)}_#{repo_name}_#{branch}"
  # TODO Truncate the SHA1 in the filename

  if !File.exists?( repo_local_path )
    puts "git-notifier: adding #{repo_uri} to watch list... (this might take a while)"
    output = `mkdir #{repo_local_path}; cd #{repo_local_path}; git clone #{repo_uri} . 2>/dev/null`
    # TODO Add error handling in case the repo does not exist
  end
  puts "git-notifier: repo '#{repo_uri}' added to watch list"
end

def start
  demonize
end

def stop
  demonize
  puts "git-notifier is now stopped"
end

def status
  watched_repos = []
  available_repos.each do |repo_dirname|
    prefix, repo_sha1, repo_name, repo_branch = repo_dirname.split('_')
    watched_repos << [repo_name, repo_branch]
  end
  if watched_repos.any?
    # TODO Show if the notifier is running or not
    puts "git-notifier: the following repositories are in the watch list"
    watched_repos.each do |repo|
      puts " - #{repo[0]} (#{repo[1]})"
    end
  else
    puts "git-notifier: no repositories are being watched at the moment\nUse: 'git-notifier add <repo_uri>' to add repos to watch"
  end
end

def available_repos
  repos = []
  Dir.new('/var/tmp').each do |repo_dir|
    repos << repo_dir if repo_dir =~ /^git-notifier/ 
  end
  repos
end

def clear_all
  repos = available_repos
  repos.each do |repo|
    puts "/var/tmp/#{repo} deleted"
    `cd /var/tmp; rm -Rf #{repo}` if repo =~ /^git-notifier/
  end
  puts "git-notifier: no repositories are being watched at the moment\nUse: 'git-notifier add <repo_uri>' to add repos to watch" if repos.empty?
end

def demonize
  Daemons.run_proc('git-notifier', :dir_mode => :normal, :dir => 'pids/', :monitor => false) do
    g = Growl.new "localhost", "ruby-growl", ["git-notifier"]
    # g.notify "git-notifier", "GIT Notifier", "Start watching\nrepo: #{ARGV[0]}\nbranch: #{@@branch}"
    g.notify "git-notifier", "GIT Notifier", "Start notifier"

    loop do
      # TODO store available_repoes in a variable if adding while running doesn't work
      available_repos.each do |repo_dirname|
        prefix, repo_sha1, repo_name, repo_branch = repo_dirname.split('_')
        
        git_pull_output = `cd /var/tmp/#{repo_dirname}; git checkout -b #{repo_branch} >/dev/null 2>&1; git pull origin #{repo_branch} 2>/dev/null`

        if git_pull_output =~ /Updating (.+)\.\.(.+)/
          from_commit = $1
          to_commit   = $2

          git_log_output = `cd /var/tmp/#{repo_dirname}; git log -1 $1`

          notification_lines = git_log_output.split( "\n" )
          sha1 = notification_lines[0]
          author = notification_lines[1]
          date = notification_lines[2]
          body = notification_lines[3 .. notification_lines.size - 1].to_s.gsub( /\t/, '')
          # TODO truncate commit sha1 and author name stripping off email

          g.notify "git-notifier", sha1 + date, author + "\n" + body
        end
        # TODO increase sleep time
        sleep( 60 )
      end
    end
  end
end

case ARGV[0]
  when 'start'
    start
  when 'add'
    add_repo
  when 'stop'
    stop
  when 'clear'
    clear_all
  when 'status'
    status
  else
    RDoc::usage('usage')
end

