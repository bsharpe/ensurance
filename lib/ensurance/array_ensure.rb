# NOTE: https://blog.daveallie.com/clean-monkey-patching/

require 'active_support/core_ext/array'

module Ensurance
  module ArrayEnsure
    def self.prepended(base)
      base.singleton_class.prepend(ClassMethods)
    end

    module ClassMethods
      def ensure(thing)
        case thing.class.name
        when 'NilClass'
          nil
        when 'Hash'
          thing.to_a
        when 'String'
          begin
            [JSON.parse(thing)].flatten
          rescue JSON::ParserError
            thing.split(',')
          end
        else
          Array(thing)
        end
      end

      def ensure!(thing)
        result = self.ensure(thing)
        raise ArgumentError, "Cannot Array.ensure(#{thing || 'nil'})" unless result
        result
      end
    end
  end
end

::Array.prepend(Ensurance::ArrayEnsure)
