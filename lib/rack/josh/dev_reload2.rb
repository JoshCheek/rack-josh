module Rack
  module Josh
    class DevReload2
      def initialize(app, to_require)
        @app                        = app
        @to_require                 = to_require
        @prev_added_constants       = []
        @prev_added_loaded_features = []
      end

      def call(env)
        # remove prev additions
        @prev_added_loaded_features.each do |loaded_feature|
          $LOADED_FEATURES.delete loaded_feature
        end
        remove_constants @prev_added_constants

        # record the world
        pre_load_path = $LOADED_FEATURES.dup
        pre_constants = all_constants

        # require the files
        @to_require.each { |filename| require filename }

        # app does its thing
        result = @app.call env

        # record the stuffs to remove next time
        @prev_added_loaded_features = $LOADED_FEATURES - pre_load_path
        @prev_added_constants       = all_constants - pre_constants
        result
      end

      def all_constants
        AllConstants.call
      end

      def remove_constants(constants)
        constants.each do |constant|
          *path_segments, name = constant.split('::')
          path = path_segments.reject(&:empty?).join('::')
          namespace = ::Object.const_get(path)
          begin
            namespace.__send__ :remove_const, name
          rescue NameError
            # again, fucking Module overlaps Object
          end
        end
      end

      module AllConstants
        def self.call
          queue        = ['::Object']
          constants    = []
          dont_recurse = []

          until queue.empty?
            base_path = queue.shift
            base      = ::Object.const_get base_path
            constants << base_path
            next if dont_recurse.include? base
            dont_recurse << base
            base.constants
                .map  { |name|
                  next nil if base.autoload? name
                  begin
                    path = "#{base_path}::#{name}"
                    [path, ::Object.const_get(path)]
                  rescue ::NameError # fkn Module, y'all
                    nil
                  end
                }
                .compact
                .each { |constant_name, constant|
                  if constant.kind_of?(::Class) || constant.kind_of?(::Module)
                    queue << constant_name
                  else
                    constants << constant_name
                  end
                }
          end
          constants
        end
      end
    end
  end
end
