require 'spec_helper'

describe AggregateRoot do
  class ComponentOne; end
  class ComponentTwo; end
  class ComponentThree; end

  context "simple models" do
    class Simple
      include AggregateRoot

      aggregates :component_one
      aggregates :component_two
    end

    it "initializes its components" do
      ComponentOne.should_receive(:new).
        with(title: "Title", description: "Description")
      ComponentTwo.should_receive(:new).
        with(name: "Name", description: "Description Two")

      Simple.new(
        component_one_title: "Title",
        component_one_description: "Description",
        component_two_name: "Name",
        component_two_description: "Description Two"
      )
    end
  end

  context "one related model" do
    class Dependant
      include AggregateRoot

      aggregates :component_one
      aggregates :component_two, related_to: :component_one
    end

    it "initializes the second component with a reference to the first" do
      component_one = double("Component one")
      ComponentOne.should_receive(:new).and_return(component_one)
      ComponentTwo.should_receive(:new).
        with(hash_including(component_one: component_one))

      Dependant.new
    end
  end

  context "one model related to two others" do
    class TwoDependant
      include AggregateRoot

      aggregates :component_one
      aggregates :component_two
      aggregates :component_three,
        related_to: [:component_one, :component_two]
    end

    it "initializes the second component with a reference to the first" do
      component_one = double("Component one")
      component_two = double("Component two")
      ComponentOne.should_receive(:new).and_return(component_one)
      ComponentTwo.should_receive(:new).and_return(component_two)
      ComponentThree.should_receive(:new).
        with(hash_including(
          component_one: component_one,
          component_two: component_two
        ))

      TwoDependant.new
    end
  end

  context "model with alternate class" do
    class AlternateClass
      include AggregateRoot

      aggregates :component_one, model_class: ComponentTwo
    end

    it "uses the correct class to instantiate the model" do
      ComponentOne.should_not_receive(:new)
      ComponentTwo.should_receive(:new).
        with(title: "Title")

      AlternateClass.new(component_one_title: "Title")
    end
  end

  context "model with default attribute values" do
    class DefaultValues
      include AggregateRoot

      aggregates :component_one, defaults: { description: "Description" }
    end

    it "includes the defaults during instantiation" do
      ComponentOne.should_receive(:new).
        with(title: "Title", description: "Description")

      DefaultValues.new(component_one_title: "Title")
    end

    it "allows the defaults to be overriden" do
      ComponentOne.should_receive(:new).
        with(description: "Other description")

      DefaultValues.new(component_one_description: "Other description")
    end
  end
end
