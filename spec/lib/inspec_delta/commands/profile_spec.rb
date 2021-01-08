# frozen_string_literal: true

require 'spec_helper'

describe InspecDelta::Command do
  let(:profile_path_stub) { 'profile/path' }
  let(:stig_file_path_stub) { 'stig/path' }
  let(:command_options) do
    [
      '--profile_path', profile_path_stub,
      '--stig_file_path', stig_file_path_stub
    ]
  end

  describe '#update' do
    subject(:profile_update_test_run) { described_class.start(['profile', 'update', *command_options]) }
    let(:mock_profile_update) { instance_double(InspecDelta::Object::Profile, update: nil, format: nil) }

    before do
      allow(InspecDelta::Object::Profile).to receive(:new).with(profile_path_stub).and_return(mock_profile_update)
    end

    context 'when all required options are given' do
      it 'runs profile update with the correct parameters' do
        profile_update_test_run
        expect(mock_profile_update).to have_received(:update).with(stig_file_path_stub)
      end

      it 'formats the updated code' do
        profile_update_test_run
        expect(mock_profile_update).to have_received(:format)
      end
    end

    context 'when all required options are not given' do
      context 'when stig_file_path is missing' do
        let(:command_options) { ['--profile_path', profile_path_stub] }

        it 'raises exit error' do
          expect { profile_update_test_run }.to raise_error(SystemExit)
        end
      end

      context 'when stig_file_path is missing' do
        let(:command_options) { ['--stig_file_path', stig_file_path_stub] }

        it 'raises exit error' do
          expect { profile_update_test_run }.to raise_error(SystemExit)
        end
      end
    end
  end
end
