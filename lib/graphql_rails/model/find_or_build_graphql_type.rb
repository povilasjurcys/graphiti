# frozen_string_literal: true

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class FindOrBuildGraphqlType
      require 'graphql_rails/concerns/service'
      require 'graphql_rails/model/find_or_build_graphql_type_class'
      require 'graphql_rails/model/add_fields_to_graphql_type'

      include ::GraphqlRails::Service

      def initialize(name:, description:, attributes:, type_name:)
        @name = name
        @description = description
        @attributes = attributes
        @type_name = type_name
      end

      def call
        klass.tap { add_fields_to_graphql_type if new_class? }
      end

      private

      attr_reader :name, :description, :attributes, :type_name

      delegate :klass, :new_class?, to: :type_class_finder

      def type_class_finder
        @type_class_finder ||= FindOrBuildGraphqlTypeClass.new(
          name: name,
          type_name: type_name,
          description: description,
          attributes: attributes
        )
      end

      def add_fields_to_graphql_type
        AddFieldsToGraphqlType.call(klass: klass, attributes: attributes.values.select(&:scalar_type?))

        attributes.values.reject(&:scalar_type?).tap do |dynamic_attributes|
          find_or_build_dynamic_graphql_types(dynamic_attributes) do |name, description, attributes, type_name|
            self.class.call(
              name: name, description: description,
              attributes: attributes, type_name: type_name
            )
          end
          AddFieldsToGraphqlType.call(klass: klass, attributes: dynamic_attributes)
        end
      end

      def find_or_build_dynamic_graphql_types(dynamic_attributes)
        dynamic_attributes.each do |attribute|
          yield(
            attribute.graphql_model.graphql.name,
            attribute.graphql_model.graphql.description,
            attribute.graphql_model.graphql.attributes,
            attribute.graphql_model.graphql.type_name
          )
        end
      end
    end
  end
end
