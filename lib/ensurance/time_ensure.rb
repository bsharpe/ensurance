require 'active_support/core_ext/time'

# NOTE: https://blog.daveallie.com/clean-monkey-patching/

module Ensurance
  module TimeEnsure
    def self.prepended(base)
      base.singleton_class.prepend(ClassMethods)
    end

    module ClassMethods
      def ensure(thing)
        case thing.class.name
        when "NilClass"
          thing
        when "Time"
          thing
        when "Date"
          thing.beginning_of_day
        when "Integer", "Float"
          ::Time.at(thing)
        when "String"
          if thing.to_i.to_s == thing
            ::Time.at(thing.to_i)
          elsif thing.to_f.to_s == thing
            ::Time.at(thing.to_f)
          else
            ::Time.parse(thing)
          end
        else
          if thing.respond_to?(:to_time)
            thing.to_time
          else
            raise ArgumentError.new("Unhandled Type for Time to ensure: #{thing.class}")
          end
        end
      end
    end

  end
end

::Time.prepend(Ensurance::TimeEnsure)
