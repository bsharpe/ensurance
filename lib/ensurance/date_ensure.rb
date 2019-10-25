# NOTE: https://blog.daveallie.com/clean-monkey-patching/

require 'active_support/core_ext/date'
require 'active_support/core_ext/time'

module Ensurance
  module DateEnsure
    def self.prepended(base)
      base.singleton_class.prepend(ClassMethods)
    end

    module ClassMethods
      DATE_ENSURE_FORMATS = %w[%m/%d/%Y %Y/%m/%d].freeze
      def ensure(thing)
        Time.zone ||= 'UTC'

        case thing.class.name
        when 'NilClass'
          nil
        when 'Integer', 'Float'
          Time.ensure(thing).to_date
        when 'Date'
          thing
        when 'String'
          return nil if thing.blank?
          if thing.to_i.to_s == thing
            ::Time.zone.at(thing.to_i).to_date
          elsif thing.to_f.to_s == thing
            ::Time.zone.at(thing.to_f).to_date
          elsif thing.index('/')
            # Assume US Date format
            result = nil
            DATE_ENSURE_FORMATS.each do |f|
              begin
                result = Date.strptime(thing, f)
                break
              rescue ArgumentError
              end
            end
            raise ArgumentError, "Bad Date: #{thing}".yellow unless result
            result
          else
            ::Time.zone.parse(thing).to_date
          end
        else
          if thing.respond_to?(:to_date)
            thing.to_date
          else
            raise ArgumentError, "Unknown Type for Date to ensure: #{thing.class.name}"
          end
        end
      end

      def ensure!(thing)
        result = self.ensure(thing)
        raise ArgumentError, "Cannot Date.ensure(#{thing})" unless result
        result
      end
    end
  end
end

::Date.prepend(Ensurance::DateEnsure)
