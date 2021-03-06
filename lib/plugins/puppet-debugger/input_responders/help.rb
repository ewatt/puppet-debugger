require 'puppet-debugger/input_responder_plugin'
module PuppetDebugger
  module InputResponders
    class Help < InputResponderPlugin
      COMMAND_WORDS = %w(help)
      SUMMARY = 'Show the help screen with version information.'
      COMMAND_GROUP = :help

      def run(args = [])
        PuppetDebugger::Cli.print_repl_desc
      end
    end
  end
end
