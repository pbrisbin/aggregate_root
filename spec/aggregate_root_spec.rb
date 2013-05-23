require 'spec_helper'

describe AggregateRoot do
  class MockComponent
    def self.attributes
      []
    end

    def initialize(options = {})
    end
  end

  class ComponentOne < MockComponent
    def self.attributes
      [:title, :description]
    end
  end

  class ComponentTwo < MockComponent
    def self.attributes
      [:name, :description]
    end
  end

  class ComponentThree < MockComponent
  end

  context "of simple models" do
    class Simple
      include AggregateRoot

      aggregates :component_one
      aggregates :component_two
    end

    it "initializes its components from prefixed attributes" do
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

    it "sets those attributes on the aggregate class" do
      simple = Simple.new(
        component_one_title: "Title",
        component_one_description: "Description",
        component_two_name: "Name",
        component_two_description: "Description Two"
      )

      expect(simple.component_one_title).to eq "Title"
      expect(simple.component_one_description).to eq "Description"
      expect(simple.component_two_name).to eq "Name"
      expect(simple.component_two_description).to eq "Description Two"
    end
  end

  context "with one model related to another" do
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

  context "with one model related to two others" do
    class TwoDependant
      include AggregateRoot

      aggregates :component_one
      aggregates :component_two
      aggregates :component_three,
        related_to: [:component_one, :component_two]
    end

    it "initializes the second component with references to each of the others" do
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

  context "with a specific class" do
    class AlternateClass
      include AggregateRoot

      aggregates :component_one, model_class: ComponentTwo
    end

    it "uses that class to instantiate the model" do
      ComponentOne.should_not_receive(:new)
      ComponentTwo.should_receive(:new).
        with(name: "Name")

      AlternateClass.new(component_one_name: "Name")
    end
  end

  context "with default attribute values" do
    class DefaultValues
      include AggregateRoot

      aggregates :component_one, defaults: { description: "Description" }
    end

    it "includes those defaults during instantiation" do
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

  context "with conditional inclusion" do
    class ConditionalComponent
      include AggregateRoot

      aggregates :component_one,
        if: ->(attrs) { attrs.key?(:title) }
    end

    it "instantiates the component when the condition is true" do
      ComponentOne.should_receive(:new).
        with(title: "Title")

      ConditionalComponent.new(component_one_title: "Title")
    end

    it "does not instantiate the component when the condition is false" do
      ComponentOne.should_not_receive(:new)

      ConditionalComponent.new
    end
  end
end
