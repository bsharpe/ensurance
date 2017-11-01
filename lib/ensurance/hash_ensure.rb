# NOTE: https://blog.daveallie.com/clean-monkey-patching/

require 'active_support/core_ext/hash'
require 'json'

module Ensurance
  module HashEnsure
    def self.prepended(base)
      base.singleton_class.prepend(ClassMethods)
    end

    module ClassMethods
      def ensure(thing)
        case thing.class.name
        when "Hash","HashWithIndifferentAccess"
          thing
        when "String"
          JSON.parse(thing)
        when "NilClass"
          nil
        else
          if thing.respond_to?(:to_h)
            begin
              thing.to_h
            rescue TypeError
              raise ArgumentError.new("Unhandled Type for Hash to ensure: #{thing.class}")
            end
          else
            raise ArgumentError.new("Unhandled Type for Hash to ensure: #{thing.class}")
          end
        end
      end
    end
  end
end

::Hash.prepend( Ensurance::HashEnsure )