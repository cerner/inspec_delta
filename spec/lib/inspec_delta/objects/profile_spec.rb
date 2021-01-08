# frozen_string_literal: true

require 'spec_helper'

describe InspecDelta::Object::Profile do
  let(:described_class_instance) { described_class.new(profile) }
  let(:profile) { 'path/to/profile' }
  let(:path_exists) { true }
  let(:profile_error_msg) { "Profile directory at #{profile} not found" }

  before do
    allow(Dir).to receive(:exist?).with(profile).and_return(path_exists)
  end

  describe '#initialize' do
    subject { described_class_instance }

    context 'when the directory at profile path exists' do
      it 'profile path is set' do
        subject
        expect(described_class_instance.instance_variable_get(:@profile_path)).to eq(profile)
      end
    end

    context 'when the directory at profile path does not exist' do
      let(:profile) {}
      let(:path_exists) { false }

      it 'throws an error' do
        expect { subject }.to raise_error(StandardError, profile_error_msg)
      end
    end
  end

  describe '#format' do
    subject { described_class_instance.format }

    let(:control_dir) { "#{File.expand_path(profile)}/controls" }
    let(:rubo_file) { "#{File.expand_path(profile)}/.rubocop.yml" }
    let(:rubo_exists) { true }

    before do
      allow(File).to receive(:exist?).with(rubo_file).and_return(rubo_exists)
      allow(described_class_instance).to receive(:`)
    end

    context 'when rubocop config file exists' do
      it 'calls rubocop' do
        expect(described_class_instance).to receive(:`).with("rubocop -a #{control_dir} -c #{rubo_file}")
        expect { subject }.not_to raise_error
      end
    end

    context 'when rubocop config file does not exist' do
      let(:rubo_exists) { false }
      let(:rubo_error_msg) { "Rubocop configuration file at #{rubo_file} not found" }

      it 'throws an error' do
        expect { subject }.to raise_error(StandardError, rubo_error_msg)
      end
    end
  end

  describe '#update' do
    subject { described_class_instance.update(stig) }

    let(:stig) { 'path/to/stig.xml' }
    let(:control_dir) { 'path/to/profile/controls' }
    let(:stig_exists) { true }
    let(:benchmark) { instance_double(Hash) }
    let(:benchmark_control) { instance_double(InspecDelta::Object::Control) }
    let(:profile_control_path) { 'path/to/profile/controls/1.rb' }
    let(:control_id) { 1 }
    let(:control) { InspecDelta::Object::Control }
    let(:file_status) { true }

    before do
      allow(File).to receive(:exist?).with(stig).and_return(stig_exists)
      allow(InspecDelta::Parser::Benchmark).to receive(:get_benchmark).with(stig).and_return(benchmark)
      allow(benchmark).to receive(:each).and_yield(control_id, control)
      allow(InspecDelta::Object::Control).to receive(:from_benchmark).with(control).and_return(benchmark_control)
      allow(File).to receive(:join).with(File.expand_path(control_dir), "#{control_id}.rb").and_return(profile_control_path)
      allow(File).to receive(:file?).with(profile_control_path).and_return(file_status)
      allow(described_class_instance).to receive(:update_existing_control_file)
      allow(described_class_instance).to receive(:create_new_control_file)
    end

    context 'when STIG file exists' do
      context 'when control file exists' do
        it 'calls update_existing_control_file' do
          expect(described_class_instance).to receive(:update_existing_control_file).with(profile_control_path, benchmark_control)
          subject
        end
      end

      context 'when control file does not exist' do
        let(:file_status) { false }

        it 'calls create_new_control_file' do
          expect(described_class_instance).to receive(:create_new_control_file).with(profile_control_path, benchmark_control)
          subject
        end
      end
    end

    context 'when STIG file does not exist' do
      let(:stig_exists) { false }
      let(:stig_error_msg) { "STIG file at #{stig} not found" }

      it 'throws an error' do
        expect { subject }.to raise_error(StandardError, stig_error_msg)
      end
    end
  end

  describe '#update_existing_control_file' do
    subject { described_class_instance.update_existing_control_file(profile_control_path, benchmark_control) }

    let(:profile_control_path) { 'path/to/profile' }
    let(:benchmark_control) { instance_double(InspecDelta::Object::Control) }
    let(:control) { instance_double(InspecDelta::Object::Control) }
    let(:updated_control) { instance_double(String) }
    let(:control_file) { instance_double(File) }

    before do
      allow(InspecDelta::Object::Control).to receive(:from_ruby).with(profile_control_path).and_return(control)
      allow(control).to receive(:apply_updates).with(benchmark_control).and_return(updated_control)
      allow(File).to receive(:open).with(profile_control_path, 'w').and_yield(control_file)
      allow(control_file).to receive(:puts)
    end

    it 'reads profile control path' do
      subject
      expect(control_file).to have_received(:puts).with(updated_control)
    end
  end

  describe '#create_new_control_file' do
    subject { described_class_instance.create_new_control_file(profile_control_path, benchmark_control) }

    let(:profile_control_path) { 'path/to/profile' }
    let(:benchmark_control) { instance_double(InspecDelta::Object::Control) }
    let(:control) { instance_double(InspecDelta::Object::Control) }
    let(:control_file) { instance_double(File) }
    let(:ruby_output) { 'control x do end' }

    before do
      allow(File).to receive(:open).with(profile_control_path, 'w').and_yield(control_file)
      allow(benchmark_control).to receive(:to_ruby).and_return(ruby_output)
      allow(control_file).to receive(:puts)
    end

    it 'creates control file' do
      subject
      expect(control_file).to have_received(:puts).with(ruby_output)
    end
  end
end
