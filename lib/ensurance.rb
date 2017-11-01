require "ensurance/version"
require 'active_support'

require 'ensurance/date_ensure'
require 'ensurance/time_ensure'
require 'ensurance/hash_ensure'

module Ensurance
  extend ActiveSupport::Concern

  class_methods do
    def ensure_by(*args)
      @_additional_ensure_by = args
      @_ensure_by = nil
    end

    def ensure(thing = nil)
      return nil unless thing.present?

      if thing.is_a?(self)
        return thing
      elsif thing.is_a?(GlobalID)
        return GlobalID::Locator.locate(thing)
      elsif thing.is_a?(Hash) && thing['_aj_globalid'] && (found = GlobalID::Locator.locate(thing['_aj_globalid']))
        return found
      elsif thing.is_a?(String) && found = GlobalID::Locator.locate(thing)
        return found
      end
      found = nil

      @_ensure_by ||= [self.primary_key, @_additional_ensure_by].flatten.compact.uniq
      @_ensure_by.each do |ensure_field|
        value = thing.try(:fetch, ensure_field.to_sym, nil) || thing.try(:fetch, ensure_field.to_s, nil) || thing
        found = self.find_by(ensure_field => value)
        break if found.is_a?(self)
      end

      found
    end

    def ensure!(thing = nil)
      result = self.ensure(thing)
      raise ::ActiveRecord::RecordNotFound unless result
      result
    end

  end
end
