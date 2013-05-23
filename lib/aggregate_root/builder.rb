module AggregateRoot
  class Builder

    attr_reader :name, :instance

    def initialize(aggregate, name, options)
      @name = name

      @attributes = Attributes.new(name)
      @relations  = Relations.new(aggregate, options[:related_to])
      @condition  = options[:if]
      @defaults   = options.fetch(:defaults, {})
      @model      = options.fetch(:model_class) { Model.for(name) }
    end

    def build(prefixed_attributes)
      model_attrs = defaults.merge(attributes.from(prefixed_attributes))

      if instantiate?(model_attrs)
        @instance = model.new(model_attrs.merge(relations.to_attributes))
      end
    end

    private

    attr_reader :attributes, :relations, :condition, :defaults, :model

    def instantiate?(model_attrs)
      condition.nil? || condition.call(model_attrs)
    end
  end
end
