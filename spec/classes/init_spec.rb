require 'spec_helper'
describe 'projects' do

  context 'with defaults for all parameters' do
    it { should contain_class('projects') }
  end
end
