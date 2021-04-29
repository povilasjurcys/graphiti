# frozen_string_literal: true

module GraphqlRails
  module Model
    # Initializes class to define graphql type and fields.
    class FindOrBuildGraphqlTypeClass
      require 'graphql_rails/concerns/service'

      include ::GraphqlRails::Service

      def initialize(name:, type_name:, description: nil, attributes: [])
        @name = name
        @type_name = type_name
        @description = description
        @new_class = false
        @attributes = attributes
      end

      def klass
        @klass ||= Object.const_defined?(type_name) && Object.const_get(type_name) || build_graphql_type_klass
      end

      def new_class?
        new_class
      end

      private

      attr_accessor :new_class
      attr_reader :name, :type_name, :description, :attributes

      def build_graphql_type_klass
        graphql_type_name = name
        graphql_type_description = description

        graphql_type_klass = Class.new(GraphQL::Schema::Object) do
          graphql_name(graphql_type_name)
          description(graphql_type_description)
        end

        self.new_class = true

        if attributes.any?
          Object.const_set(type_name, graphql_type_klass)
        else
          graphql_type_klass
        end
      end
    end
  end
end
