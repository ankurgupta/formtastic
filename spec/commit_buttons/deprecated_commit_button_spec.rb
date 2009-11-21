# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'SemanticFormBuilder#commit_button' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end
  
  it "should warn about deprecation" do
    ::ActiveSupport::Deprecation.should_receive(:warn).with(/commit_button/, anything())
    semantic_form_for(@new_post) do |builder|
      concat(builder.commit_button)
    end
  end
  
  it "should call commit button" do
    semantic_form_for(@new_post) do |builder|
      builder.should_receive(:commit_button).with("Foo").and_return("")
      concat(builder.commit_button("Foo"))
    end
  end
  
end