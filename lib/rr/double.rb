module RR
  class Double
    attr_reader :space, :object, :method_name, :original_method, :scenarios

    def initialize(space, object, method_name)
      @space = space
      @object = object
      @method_name = method_name.to_sym
      @original_method = object.method(method_name) if @object.methods.include?(method_name.to_s)
      @scenarios = []
    end

    def bind
      define_implementation_placeholder
      returns_method = <<-METHOD
        def #{@method_name}(*args, &block)
          if block
            args << block
            #{placeholder_name}(*args)
          else
            #{placeholder_name}(*args)
          end
        end
      METHOD
      meta.class_eval(returns_method, __FILE__, __LINE__ - 9)
    end

    def verify
      @scenarios.each do |scenario|
        scenario.verify
      end
    end

    def reset
      meta.send(:remove_method, placeholder_name)
      if @original_method
        meta.send(:define_method, @method_name, &@original_method)
      else
        meta.send(:remove_method, @method_name)
      end
    end

    protected
    def define_implementation_placeholder
      me = self
      meta.send(:define_method, placeholder_name) do |*args|
        me.send(:call_method, *args)
      end
    end

    def call_method(*args)
      scenarios.each do |scenario|
        return scenario.call(*args) if scenario.exact_match?(*args)
      end
      scenarios.each do |scenario|
        return scenario.call(*args) if scenario.wildcard_match?(*args)
      end
    end
    
    def placeholder_name
      "__rr__#{@method_name}__rr__"
    end
    
    def meta
      (class << @object; self; end)
    end
  end
end
