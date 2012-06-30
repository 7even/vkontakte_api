module VkontakteApi
  module Utils
    class << self
      def flatten_arguments(arguments)
        arguments.inject({}) do |flat_args, (arg_name, arg_value)|
          flat_args[arg_name] = flatten_argument(arg_value)
          flat_args
        end
      end
      
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
