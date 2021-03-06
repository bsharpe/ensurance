require 'active_support/core_ext/time'
require 'active_support/time_with_zone'

# NOTE: https://blog.daveallie.com/clean-monkey-patching/

module Ensurance
  module TimeEnsure
    def self.prepended(base)
      base.singleton_class.prepend(ClassMethods)
    end

    module ClassMethods
      def ensure(thing)
        ::Time.zone ||= "UTC"

        case thing.class.name
        when 'NilClass'
          thing
        when 'Time'
          thing
        when 'Date'
          thing.beginning_of_day
        when 'Integer', 'Float'
          ::Time.zone.at(thing)
        when 'String'
          if thing.to_i.to_s == thing
            ::Time.zone.at(thing.to_i)
          elsif thing.to_f.to_s == thing
            ::Time.zone.at(thing.to_f)
          else
            ::Time.zone.parse(thing)
          end
        else
          if thing.respond_to?(:to_time)
            thing.to_time
          else
            raise ArgumentError, "Unhandled Type for Time to ensure: #{thing.class}"
          end
        end
      end

      def ensure!(_thing)
        def ensure!(thing)
          result = self.ensure(thing)
          raise ArgumentError, "Cannot Time.ensure(#{thing})" unless result
          result
        end
      end
    end
  end
end

::Time.prepend(Ensurance::TimeEnsure)
