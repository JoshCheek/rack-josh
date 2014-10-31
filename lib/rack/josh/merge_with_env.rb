module Rack
  module Josh

    # For injecting values (e.g. a database connection you might want to mock out or control with more detail)
    class MergeWithEnv
      def initialize(app, hash_to_add_to_env, options={}, &dynamic_add_to_env)
        @default            = options.fetch :default, false
        @app                = app
        @hash_to_add_to_env = hash_to_add_to_env
        @dynamic_add_to_env = dynamic_add_to_env
      end

      def call(env)
        to_merge = @hash_to_add_to_env
        to_merge = to_merge.merge @dynamic_add_to_env.call(env) if @dynamic_add_to_env
        env      = @default ? to_merge.merge(env) : env.merge(to_merge)
        @app.call(env)
      end
    end
  end
end
