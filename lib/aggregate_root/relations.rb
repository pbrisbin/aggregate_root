module AggregateRoot
  class Relations
    def initialize(aggregate, related_to)
      @aggregate = aggregate
      @relations = Array(related_to)
    end

    def to_attributes
      {}.tap do |ret|
        relations.each do |relation|
          if instance = related_instance(relation)
            ret[relation] = instance
          end
        end
      end
    end

    private

    attr_reader :aggregate, :relations

    def related_instance(relation)
      builder = aggregate.builders.detect { |b| b.name == relation }
      builder && builder.instance

      # TODO: if builder is found but instance is nil, this is because
      # the user has specified a related_to option before the component
      # she is relating to -- this is unsupported and per-haps should
      # rase a meaningful error.
    end

  end
end
