# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/attributes/attributable'

module GraphqlRails
  module Attributes
    # contains info about single graphql attribute
    class Attribute
      include Attributable

      def initialize(name, type = nil, description: nil, property: name)
        @initial_type = type
        @initial_name = name
        @description = description
        @property = property.to_s
      end

      def type(new_type = nil)
        return @initial_type if new_type.nil?

        @initial_type = new_type
        self
      end

      def description(new_description = nil)
        return @description if new_description.nil?

        @description = new_description
        self
      end

      def property(new_property = nil)
        return @property if new_property.nil?

        @property = new_property.to_s
        self
      end

      def field_args
        [
          field_name,
          graphql_field_type,
          {
            property: property.to_sym,
            description: description
          }
        ]
      end

      protected

      attr_reader :initial_type, :initial_name
    end
  end
end
