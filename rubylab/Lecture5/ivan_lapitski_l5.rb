#!/usr/bin/env ruby
require 'yaml'
class Command
  ALL_COMMANDS = []
  @config_yaml = YAML.load_file('config.yaml')

  def self.my_error_method (debug)
    debug ? NoMethodError : StandardError
  end

  def self.command_by_name
    print ' > '
    begin
      caught_command = $stdin.gets.chomp.downcase.split
      caught_class = ALL_COMMANDS.detect { |c| c.name == caught_command[0] }
      @@caught_arguments = caught_command[1]
    rescue NoMethodError, Interrupt => e
      File.open(@config_yaml[:error_log], 'a') {|f| f.write("#{Time
          .now} - Execution stopped \n")}
      puts "\nbye..."
      exit 0
    end

    caught_command.empty? ? command_by_name :

    if caught_class.nil?
      print " > Answer:\n > Nil class caught..\n\
 > Command unknown, available commands:\n"

      ALL_COMMANDS.each { |cmd| puts "#{ cmd.name }" }
      # command_by_name
    else
      File.open(@config_yaml[:output_log], 'a') {|f| f
          .write(" > #{caught_class} class caught..\n")}
      print " > #{caught_class} class caught.. \n > Answer:\n"
    end

    if @@caught_arguments == '--help'
      puts caught_class.description
      # command_by_name

    elsif @@caught_arguments == '--all' && caught_class == HelpCommand
      say
      Command::ALL_COMMANDS.each do |cmd|
        puts "#{cmd.name} <<--- #{cmd.description}"
      end
      # command_by_name

    else
      begin
        caught_class.run
      # rescue NoMethodError => e
      rescue my_error_method(@config_yaml[:debug]) => e
        File.open('err.log', 'a') {|f| f.write "#{Time
        .now} - wrong command: #{caught_command[0]} - #{e.class}: #{e.message} \n"}
        print " > wrong command: #{caught_command[0]}\n"
      end
      # command_by_name
    end
  end

  def self.say(*args)
    print "Time now --> #{Time.now}\n"
    print "Program name --> #{$0}\n"
    if args != []
      puts " > Hello from Command.say method:)\n > #{args}\n"
    else
      puts " > Hello from Command.say method:)\n"
    end
  end
end

class HelpCommand < Command
  class << self
    def name
      'help'
    end

    def description
      'type \'command_name --help\' to see description'
    end

    def run
      say ('List of commands')
      Command::ALL_COMMANDS.each { |cmd| puts "#{cmd.name}"}
      puts " > for full help type 'help --all'"
    end
  end
end

class UpTimeCommand < Command
  class << self
    def name
      'uptime'
    end

    def description
      'will give you OS uptime'
    end

    def run
      uptime_file = '/proc/uptime'
      time = IO.read( uptime_file ).split[0].to_i
      hours = (IO.read( uptime_file ).split[0].to_i) / 3600
      minutes = (time - hours * 3600) / 60
      seconds = time - hours * 3600 - minutes * 60
      puts "#{hours}h #{minutes}min #{seconds}sec"
    rescue Errno::ENOENT => e
      File.open(@config_yaml[:error_log], 'a') {|f| f.write "#{Time
      .now} - #{e.message} \n"}
      puts e.message
    end
  end
end

class DateCommand < Command
  class << self
    def name
      'date'
    end

    def description
      'prints today\'s date'
    end

    def run
      puts Time.now
    end
  end
end

class EchoCommand < Command
  class<< self
    def name
      'echo'
    end

    def description
      'echo you args'
    end

    def run
      if @@caught_arguments
        puts "#{ @@caught_arguments }"
      else
        print " > print message to echo:\n"
        words = gets.chomp.split
        puts " > #{words[0]}"
      end
    end
  end
end

class PingCommand < Command
  class << self
    def name
      'ping'
    end

    def description
      'to ping everything'
    end

    def run( ping_count: 4)
      if @@caught_arguments
        puts " > please wait ...\n\n"
        puts `ping -q -c #{ ping_count } #{ @@caught_arguments }`
        if $?.exitstatus == 0
          puts "\n > #{ @@caught_arguments } is up!\n\n"
        end
      else
        puts ' > Please, enter host name to ping'
        servername = gets.chomp.split
        puts " > please wait...\n\n"
        puts `ping -q -c #{ ping_count } #{ servername[0]}`
        if $?.exitstatus == 0
          puts "\n > #{servername[0]} is up!\n\n"
        end
      end
    end
  end
end

puts "-Hello, #{ ENV['USER']}! Welcome to ruby console.
-Enter you command, or 'help' to get help
-To exit Ctrl+D or Ctrl+C"
Command::ALL_COMMANDS.push(HelpCommand, UpTimeCommand, DateCommand,
                           EchoCommand, PingCommand)
while true
  Command.command_by_name
end
