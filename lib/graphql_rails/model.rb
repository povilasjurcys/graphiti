# frozen_string_literal: true

require 'graphql_rails/model/configuration'

module GraphqlRails
  # this module allows to convert any ruby class in to graphql type object
  #
  # usage:
  # class YourModel
  #   include GraphqlRails::Model
  #
  #   graphql do
  #     attribute :id
  #     attribute :title
  #   end
  # end
  #
  # YourModel.new.graphql_type # => type with [:id, :title] attributes
  module Model
    def self.included(base)
      base.extend(ClassMethods)
    end

    # static methods for GraphqlRails::Model
    module ClassMethods
      def inherited(subclass)
        subclass.instance_variable_set(:@graphql, graphql.dup)
        subclass.graphql.instance_variable_set(:@model_class, self)
        subclass.graphql.instance_variable_set(:@graphql_type, nil)
      end

      def graphql
        @graphql ||= Model::Configuration.new(self)
        yield(@graphql) if block_given?
        @graphql
      end
    end
  end
end
