module AggregateRoot
  class Attributes
    def initialize(name)
      @name = name
    end

    def from(prefixed_attributes)
      {}.tap do |ret|
        prefixed_attributes.each do |attr,value|
          if attr.to_s =~ /^#{name}_(.+)$/
            ret[$1.to_sym] = value
          end
        end
      end
    end

    private

    attr_reader :name

  end
end
