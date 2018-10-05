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
        when 'NilClass'
          nil
        when 'Hash', 'HashWithIndifferentAccess'
          thing
        when 'String'
          JSON.parse(thing)
        when 'ActionController::UnfilteredParameters', 'ActionController::Parameters'
          thing.permit!.to_h
        else
          if thing.respond_to?(:to_h)
            begin
              thing.to_h
            rescue TypeError
              raise ArgumentError, "Unhandled Type for Hash to ensure: #{thing.class}"
            end
          else
            raise ArgumentError, "Unhandled Type for Hash to ensure: #{thing.class}"
          end
        end
      end

      def ensure!(thing)
        result = self.ensure(thing)
        raise ArgumentError, "Cannot Hash.ensure(#{thing})" unless result
        result
      end
    end
  end
end

::Hash.prepend(Ensurance::HashEnsure)
