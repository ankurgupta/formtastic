# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'SemanticFormBuilder#cancel :as => :link' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    @new_post.stub!(:new_record?).and_return(false)
    semantic_form_for(@new_post) do |builder|
      concat(builder.cancel :as => :link)
    end
  end
  
  it 'should render a cancel li' do
    output_buffer.should have_tag('li.cancel')
  end
  
  it 'should render an anchor' do
    output_buffer.should have_tag('li.cancel a')
  end
  
  it 'should render a span inside the anchor' do
    output_buffer.should have_tag('li.cancel a span')
  end
  
  it "should render an anchor with the text" do
    output_buffer.should have_tag('li.cancel a', /TODO/)
  end
  
  it "should render an anchor with the class 'button' and 'negative' to allow styling with 'pretty buttons' frameworks" do
    output_buffer.should have_tag('li.cancel a.button.negative')
  end
  
  describe 'when access key is nil' do
    it "should not have an accesskey" do
      ::Formtastic::SemanticFormBuilder.default_cancel_button_accesskey.should == nil
      semantic_form_for(@new_post) do |builder|
        concat(builder.cancel('text', :as => :link, :button_html => {}))
      end
      output_buffer.should_not have_tag('li.cancel a[@accesskey]')
    end
  end
  
  describe 'when access key is set through configuration' do
    it "should not have an accesskey" do
      ::Formtastic::SemanticFormBuilder.default_cancel_button_accesskey = 's'
      @new_post.stub!(:new_record?).and_return(false)
      semantic_form_for(@new_post) do |builder|
        concat(builder.cancel('text', :as => :link, :button_html => {}))
      end
      output_buffer.should have_tag('li.cancel a[@accesskey="s"]')
      ::Formtastic::SemanticFormBuilder.default_cancel_button_accesskey = nil
    end
  end
  
  describe 'when access key is set through options' do
    it 'should use the value set in options over the default' do
      ::Formtastic::SemanticFormBuilder.default_cancel_button_accesskey = 's'
      @new_post.stub!(:new_record?).and_return(false)
      semantic_form_for(@new_post) do |builder|
        concat(builder.cancel('text', :as => :link, :accesskey => 'o'))
      end
      output_buffer.should_not have_tag('li.cancel a[@accesskey="s"]')
      output_buffer.should have_tag('li.cancel a[@accesskey="o"]')
      ::Formtastic::SemanticFormBuilder.default_cancel_button_accesskey = nil
    end
  end
  
  describe "when accesskey is set through :button_html option" do
    it 'should use the value set in button_html' do
      ::Formtastic::SemanticFormBuilder.default_cancel_button_accesskey = 's'
      @new_post.stub!(:new_record?).and_return(false)
      semantic_form_for(@new_post) do |builder|
        concat(builder.cancel('text', :as => :link, :accesskey => 'o', :button_html => {:accesskey => 't'}))
      end
      output_buffer.should_not have_tag('li.cancel a[@accesskey="s"]')
      output_buffer.should_not have_tag('li.cancel a[@accesskey="o"]')
      output_buffer.should have_tag('li.cancel a[@accesskey="t"]')
      ::Formtastic::SemanticFormBuilder.default_cancel_button_accesskey = nil
    end
  end
  
  describe "when :button_html options are provided" do
    
    before do
      @output_buffer = ''
      @new_post.stub!(:new_record?).and_return(false)
      semantic_form_for(@new_post) do |builder|
        concat(builder.cancel('text', :as => :link, :button_html => {:class => 'my_class', :id => 'my_id'}))
      end
    end
  
    it 'should pass :id to the button' do
      output_buffer.should have_tag('li.cancel a#my_id')
    end
    
    it 'should pass :class to the button' do
      output_buffer.should have_tag('li.cancel a.my_class')        
    end
    
  end
  
  describe 'when the first option is a string and the second is a hash' do
  
    before do
      @new_post.stub!(:new_record?).and_return(false)
      semantic_form_for(@new_post) do |builder|
        concat(builder.cancel("a string", :as => :link, :button_html => { :class => "wowser"}))
      end
    end
  
    it "should render the string in the anchor" do
      output_buffer.should have_tag('li a', /a string/)
    end
  
    it "should deal with the options hash" do
      output_buffer.should have_tag('li a.wowser')
    end
  
  end
  
  describe 'when the first option is a hash' do
  
    before do
      @new_post.stub!(:new_record?).and_return(false)
      semantic_form_for(@new_post) do |builder|
        concat(builder.cancel(:as => :link, :button_html => { :class => "wowser"}))
      end
    end
  
    it "should deal with the options hash" do
      output_buffer.should have_tag('li a.wowser')
    end
  
  end
  
  describe 'label' do
    before do
      ::Post.stub!(:human_name).and_return('Post')
    end
    
    after do
      ::I18n.backend.store_translations :en, :formtastic => nil
    end
  
    # No object
    describe 'when used without object' do
      describe 'when explicit label is provided' do
        it 'should render an input with the explicitly specified label' do
          semantic_form_for(:post, :url => 'http://example.com') do |builder|
            concat(builder.cancel("Click!", :as => :link))
          end
          output_buffer.should have_tag('li.cancel a[@class~="submit"]', /Click!/)
        end
      end
  
      describe 'when no explicit label is provided' do
        describe 'when no I18n-localized label is provided' do
          before do
            ::I18n.backend.store_translations :en, :formtastic => {:submit => 'Submit {{model}}'}
          end
  
          after do
            ::I18n.backend.store_translations :en, :formtastic => {:submit => nil}
          end
  
          it 'should render an input with default I18n-localized label (fallback)' do
            semantic_form_for(:post, :url => 'http://example.com') do |builder|
              concat(builder.cancel(:as => :link))
            end
            output_buffer.should have_tag('li.cancel a[@class~="submit"]', /Submit Post/)
          end
        end
  
       describe 'when I18n-localized label is provided' do
         before do
           ::I18n.backend.store_translations :en,
             :formtastic => {
                 :actions => {
                   :submit => 'Custom Submit',
                   :post => {
                     :submit => 'Custom Submit {{model}}'
                    }
                  }
               }
           ::Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true
         end
  
         it 'should render an input with localized label (I18n)' do
           semantic_form_for(:post, :url => 'http://example.com') do |builder|
             concat(builder.cancel(:as => :link))
           end
           output_buffer.should have_tag(%Q{li.cancel a[@class~="submit"]}, /Custom Submit Post/)
         end
  
         it 'should render an input with anoptional localized label (I18n) - if first is not set' do
           ::I18n.backend.store_translations :en,
             :formtastic => {
                 :actions => {
                   :post => {
                     :submit => nil
                    }
                  }
               }
           semantic_form_for(:post, :url => 'http://example.com') do |builder|
             concat(builder.cancel(:as => :link))
           end
           output_buffer.should have_tag(%Q{li.cancel a[@class~="submit"]}, /Custom Submit/)
         end
  
       end
      end
    end
  
    # New record
    describe 'when used on a new record' do
      before do
        @output_buffer = ''
        @new_post.stub!(:new_record?).and_return(true)
      end
  
      describe 'when explicit label is provided' do
        it 'should render an input with the explicitly specified label' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.cancel("Click!", :as => :link))
          end
          output_buffer.should have_tag('li.cancel a', /Click!/)
        end
      end
  
      describe 'when no explicit label is provided' do
        describe 'when no I18n-localized label is provided' do
          before do
            ::I18n.backend.store_translations :en, :formtastic => {:create => 'Create {{model}}'}
          end
  
          after do
            ::I18n.backend.store_translations :en, :formtastic => {:create => nil}
          end
  
          it 'should render an input with default I18n-localized label (fallback)' do
            semantic_form_for(@new_post) do |builder|
              concat(builder.cancel(:as => :link))
            end
            output_buffer.should have_tag('li.cancel a[@class~="create"]', /Create Post/)
          end
        end
  
        describe 'when I18n-localized label is provided' do
          before do
            ::I18n.backend.store_translations :en,
              :formtastic => {
                  :actions => {
                    :create => 'Custom Create',
                    :post => {
                      :create => 'Custom Create {{model}}'
                     }
                   }
                }
            ::Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true
          end
  
          it 'should render an input with localized label (I18n)' do
            semantic_form_for(@new_post) do |builder|
              concat(builder.cancel(:as => :link))
            end
            output_buffer.should have_tag(%Q{li.cancel a[@class~="create"]}, /Custom Create Post/)
          end
  
          it 'should render an input with anoptional localized label (I18n) - if first is not set' do
            ::I18n.backend.store_translations :en,
              :formtastic => {
                  :actions => {
                    :post => {
                      :create => nil
                     }
                   }
                }
            semantic_form_for(@new_post) do |builder|
              concat(builder.cancel(:as => :link))
            end
            output_buffer.should have_tag(%Q{li.cancel a[@class~="create"]}, /Custom Create/)
          end
  
        end
      end
    end
  
    # Existing record
    describe 'when used on an existing record' do
      before do
        @new_post.stub!(:new_record?).and_return(false)
      end
  
      describe 'when explicit label is provided' do
        it 'should render an input with the explicitly specified label' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.cancel("Click!", :as => :link))
          end
          output_buffer.should have_tag('li.cancel a[@class~="update"]', /Click!/)
        end
      end
  
      describe 'when no explicit label is provided' do
        describe 'when no I18n-localized label is provided' do
          before do
            ::I18n.backend.store_translations :en, :formtastic => {:update => 'Save {{model}}'}
          end
  
          after do
            ::I18n.backend.store_translations :en, :formtastic => {:update => nil}
          end
  
          it 'should render an input with default I18n-localized label (fallback)' do
            semantic_form_for(@new_post) do |builder|
              concat(builder.cancel(:as => :link))
            end
            output_buffer.should have_tag('li.cancel a[@class~="update"]', /Save Post/)
          end
        end
  
        describe 'when I18n-localized label is provided' do
          before do
            ::I18n.backend.store_translations :en,
              :formtastic => {
                  :actions => {
                    :update => 'Custom Save',
                    :post => {
                      :update => 'Custom Save {{model}}'
                     }
                   }
                }
            ::Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true
          end
  
          it 'should render an input with localized label (I18n)' do
            semantic_form_for(@new_post) do |builder|
              concat(builder.cancel(:as => :link))
            end
            output_buffer.should have_tag(%Q{li.cancel a[@class~="update"]}, /Custom Save Post/)
          end
  
          it 'should render an input with anoptional localized label (I18n) - if first is not set' do
            ::I18n.backend.store_translations :en,
              :formtastic => {
                  :actions => {
                    :post => {
                      :update => nil
                     }
                   }
                }
            semantic_form_for(@new_post) do |builder|
              concat(builder.cancel(:as => :link))
            end
            output_buffer.should have_tag(%Q{li.cancel a[@class~="update"]}, /Custom Save/)
          end
  
        end
      end
    end
  end
    
end
