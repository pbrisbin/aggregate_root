module AggregateRoot
  autoload :Attributes, 'aggregate_root/attributes'
  autoload :Builder,    'aggregate_root/builder'
  autoload :Model,      'aggregate_root/model'
  autoload :Relations,  'aggregate_root/relations'

  def self.included(base)
    base.extend(ClassMethods)
  end

  def initialize(attributes = {})
    assign_attributes(attributes)

    builders.each do |builder|
      builder.build(attributes)
    end
  end

  private

  def builders
    self.class.builders
  end

  def assign_attributes(attributes)
    attributes.each do |attribute, value|
      writer = :"#{attribute}="

      if respond_to?(writer)
        send(:"#{attribute}=", value)
      end
    end
  end

  module ClassMethods
    def aggregates(name, options = {})
      model = options.delete(:model_class) || Model.for(name)
      accessors = options.fetch(:only) { model.attributes }
      accessors.each do |accessor|
        attr_accessor :"#{name}_#{accessor}"
      end

      builders << Builder.new(self, name, model, options)
    end

    def builders
      @builders ||= []
    end
  end
end
