module AggregateRoot
  class Builder

    attr_reader :name, :model, :instance

    def initialize(aggregate, name, options)
      @name = name
      @attributes = Attributes.new(name)
      @relations = Relations.new(aggregate, options.delete(:related_to))
      @model = options.delete(:model_class) || Model.for(name)
    end

    def build(prefixed_attributes)
      @instance = model.new(
        attributes.from(prefixed_attributes).merge(relations.to_attributes)
      )
    end

    private

    attr_reader :attributes, :relations

  end
end
