module Ensurance
  module ActiveRecord
    extend ActiveSupport::Concern

    ## ---
    # Allow you to ensure you have the class you expect... it's similar to
    # result = value.is_a?(Person) ? value : Person.find(value)
    #
    # You can add fields to "ensure_by" (:id is included always)
    # e.g.
    #  if you add `ensure_by :token` to the User class
    #   User.ensure(<UserObject>) works
    #   User.ensure(:user_id) works
    #   User.ensure(:token) works
    #
    #  .ensure() returns nil if the record is not found
    #  .ensure!() throws an exception if the record is not found

    class_methods do
      def ensure_by(*args)
        @_ensure_by ||= [:id]
        @_ensure_by += [args].flatten
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

        @_ensure_by ||= [:id]
        @_ensure_by.each do |ensure_field|
          value = thing.try(:fetch, ensure_field.to_sym, nil) || thing.try(:fetch, ensure_field.to_s, nil) || thing
          found = self.find_by(ensure_field => value)
          break if found.is_a?(self)
        end

        found
      end

      def ensure!(thing = nil)
        result = self.ensure(thing)
        raise ActiveRecord::RecordNotFound unless result
        result
      end

    end
  end
end
