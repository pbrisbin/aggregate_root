module AggregateRoot
  autoload :Attributes, 'aggregate_root/attributes'
  autoload :Builder,    'aggregate_root/builder'
  autoload :Model,      'aggregate_root/model'
  autoload :Relations,  'aggregate_root/relations'

  def self.included(base)
    base.extend(ClassMethods)
  end

  def initialize(attributes = {})
    builders.each do |builder|
      builder.build(attributes)
    end
  end

  private

  def builders
    self.class.builders
  end

  module ClassMethods
    def aggregates(object_name, options = {})
      builders << Builder.new(self, object_name, options)
    end

    def builders
      @builders ||= []
    end
  end
end
