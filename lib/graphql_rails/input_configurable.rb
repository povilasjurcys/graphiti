# frozen_string_literal: true

module GraphqlRails
  # contains configuration options related with inputs
  module InputConfigurable
    def permit(*args)
      args.each do |arg|
        if arg.is_a? Hash
          arg.each { |attribute, type| permit_input(attribute, type: type) }
        else
          permit_input(arg)
        end
      end
      self
    end

    def permit_input(name, **input_options)
      field_name = name.to_s.remove(/!\Z/)

      attributes[field_name] = build_input_attribute(name.to_s, **input_options)
      self
    end

    def paginated(pagination_options = {})
      pagination_options = {} if pagination_options == true
      pagination_options = nil if pagination_options == false

      @pagination_options = pagination_options
      permit(:before, :after, first: :int, last: :int)
    end

    def paginated?
      !pagination_options.nil?
    end

    def pagination_options
      @pagination_options
    end

    def input_attribute_options
      @input_attribute_options || {}
    end

    def build_input_attribute(name, options: {}, **other_options)
      Attributes::InputAttribute.new(
        name.to_s,
        options: input_attribute_options.merge(options),
        **other_options
      )
    end
  end
end
