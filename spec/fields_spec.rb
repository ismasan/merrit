require 'spec_helper'

describe Merrit::Fields do
  
  before do
    @context = mock('Context')
    
    @fields = Merrit::Fields.new(@context) do
      string :title, 'The title'
      
      object :shop do
        string :name, 'A shop'
      end
      
      array :user_ids, [1,2,3,4]
    end
  end
  
  it 'should define top level fields' do
    @fields[:title].should be_kind_of(Merrit::Field)
    @fields[:title].type.should == :string
    @fields[:title].value.should == 'The title'
  end
  
  it 'should define nested fields' do
    @fields[:shop].should be_kind_of(Merrit::Fields)
    @fields[:shop].type.should == :object
    @fields[:shop][:name].should be_kind_of(Merrit::Field)
    @fields[:shop][:name].value.should == 'A shop'
  end
  
  describe 'array' do
    context 'with block' do
      before do
        categories = [{:name => 'Cat 1'}, {:name => 'Cat 2'}]
        
        @fields = Merrit::Fields.new(@context) do
          array :categories, categories do |cat|
            string :name, cat[:name]
          end
        end
      end
      
      it 'should map to array of objects' do
        @fields[:categories]
      end
    end
  end
  
  describe '#to_hash' do
    it 'should produce a ruby hash' do
      hash = @fields.to_hash
      hash[:title].should == 'The title'
      hash[:shop][:name].should == 'A shop'
    end
  end
  
  describe '#merge!' do
    before do
      
      @more_fields = Merrit::Fields.new(@context) do
        string :title, 'Changed title'
        string :description, 'a description'
        integer :age, 34
        object :account do
          string :name, 'an account'
        end
      end
      
      @fields.merge! @more_fields
    end
    
    it 'should merge into host fields' do
      @fields[:title].value.should == 'Changed title'
      @fields[:description].value.should == 'a description'
      @fields[:age].value.should == 34
      @fields[:shop].should be_kind_of(Merrit::Fields)
      @fields[:account].should be_kind_of(Merrit::Fields)
    end
  end
  
end