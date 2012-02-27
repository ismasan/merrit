require 'spec_helper'

describe Merrit::Resource do
  
  def rack_request(path = '/products/123')
    env = Rack::MockRequest.env_for(path)
    Rack::Request.new(env)
  end
  
  before do
    # @product_class = mock('Product')
    #     
    #     @shop = mock(
    #       name: 'E-Shop',
    #       subdomain: 'eshop'
    #     )
    #     
    #     @product = mock('product',
    #       id: 123, 
    #       title: 'iPhone 4s', 
    #       price: 1200.0, 
    #       description: 'The description',
    #       shop: @shop
    #     )
    #     
    #     @product_class.stub!(:find).and_return @product
    # 
    #     @resource = Class.new(Merrit::Resource) do
    #       
    #       collection :products
    #       
    #       data do
    #         let(:product) { @product_class.find(params[:uid]) }
    #         let(:shop)    { @product.shop }
    #       end
    #       
    #       fields :mini do
    #         expose    data.product, :title, :price
    #       end
    #       
    #       fields :full do
    #         description data.product.description
    #         shop do
    #           delegate(:shop, :mini, :data => :shop)
    #           extra_field 'foo' if params[:show_foo]
    #         end
    #       end
    #       
    #       get do
    #         fields :mini, :full
    #       end
    #       
    #       post do
    #         data.product = @product_class.create params[:product]
    #         fields :mini
    #       end
    #       
    #       put do
    #         data.product.update_attributes params[:product]
    #       end
    #       
    #       delete do
    #         data.product.destroy
    #       end
    #       
    #     end
  end
  
  describe '.collection' do
    context 'implicit' do
      it 'should infer it from class name' do
        class Product < Merrit::Resource; end
        Product.collection.should == 'products'
      end
    end
    
    context 'explicit' do
      it 'should set it' do
        resource = Class.new(Merrit::Resource) do
          collection :products
        end
        resource.collection.should == 'products'
      end
    end
  end
  
  describe '.fields' do
    before do
      categories = [mock('Category', :id => 1, :name => 'Cat 1'), mock('Category', :id => 2, :name => 'Cat 2')]
      
      @resource = Class.new(Merrit::Resource) do
        fields do
          string :title, 'the title'
          integer :age, 34
          array :years, [2010, 2011, 2012]
          array :categories, categories do |cat|
            string :name, cat.name
            integer :id, cat.id
          end
        end
        
        fields :full do
          object :shop do
            string :name, 'Foo Shop'
            string :url, 'foo.shop.com'
          end
        end
        
      end
  
    end
    
    # context 'without explicit group name' do
    #       it 'should map to :all' do
    #         @resource.field_mappings[:all].should be_kind_of(Merrit::Fields)
    #         @resource.field_mappings[:all].schema[:title].should be_kind_of(Merrit::Field)
    #         @resource.field_mappings[:all].schema[:title].type.should == :string
    #       end
    #     end
    #     
    #     context 'with explicit group name' do
    #       it 'should store declared field groups' do
    #         @resource.field_mappings[:full].should be_kind_of(Merrit::Fields)
    #       end
    #     end
  end
  
  describe '#supports?' do
    before do
      resource_class = Class.new(Merrit::Resource) do
        get do
          
        end
      end
      
      @resource = resource_class.new(rack_request)
    end
    
    context 'with declared HTTP method' do
      it 'should be true' do
        @resource.supports?('GET').should be_true
        @resource.supports?('get').should be_true
        @resource.supports?(:get).should be_true
      end
    end
    
    context 'with missing HTTP methods' do
      it 'should be false' do
        @resource.supports?('PUT').should be_false
        @resource.supports?('put').should be_false
        @resource.supports?(:put).should be_false        
      end
    end
  end

  
  describe 'Rack integration' do
    before do
      
      categories = [mock('Category', :id => 1, :name => 'Cat 1'), mock('Category', :id => 2, :name => 'Cat 2')]
      
      @resource = Class.new(Merrit::Resource) do
        
        collection :products
        
        data do
          product { Product.find(params[:id]) }
          shop {dede}
        end
        
        fields do
          string :title, 'the title'
          integer :age, 34
          array :years, [2010, 2011, 2012]
          array :categories, categories do |cat|
            string :name, cat.name
            integer :id, cat.id
          end
        end
        
        fields :full do
          object :shop do
            string :name, 'Foo Shop'
            string :url, 'foo.shop.com'
          end
        end
        
        get do
          
        end
        
      end
      
      env = Rack::MockRequest.env_for("/products/123")
      @resp = @resource.call(env)
    end
    
    describe '.call(env)' do
      it 'should be 200 Ok' do
        @resp.status.should == 200
      end
      
      it 'should be json by default' do
        @resp.headers['Content-Type'].should == 'application/json'
      end
      
      describe 'json response' do
        before do
          @json = MultiJson.decode(@resp.body.first)
        end
        
        it 'should map fields to JSON' do
          @json['title'].should == 'the title'
          @json['age'].should == 34
          @json['years'].should == [2010, 2011, 2012]
          #@json['categories'].should == [{'name' => 'Cat 1', 'id' => 1},{'name' => 'Cat 2', 'id' => 2}]
        end
        
      end
    end
    
  end
  
end