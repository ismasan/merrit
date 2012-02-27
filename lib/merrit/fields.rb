module Merrit
  
  class Fields
    
    attr_accessor :fields
    
    def initialize(context, &block)
      @context = context
      @fields = {}
      instance_eval(&block) if block_given?
    end
    
    def type
      :object
    end
    
    def to_hash
      @fields.inject({}) do |mem, (k, v)|
        mem[k.to_sym] = v.to_hash
        mem
      end
    end
    
    def [](key)
      @fields[key]
    end
    
    def string(field_name, value)
      @fields[field_name] = Merrit::Field.new(value, :string)
    end
    
    def integer(field_name, value)
      @fields[field_name] = Merrit::Field.new(value, :integer)
    end
    
    def object(field_name, &block)
      @fields[field_name] = Merrit::Fields.new(@context, &block)
    end
    
    def array(field_name, value = nil, &block)
      if block_given?
        
      else
        @fields[field_name] = Merrit::Field.new(value, :array)
      end
    end
    
    def merge!(other_fields)
      other_fields.fields.each do |key, value|
        @fields[key] = value
      end
    end
    
  end
  
end