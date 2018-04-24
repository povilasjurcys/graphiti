# frozen_string_literal: true

module Graphiti
  # GrapqhQL error that is raised when invalid data is given
  class ValidationError < ExecutionError
    attr_reader :short_message, :field

    def initialize(short_message, field)
      super([field.presence, short_message].compact.join(' '))
      @short_message = short_message
      @field = field
    end

    def type
      'validation_error'
    end

    def http_status_code
      422
    end

    def to_h
      super.merge('field' => field, 'short_message' => short_message)
    end
  end
end
