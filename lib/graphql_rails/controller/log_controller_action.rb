# frozen_string_literal: true

require 'graphql_rails/errors/execution_error'

module GraphqlRails
  class Controller
    # logs controller start and end times
    class LogControllerAction
      START_PROCESSING_KEY = 'start_processing.graphql_action_controller'
      PROCESS_ACTION_KEY = 'process_action.graphql_action_controller'

      def self.call(**kwargs, &block)
        new(**kwargs).call(&block)
      end

      def initialize(controller_name:, action_name:, params:, graphql_request:)
        @controller_name = controller_name
        @action_name = action_name
        @params = params
        @graphql_request = graphql_request
      end

      def call
        ActiveSupport::Notifications.instrument(START_PROCESSING_KEY, default_payload)
        ActiveSupport::Notifications.instrument(PROCESS_ACTION_KEY, default_payload) do |payload|
          yield.tap do
            payload[:status] = status
          end
        end
      end

      private

      attr_reader :controller_name, :action_name, :params, :graphql_request

      def default_payload
        {
          controller: controller_name,
          action: action_name,
          params: filtered_params
        }
      end

      def status
        graphql_request.errors.present? ? 500 : 200
      end

      def filtered_params
        @filtered_params ||=
          if filter_parameters.empty?
            params
          else
            filter_options = Rails.configuration.filter_parameters
            parametter_filter = ActionDispatch::Http::ParameterFilter.new(filter_options)
            parametter_filter.filter(params)
          end
      end

      def filter_parameters
        return [] if !defined?(Rails) || Rails.application.nil?

        Rails.application.config.filter_parameters || []
      end
    end
  end
end
