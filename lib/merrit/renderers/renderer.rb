module Merrit
  
  module Renderers
    
    class Renderer
      
      attr_reader :fields
      
      def initialize(fields)
        @fields = fields
      end
      
      def render
        raise 'Define this in subclass'
      end
      
      def content_type
        'text/html'
      end
    end
    
  end
  
end