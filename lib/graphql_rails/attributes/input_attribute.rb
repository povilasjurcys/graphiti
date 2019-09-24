# frozen_string_literal: true

module GraphqlRails
  module Attributes
    # contains info about single graphql input attribute
    class InputAttribute
      require_relative './input_type_parser'
      include Attributable

      attr_reader :description

      # rubocop:disable Metrics/ParameterLists
      def initialize(name, type = nil, description: nil, subtype: nil, required: nil, options: {})
        @initial_name = name
        @initial_type = type
        @description = description
        @options = options
        @subtype = subtype
        @required = required
      end
      # rubocop:enable Metrics/ParameterLists

      def input_argument_args
        type = raw_input_type || input_type_parser.nullable_type || nullable_type

        [field_name, type, { required: required?, description: description, camelize: false }]
      end

      def graphql_input_type
        raw_input_type || input_type_parser.graphql_type || graphql_field_type
      end

      def graphql_field_type
        @graphql_field_type ||= \
          if required?
            nullable_type.to_non_null_type
          else
            nullable_type
          end
      end

      private

      attr_reader :initial_name, :initial_type, :options, :subtype

      def nullable_type
        type = type_parser.graphql_type
        type.non_null? ? type.of_type : type
      end

      def input_type_parser
        @input_type_parser ||= InputTypeParser.new(initial_type, subtype: subtype)
      end

      def raw_input_type
        return initial_type if initial_type.is_a?(GraphQL::InputObjectType)
        return initial_type.graphql_input_type if initial_type.is_a?(Model::Input)
      end
    end
  end
end
