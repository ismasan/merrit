require 'multi_json'
module Merrit
  
  module Renderers
    class Json < Renderer
      
      def render
        MultiJson.encode(fields.to_hash)
      end
      
      def content_type
        'application/json'
      end
      
    end
  end
  
end