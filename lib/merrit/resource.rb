require 'rack'
module Merrit
  
  class Resource
    
    NOT_FOUND_RESPONSE = [404, {'Content-Type' => 'application/json'}, ['{"error":"Not Found"}']].freeze
    
    attr_reader :request, :params, :response
    
    def initialize(request)
      @request = request
      @params = request.params
      @response = Rack::Response.new
    end
    
    def supports?(method_name)
      self.class.supported_methods.keys.include? method_name.downcase.to_sym
    end
    
    def respond!
      @field_groups = []
      catch :halt do
        instance_eval &self.class.supported_methods[request.request_method.downcase.to_sym]
        @field_groups << :all if @field_groups.empty?
        renderer = process_fields(@field_groups)
        response.headers['Content-Type'] = renderer.content_type
        response.write renderer.render
      end
      response.finish
      response
    end
    
    def halt(status, body = '')
      response.status = status
      response.write body
      throw :halt
    end
    
    def fields(*groups)
      groups
    end
    
    protected
    
    # Return a hash of all field groups run for the current request context
    def process_fields(field_groups)
      fields = Merrit::Fields.new(self)
      field_groups.each do |group_key|
        if block = self.class.field_groups[group_key.to_sym]
          fields.merge! Merrit::Fields.new(self, &block)
        end
      end
      Merrit::Renderers::Json.new(fields)
    end
    
    # Turn field definitions into a hash
    def render_fields(block)
      
    end
    
    class << self
      
      def collection(resources_name = nil)
        @resources_name ||= resources_name ? resources_name.to_s : (self.name.downcase + 's')
        @resources_name
      end
      
      def call(env)
        if env['PATH_INFO'] =~ %r{^\/#{collection}\/(.+)}
          request = Rack::Request.new(env)
          request.params[:uid] = $1
          resource = new(request)
          if resource.supports? request.request_method
            resource.respond!
          else
            NOT_FOUND_RESPONSE
          end
        else
          NOT_FOUND_RESPONSE
        end
      end
      
      def data(&block)
        
      end
      
      def fields(group = nil, &block)
        group ||= :all
        field_groups[group] = block
      end
      
      def field_groups
        @field_groups ||= {}
      end
      
      def get(&block)
        register_handler :get, block
      end
      
      def post(&block)
        register_handler :post, block
      end
      
      def put(&block)
        register_handler :put, block
      end
      
      def delete(&block)
        register_handler :delete, block
      end
      
      def options(&block)
        register_handler :options, block
      end
      
      def supported_methods
        (@supported_methods ||= {})
      end
      
      protected
      
      def register_handler(method_name, handler)
        supported_methods[method_name] = handler
      end
      
    end
    
  end
  
end