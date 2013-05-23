module AggregateRoot
  class Builder

    attr_reader :name, :model, :instance

    def initialize(aggregate, name, options)
      @name = name

      @attributes = Attributes.new(name)
      @relations  = Relations.new(aggregate, options[:related_to])
      @defaults   = options.fetch(:defaults, {})
      @model      = options.fetch(:model_class) { Model.for(name) }
    end

    def build(prefixed_attributes)
      @instance = model.new(
        defaults.merge(
          attributes.from(prefixed_attributes).merge(
            relations.to_attributes
      )))
    end

    private

    attr_reader :attributes, :relations, :defaults

  end
end
