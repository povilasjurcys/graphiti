# frozen_string_literal: true

module GraphqlRails
  class Router
    # builds GraphQL::Schema based on previously defined grahiti data
    class SchemaBuilder
      require_relative './plain_cursor_encoder'

      attr_reader :queries, :mutations, :raw_actions

      def initialize(queries:, mutations:, raw_actions:)
        @queries = queries
        @mutations = mutations
        @raw_actions = raw_actions
      end

      def call
        query_type = build_type('Query', queries)
        mutation_type = build_type('Mutation', mutations)
        raw = raw_actions

        Class.new(GraphQL::Schema) do
          cursor_encoder(Router::PlainCursorEncoder)
          raw.each { |action| send(action[:name], *action[:args], &action[:block]) }

          query(query_type)
          mutation(mutation_type)
        end
      end

      private

      def build_type(type_name, routes)
        Class.new(GraphQL::Schema::Object) do
          graphql_name(type_name)

          routes.each do |route|
            field(*route.field_args)
          end

          def self.inspect
            "#{GraphQL::Schema::Object}(#{graphql_name})"
          end
        end
      end
    end
  end
end
