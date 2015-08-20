require 'spec_helper'
describe 'tweaks_and_fixes' do

  context 'with defaults for all parameters' do
    it { should contain_class('tweaks_and_fixes') }
  end
end
