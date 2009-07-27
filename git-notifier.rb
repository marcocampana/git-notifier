require 'rubygems'
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
#   ruby_cl_skeleton [options] source_file
#
#   For help use: ruby_cl_skeleton -h
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


require 'ruby-growl'
require 'optparse' 
require 'rdoc/usage'
require 'ostruct'
require 'date'

class App
  VERSION = '0.0.1'
  APPNAME = 'git-notifier'
  
  attr_reader :options

  def initialize(arguments, stdin)
    @arguments = arguments
    @stdin = stdin
    
    # Set defaults
    @options = OpenStruct.new
    # @options.quiet = false
    # TO DO - add additional defaults
  end


  # Parse options, check arguments, then process the command
  def run
    if parsed_options? && arguments_valid? 
      start_notifier
    else
      RDoc::usage('usage') # gets usage from comments above
    end
  end


  protected


  def parsed_options?
    
    # Specify options
    opts = OptionParser.new 
    opts.on('-v', '--version') { puts "#{APPNAME} version #{VERSION}"; exit 0 }
    opts.on('-h', '--help')    { RDoc::usage() } #exits app 
    # TO DO - add additional options
          
    opts.parse!(@arguments) rescue return false
    true      
  end


  # True if required arguments were provided
  def arguments_valid?
    # TO DO - implement your real logic here
    true #true if @arguments.length == 1 
  end


  def start_notifier
    while( 1 ) do
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

        g = Growl.new "localhost", "ruby-growl", ["git-notifier"]
        g.notify "git-notifier", sha1 + date, author + "\n" + body
        sleep( 60 )
      end
    end
  end


  def process_standard_input
    input = @stdin.read      
    # TO DO - process input
    
    # [Optional]
    # @stdin.each do |line| 
    #  # TO DO - process each line
    #end
  end


end

# Create and run the application
app = App.new(ARGV, STDIN)
app.run