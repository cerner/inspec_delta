# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InspecDelta do
  it 'has a version number' do
    expect(InspecDelta::VERSION).not_to be nil
  end
end
