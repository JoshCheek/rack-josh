require 'rubygems/commands/which_command'

module Rack
  module Josh
    class DevReload
      class FakeUI
        attr_reader :output
        def say(output)
          @output = output
        end

        def alert_error(message, *)
          raise message
        end
      end

      def initialize(app, to_reload)
        @app       = app
        @to_reload = to_reload
      end

      def call(env)
        reload!
        @app.call env
      end

      def reload!
        @to_reload.each do |constants, require_paths|
          Array(constants).each do |constant|
            *path_segments, name = constant.split('::')
            path = ['Object', *path_segments].reject(&:empty?).join('::')
            namespace = Object.const_get(path)
            namespace.__send__ :remove_const, name
          end

          Array(require_paths).map { |require_path|
            w = Gem::Commands::WhichCommand.new                                                 # => #<Gem::Commands::WhichCommand:0x007fcc288ba3c0 @command="which", @summary="Find the location of a library file you can require", @program_name="gem which", @defaults={:search_gems_first=>false, :show_all=>false}, @options={:search_gems_first=>false, :show_all=>false}, @option_groups={:options=>[[["-a", "--[no-]all", "show all matching files"], #<Proc:0x007fcc288b99e8@/Users/josh/.rubies/ru...
            w.handle_options([require_path])                                                        # => ["parser"]
            fake_ui = FakeUI.new
            w.ui = fake_ui
            w.execute
            w.ui.output.first
          }.each { |full_path| $LOADED_FEATURES.delete full_path }
           .each { |full_path| require full_path }
        end
      end
    end
  end
end
