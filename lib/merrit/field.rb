module Merrit
  
  class Field
    
    attr_reader :value, :type
    
    def initialize(value, type)
      @value, @type = value, type
    end
    
    def to_hash
      value
    end
    
  end
  
end