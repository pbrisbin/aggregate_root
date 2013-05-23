module AggregateRoot
  class Attributes
    def initialize(name, whitelist)
      @name = name
      @whitelist = whitelist
    end

    def from(prefixed_attrs)
      {}.tap do |ret|
        prefixed_attrs.each do |prefixed_attr, value|
          if (attr = unprefix(prefixed_attr)) && include?(attr)
            ret[attr] = value
          end
        end
      end
    end

    private

    attr_reader :name, :whitelist

    def unprefix(attr)
      $1.to_sym if attr.to_s =~ /^#{name}_(.+)$/
    end

    def include?(attr)
      whitelist.nil? ||
        whitelist.empty? ||
        whitelist.include?(attr)
    end

  end
end
