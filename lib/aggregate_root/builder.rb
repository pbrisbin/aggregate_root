module AggregateRoot
  class Builder

    attr_reader :name, :model, :instance

    def initialize(aggregate, name, options)
      @name = name
      @model = Model.new(name)
      @attributes = Attributes.new(name)
      @relations = Relations.new(aggregate, options.delete(:related_to))
    end

    def build(prefixed_attributes)
      @instance = model.instantiate(
        attributes.from(prefixed_attributes).merge(relations.to_attributes)
      )
    end

    private

    attr_reader :attributes, :relations

  end
end
