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
        when 'NilClass', 'Time'
          thing
        when "Integer"
          if thing < 10 ** 10
            ::Time.zone.at(thing)
          else # assume millis
            ::Time.zone.at(thing / 1000.0)
          end
        when "Float"
          ::Time.zone.at(thing)
        when 'String'
          if thing.match?(/\d{2}:\d{2}/) || thing.match?(/^\d{4}-\d{2}-\d{2}$/)
            ::Time.parse(thing)
          elsif thing.match?(/^\d+\.\d+$/)
            self.ensure(thing.to_f)
          elsif thing.match?(/^\d+$/)
            self.ensure(thing.to_i)
          elsif thing.blank?
            nil
          else
            raise ArgumentError, "Cannot convert #{thing.class}/\"#{thing}\" to Time"
          end
        else
          if thing.respond_to?(:to_time)
            thing.to_time
          else
            raise ArgumentError, "Unhandled Type for Time to ensure: #{thing.class}"
          end
        end
      end

      def ensure!(thing)
        result = self.ensure(thing)
        raise ArgumentError, "Cannot Time.ensure(#{thing})" unless result
        result
      end
    end
  end
end

::Time.prepend(Ensurance::TimeEnsure)
