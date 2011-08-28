def require_without_bundler(*gems)
  unless defined?(::Bundler)
    gems.each { |g| require g }
    return
  end
  # I'm use rvm, and keep all irb gems in @global gemset
  base_directory = $LOAD_PATH.grep(/@global.*?lib/).first
  if base_directory
    base_directory = base_directory.gsub(%r{@global/gems/.*$}, '@global/gems')
    Dir["#{base_directory}/*"].to_a.reverse.each do |gem_path|
      gem_name = File.basename(gem_path).gsub(/-(\d\.?)+$/, '')
      if gems.include?(gem_name)
        $LOAD_PATH << "#{gem_path}/lib"
        require gem_name
      end
    end
    nil
  end
end

# load libraries
require 'rubygems'
require 'ostruct'
require 'open-uri'
require 'etc'
require 'irb/completion'
require_without_bundler 'color', 'hirb', 'awesome_print'


#Itunes = OSA.app('iTunes')


# add the mocker!
class Object;
  def mock_methods(mock_methods);
    original = self;
    klass = Class.new(self) do; 
      instance_eval do; 
        mock_methods.each do |method, proc|; 
          define_method("mocked_#{method}", &proc);
          alias_method method, "mocked_#{method}";
        end;
      end;
    end;
      
    begin;
      Object.send(:remove_const, self.name.to_s);
      Object.const_set(self.name.intern, klass);
      yield;
    ensure;
      Object.send(:remove_const, self.name.to_s);
      Object.const_set(self.name.intern, original);
    end;
  end;
end

# load some tricks
class Module
  def awesome_attr_accessor(*args)
    args.each do |arg|      
      class_eval { 
        define_method arg, Proc.new { instance_variable_get "@#{arg}" }
        define_method "#{arg}=", Proc.new {|obj| instance_variable_set "@#{arg}", "awesome #{obj.to_s}" }
      }
    end
  end
end

class Struct
  def to_hash
    self.members.inject({}) { |hash, key| hash[key.to_sym] = self[key]; hash }
  end
end

class Hash
  def /(key)
    self[key]
  end
end

class Numeric
  def ordinal
    cardinal = self.to_i.abs
    if (10...20).include?(cardinal) then
      cardinal.to_s << 'th'
    else
      cardinal.to_s << %w{th st nd rd th th th th th th}[cardinal % 10]
    end
  end
end

module Etc
  def self.gwtinfohash(name)
    Etc.getpwnam(name).to_hash
  end
end

module UrlVerifier
  def self.verify(url,title)
    doc = Hpricot(open(url))
    urititle = (doc/:title).text
    title == urititle ? true : false
  end
end

# wrap text at a given column width
def wrap_text(txt, col = 80)
   txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n")
end

begin # ANSI codes
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
end

# Readline-enable prompts.
require 'irb/ext/save-history'
IRB.conf[:USE_READLINE] = true

HISTFILE = "~/.irb.history"
MAXHISTSIZE = 10000


   begin # Ben Bleything's history methods, as seen at http://dotfiles.org/~topfunky/.irbrc
    def history(how_many = 50)
      history_size = Readline::HISTORY.size

      # no lines, get out of here
      puts "No history" and return if history_size == 0

      start_index = 0

      # not enough lines, only show what we have
      if history_size <= how_many
        how_many  = history_size - 1
        end_index = how_many
      else
        end_index = history_size - 1 # -1 to adjust for array offset
        start_index = end_index - how_many 
      end

      start_index.upto(end_index) {|i| print_line i}
      nil
    end
    alias :h  :history

    # -2 because -1 is ourself
    def history_do(lines = (Readline::HISTORY.size - 2))
      irb_eval lines
      nil
    end 
    alias :h! :history_do

    def history_write(filename, lines)
      file = File.open(filename, 'w')

      get_lines(lines).each do |l|
        file << "#{l}\n"
      end

      file.close
    end
    alias :hw :history_write

    def get_line(line_number)
      Readline::HISTORY[line_number]
    end

    def get_lines(lines = [])
      return [get_line(lines)] if lines.is_a? Fixnum

      out = []

      lines = lines.to_a if lines.is_a? Range

      lines.each do |l|
        out << Readline::HISTORY[l]
      end

      return out
    end

    def print_line(line_number, show_line_numbers = true)
      print "[%04d] " % line_number if show_line_numbers
      puts get_line(line_number)
    end

    def irb_eval(lines)
      to_eval = get_lines(lines)

      eval to_eval.join("\n")

      to_eval.each {|l| Readline::HISTORY << l}
    end
  end


begin # Custom Prompt
  if ENV['RAILS_ENV']
    name = "rails #{ENV['RAILS_ENV']}"
    colors = ANSI_BACKBLUE + ANSI_YELLOW
  else
    name = "ruby #{RUBY_VERSION}"
    colors = ANSI_BACKPURPLE + ANSI_YELLOW
  end

  if IRB and IRB.conf[:PROMPT]
    IRB.conf[:PROMPT][:SD] = {
      :PROMPT_I => "#{colors}#{name}: %m #{ANSI_RESET}\n" \
                 + ">> ", # normal prompt
      :PROMPT_S => "%l> ",  # string continuation
      :PROMPT_C => " > ",   # code continuation
      :PROMPT_N => " > ",   # code continuation too?
      :RETURN   => "#{ANSI_BOLD}# => %s  #{ANSI_RESET}\n\n",  # return value
      :AUTO_INDENT => true
    }
    IRB.conf[:PROMPT_MODE] = :SD
  end
end

 begin # Utility methods
    def pm(obj, *options) # Print methods
      methods = obj.methods
      methods -= Object.methods unless options.include? :more
      filter = options.select {|opt| opt.kind_of? Regexp}.first
      methods = methods.select {|name| name =~ filter} if filter

      data = methods.sort.collect do |name|
        method = obj.method(name)
        if method.arity == 0
          args = "()"
        elsif method.arity > 0
          n = method.arity
          args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")})"
        elsif method.arity < 0
          n = -method.arity
          args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")}, ...)"
        end
        klass = $1 if method.inspect =~ /Method: (.*?)#/
        [name, args, klass]
      end
      max_name = data.collect {|item| item[0].size}.max
      max_args = data.collect {|item| item[1].size}.max
      data.each do |item| 
        print " #{ANSI_BOLD}#{item[0].rjust(max_name)}#{ANSI_RESET}"
        print "#{ANSI_GRAY}#{item[1].ljust(max_args)}#{ANSI_RESET}"
        print "   #{ANSI_LGRAY}#{item[2]}#{ANSI_RESET}\n"
      end
      data.size
    end
  end

system("ruby -v")
