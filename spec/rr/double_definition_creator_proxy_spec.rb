require "spec/spec_helper"

module RR
  describe DoubleDefinitionCreatorProxy, "initializes proxy with passed in creator", :shared => true do
    it "initializes proxy with passed in creator" do
      class << the_proxy
        attr_reader :creator
      end
      the_proxy.creator.should === creator
    end
  end

  describe DoubleDefinitionCreatorProxy do
    attr_reader :space, :subject, :creator, :the_proxy
    it_should_behave_like "Swapped Space"

    before(:each) do
      @space = Space.instance
      @subject = Object.new
      @creator = DoubleDefinitionCreator.new
      creator.mock
    end

    describe ".new without block" do
      it_should_behave_like "RR::DoubleDefinitionCreatorProxy initializes proxy with passed in creator"
      before do
        @the_proxy = DoubleDefinitionCreatorProxy.new(creator, subject)
      end

      it "clears out all methods from proxy" do
        proxy_subclass = Class.new(DoubleDefinitionCreatorProxy) do
          def i_should_be_a_double
          end
        end
        proxy_subclass.instance_methods.should include('i_should_be_a_double')

        proxy = proxy_subclass.new(creator, subject)
        proxy.i_should_be_a_double.should be_instance_of(DoubleDefinition)
      end
    end

    describe ".new with block" do
      it_should_behave_like "RR::DoubleDefinitionCreatorProxy initializes proxy with passed in creator"
      before do
        @the_proxy = DoubleDefinitionCreatorProxy.new(creator, subject) do |b|
          b.foobar(1, 2) {:one_two}
          b.foobar(1) {:one}
          b.foobar.with_any_args {:default}
          b.baz() {:baz_result}
        end
      end

      it "creates double_injections" do
        subject.foobar(1, 2).should == :one_two
        subject.foobar(1).should == :one
        subject.foobar(:something).should == :default
        subject.baz.should == :baz_result
      end

      it "clears out all methods from proxy" do
        proxy_subclass = Class.new(DoubleDefinitionCreatorProxy) do
          def i_should_be_a_double
          end
        end
        proxy_subclass.instance_methods.should include('i_should_be_a_double')

        proxy_subclass.new(creator, subject) do |m|
          m.i_should_be_a_double.should be_instance_of(DoubleDefinition)
        end
      end
    end
  end
end