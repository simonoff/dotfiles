ANSI_BLACK    = "\033[0;30m"
ANSI_GRAY     = "\033[1;30m"
ANSI_LGRAY    = "\033[0;37m"
ANSI_WHITE    = "\033[1;37m"
ANSI_RED      = "\033[0;31m"
ANSI_LRED     = "\033[1;31m"
ANSI_GREEN    = "\033[0;32m"
ANSI_LGREEN   = "\033[1;32m"
ANSI_BROWN    = "\033[0;33m"
ANSI_YELLOW   = "\033[1;33m"
ANSI_BLUE     = "\033[0;34m"
ANSI_LBLUE    = "\033[1;34m"
ANSI_PURPLE   = "\033[0;35m"
ANSI_LPURPLE  = "\033[1;35m"
ANSI_CYAN     = "\033[0;36m"
ANSI_LCYAN    = "\033[1;36m"

ANSI_BACKBLACK  = "\033[40m"
ANSI_BACKRED    = "\033[41m"
ANSI_BACKGREEN  = "\033[42m"
ANSI_BACKYELLOW = "\033[43m"
ANSI_BACKBLUE   = "\033[44m"
ANSI_BACKPURPLE = "\033[45m"
ANSI_BACKCYAN   = "\033[46m"
ANSI_BACKGRAY   = "\033[47m"

ANSI_RESET      = "\033[0m"
ANSI_BOLD       = "\033[1m"
ANSI_UNDERSCORE = "\033[4m"
ANSI_BLINK      = "\033[5m"
ANSI_REVERSE    = "\033[7m"
ANSI_CONCEALED  = "\033[8m"

XTERM_SET_TITLE   = "\033]2;"
XTERM_END         = "\007"
ITERM_SET_TAB     = "\033]1;"
ITERM_END         = "\007"
SCREEN_SET_STATUS = "\033]0;"
SCREEN_END        = "\007"
Pry.config.commands.import Pry::ExtendedCommands::Experimental
Pry.config.pager = true
Pry.config.color = true
Pry.config.commands.command "add", "Add a list of numbers together" do |*args|
  output.puts "Result is: #{args.map(&:to_i).inject(&:+)}"
end
Pry.config.history.should_save = true
rails = File.join Dir.getwd, 'config', 'environment.rb'

if File.exist?(rails) && ENV['SKIP_RAILS'].nil?
  require rails
  name = "rails #{Rails.version}"
  colors = ANSI_BACKBLUE + ANSI_YELLOW
  if Rails.version[0..0] == "2"
    require 'console_app'
    require 'console_with_helpers'
  elsif Rails.version[0..0] == "3"
    require 'rails/console/app'
    require 'rails/console/helpers'
  end
else
  name = "ruby #{RUBY_VERSION}"
  colors = ANSI_BACKPURPLE + ANSI_YELLOW
end
Pry.config.prompt = [
  proc { |obj, nest_level|
    if nest_level == 0
      "#{colors}#{name}:#{ANSI_RESET} \n#{ANSI_BACKBLUE}#{ANSI_RED}>>#{ANSI_RESET} "
    else
      "#{ANSI_BACKBLUE}#{ANSI_RED}>>#{ANSI_RESET} "
    end
  }, 
  proc { |obj, nest_level| 
    p = ""
    if nest_level == 0
      p << "#{ANSI_GREEN}*#{ANSI_RESET} "
    else
      nest_level.times{ p << " "}
      p << "#{ANSI_GREEN}*#{ANSI_RESET} "
    end
    p   
  }
]