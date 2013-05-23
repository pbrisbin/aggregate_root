module AggregateRoot
  class Model
    def initialize(name)
      @name = name
    end

    def instantiate(attributes)
      model_class.new(attributes)
    end

    private

    attr_reader :name

    def model_class
      Object.const_get(model_name)
    rescue NameError
      raise # TODO: raise our own exceptions classes
    end

    def model_name
      name.to_s.gsub(/(?:^|_)([a-z\d]*)/) { $1.capitalize }
    end
  end
end
