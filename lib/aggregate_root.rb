module AggregateRoot
  autoload :Attributes, 'aggregate_root/attributes'
  autoload :Builder,    'aggregate_root/builder'
  autoload :Model,      'aggregate_root/model'
  autoload :Relations,  'aggregate_root/relations'

  def self.included(base)
    base.extend(ClassMethods)
  end

  def initialize(attributes = {})
    attributes.each do |attribute, value|
      send(:"#{attribute}=", value)
    end

    builders.each do |builder|
      builder.build(attributes)
    end
  end

  private

  def builders
    self.class.builders
  end

  module ClassMethods
    def aggregates(name, options = {})
      model = options.delete(:model_class) || Model.for(name)
      model.attributes.each do |attr|
        attr_accessor :"#{name}_#{attr}"
      end

      builders << Builder.new(self, name, model, options)
    end

    def builders
      @builders ||= []
    end
  end
end
