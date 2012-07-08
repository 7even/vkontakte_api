module VkontakteApi
  # An utility module able to flatten arguments (join arrays into comma-separated strings).
  module Utils
    class << self
      # A multiple version of `#flatten_argument`. It transforms a hash flattening each value and keeping the keys untouched.
      # @param [Hash] arguments The arguments to flatten.
      # @return [Hash] Flattened arguments.
      def flatten_arguments(arguments)
        arguments.inject({}) do |flat_args, (arg_name, arg_value)|
          flat_args[arg_name] = flatten_argument(arg_value)
          flat_args
        end
      end
      
      # If an argument is an array, it will be joined with a comma; otherwise it'll be returned untouched.
      # @param [Object] argument The argument to flatten.
      def flatten_argument(argument)
        if argument.respond_to?(:join)
          # if argument is an array, we join it with a comma
          argument.join(',')
        else
          # otherwise leave it untouched
          argument
        end
      end
    end
  end
end
