# frozen_string_literal: false

require 'spec_helper'

describe InspecDelta::Object::Control do
  describe '#initialize' do
    subject { described_class.new }
    let(:empty_array) { [] }
    let(:empty_string) { '' }

    context 'when the class is initialized' do
      it 'attributes are initialized' do
        expect(subject.instance_variable_get(:@global_code)).to eq(empty_array)
        expect(subject.instance_variable_get(:@control_code)).to eq(empty_array)
        expect(subject.instance_variable_get(:@control_string)).to eq(empty_string)
      end
    end
  end

  describe '#apply_updates' do
    subject { control.apply_updates(other_control) }

    let(:other_title_stub) { 'title_stub' }
    let(:other_desc_stub) { 'desc stub' }
    let(:other_impact_stub) { 'impact stub' }
    let(:control) { InspecDelta::Object::Control.new }
    let(:other_control) do
      instance_double(
        InspecDelta::Object::Control,
        title: other_title_stub,
        descriptions: { default: other_desc_stub },
        impact: other_impact_stub
      )
    end

    before do
      allow(control).to receive(:apply_updates_title).with(other_title_stub)
      allow(control).to receive(:apply_updates_desc).with(other_desc_stub)
      allow(control).to receive(:apply_updates_impact).with(other_impact_stub)
      allow(control).to receive(:apply_updates_tags).with(other_control)
      subject
    end

    it 'updates the control title' do
      expect(control).to have_received(:apply_updates_title).with(other_title_stub)
    end

    it 'updates the control description' do
      expect(control).to have_received(:apply_updates_desc).with(other_desc_stub)
    end

    it 'updates the control impact' do
      expect(control).to have_received(:apply_updates_impact).with(other_impact_stub)
    end

    it 'updates the control tags' do
      expect(control).to have_received(:apply_updates_tags).with(other_control)
    end
  end

  describe '#apply_updates_title' do
    subject { control.apply_updates_title(newtitle) }
    let(:control) { InspecDelta::Object::Control.new }
    let(:control_string) do
      %(control '#{controlId}' do
      title '#{oldtitle}'
    )
    end
    let(:controlId) { 'V-12345' }
    let(:oldtitle) { 'old title' }

    before do
      control.instance_variable_set(:@control_string, control_string)
    end

    context 'when title is provided' do
      let(:newtitle) { 'new title' }
      it 'updates the control string' do
        subject
        expect(control.instance_variable_get(:@control_string)).to include(newtitle)
      end
    end

    context 'when title is not provided' do
      let(:newtitle) { '' }
      it 'does not update the control string' do
        subject
        expect(control.instance_variable_get(:@control_string)).to eq(control_string)
      end
    end
  end

  describe '#apply_updates_desc' do
    subject { control.apply_updates_desc(newdesc) }
    let(:control) { InspecDelta::Object::Control.new }
    let(:control_string) do
      %(control '#{controlId}' do
      desc '#{olddesc}'
    )
    end
    let(:controlId) { 'V-12345' }
    let(:olddesc) { 'description that is outdated' }

    before do
      control.instance_variable_set(:@control_string, control_string)
    end

    context 'when description is provided' do
      let(:newdesc) { 'fresh understanding' }
      it 'updates the control string' do
        subject
        expect(control.instance_variable_get(:@control_string)).to include(newdesc)
      end
    end

    context 'when description is not provided' do
      let(:newdesc) { '' }
      it 'the control string is not updated' do
        subject
        expect(control.instance_variable_get(:@control_string)).to eq(control_string)
      end
    end
  end

  describe '#apply_updates_impact' do
    subject { control.apply_updates_impact(newimpact) }
    let(:control) { InspecDelta::Object::Control.new }
    let(:control_string) do
      %(control '#{controlId}' do
        impact #{oldimpact}
    )
    end
    let(:controlId) { 'V-12345' }
    let(:oldimpact) { 0.5 }

    before do
      control.instance_variable_set(:@control_string, control_string)
    end

    context 'when impact is provided' do
      let(:newimpact) { 0.7 }
      it 'Updates the control string' do
        subject
        expect(control.instance_variable_get(:@control_string)).to include(newimpact.to_s)
      end
    end

    context 'when impact is not provided' do
      let(:newimpact) {}
      it 'the control string is not updated' do
        subject
        expect(control.instance_variable_get(:@control_string)).to eq(control_string)
      end
    end
  end

  describe '#apply_updates_tags' do
    subject { control.apply_updates_tags(other_control) }

    let(:control) { InspecDelta::Object::Control.new }
    let(:other_control) { InspecDelta::Object::Control.new }
    let(:control_string) do
      %(control '#{controlId}' do
      tag '#{tagId}': '#{oldtag}'
      tag '#{empty_tag_id}': '#{empty_string}'
      tag '#{array_tag_id}': #{old_array_value}
      tag '#{bool_tag_id}': #{false_value}
    )
    end
    let(:controlId) { 'V-12345' }
    let(:tagId) { 'gtitle' }
    let(:oldtag) { 'old tagging' }
    let(:newtag) { 'new tag' }
    let(:empty_tag_id) { 'tagemp' }
    let(:empty_string) { '' }
    let(:empty_tag_value) { 'populated' }
    let(:array_tag_id) { 'arrayid' }
    let(:old_array_value) { %w[old values] }
    let(:new_array_value) { %w[values new] }
    let(:bool_tag_id) { 'btag' }
    let(:false_value) { false }
    let(:true_value) { true }

    before do
      allow(InspecDelta::Object::Control).to receive(:new).and_return(control)
      control.id = controlId
      control.add_tag(Inspec::Object::Tag.new(tagId, oldtag))
      control.add_tag(Inspec::Object::Tag.new(empty_tag_id, empty_string))
      control.add_tag(Inspec::Object::Tag.new(array_tag_id, old_array_value))
      control.add_tag(Inspec::Object::Tag.new(bool_tag_id, false_value))

      allow(InspecDelta::Object::Control).to receive(:new).and_return(other_control)
      other_control.id = controlId
      other_control.add_tag(Inspec::Object::Tag.new(tagId, newtag))
      other_control.add_tag(Inspec::Object::Tag.new(empty_tag_id, empty_tag_value))
      other_control.add_tag(Inspec::Object::Tag.new(array_tag_id, new_array_value))
      other_control.add_tag(Inspec::Object::Tag.new(bool_tag_id, true_value))

      control.instance_variable_set(:@control_string, control_string)
    end

    it 'Updates the control string' do
      subject
      expect(control.instance_variable_get(:@control_string)).to include(newtag)
      expect(control.instance_variable_get(:@control_string)).to include(empty_tag_value)
      expect(control.instance_variable_get(:@control_string)).to include(new_array_value.to_s)
      expect(control.instance_variable_get(:@control_string)).to include(true_value.to_s)
    end
  end

  describe '#apply_updates_tags_string' do
    subject { control.apply_updates_tags_string(other_tag) }

    let(:control) { InspecDelta::Object::Control.new }
    let(:other_tag) { Inspec::Object::Tag.new(tagId, newtag) }
    let(:control_string) do
      %(control '#{controlId}' do
      tag '#{tagId}': '#{oldtag}'
    )
    end
    let(:controlId) { 'V-12345' }
    let(:tagId) { 'gtitle' }

    before do
      allow(InspecDelta::Object::Control).to receive(:new).and_return(control)
      control.id = controlId
      control.add_tag(Inspec::Object::Tag.new(tagId, oldtag))
      control.instance_variable_set(:@control_string, control_string)
    end

    context 'when tag has a value' do
      let(:oldtag) { 'old tagging' }
      let(:newtag) { 'new tag' }
      it 'Updates the control string' do
        subject
        expect(control.instance_variable_get(:@control_string)).to include(newtag)
      end
    end

    context 'when tag is was empty' do
      let(:oldtag) { '' }
      let(:newtag) { 'populated' }
      it 'Updates the control string' do
        subject
        expect(control.instance_variable_get(:@control_string)).to include(newtag)
      end
    end

    context 'when tag is newly empty' do
      let(:oldtag) { 'populated' }
      let(:newtag) { '' }
      it 'updates the control string to an empty string' do
        subject
        expect(control.instance_variable_get(:@control_string)).to include('')
        expect(control.instance_variable_get(:@control_string)).not_to include(oldtag)
      end
    end
  end

  describe '#apply_updates_tags_array' do
    subject { control.apply_updates_tags_array(other_tag) }

    let(:control) { InspecDelta::Object::Control.new }
    let(:other_tag) { Inspec::Object::Tag.new(tagId, newtag) }
    let(:control_string) do
      %(control '#{controlId}' do
      tag '#{tagId}': #{oldtag}
    )
    end
    let(:controlId) { 'V-12345' }
    let(:tagId) { 'gtitle' }
    let(:oldtag) { %w[old tagging] }
    let(:newtag) { %w[new tag] }

    before do
      allow(InspecDelta::Object::Control).to receive(:new).and_return(control)
      control.id = controlId
      control.add_tag(Inspec::Object::Tag.new(tagId, oldtag))
      control.instance_variable_set(:@control_string, control_string)
    end

    it 'Updates the control array tag' do
      subject
      expect(control.instance_variable_get(:@control_string)).to include(newtag.to_s)
    end
  end

  describe '#apply_updates_tags_bool' do
    subject { control.apply_updates_tags_bool(other_tag) }

    let(:control) { InspecDelta::Object::Control.new }
    let(:other_tag) { Inspec::Object::Tag.new(tagId, newtag) }
    let(:control_string) do
      %(control '#{controlId}' do
      tag '#{tagId}': #{oldtag}
    )
    end
    let(:controlId) { 'V-12345' }
    let(:tagId) { 'gtitle' }
    let(:oldtag) { false }
    let(:newtag) { true }

    before do
      allow(InspecDelta::Object::Control).to receive(:new).and_return(control)
      control.id = controlId
      control.add_tag(Inspec::Object::Tag.new(tagId, oldtag))
      control.instance_variable_set(:@control_string, control_string)
    end

    it 'Updates the control boolean tag' do
      subject
      expect(control.instance_variable_get(:@control_string)).to include(newtag.to_s)
    end
  end

  describe '.from_benchmark' do
    subject { described_class.from_benchmark(benchmark) }

    let(:benchmark) { { value1: value1, id: id, severity: severity, title: title, desc: desc } }
    let(:mocked_tag) { instance_double(Inspec::Object::Tag) }
    let(:mocked_control) { InspecDelta::Object::Control.new }
    let(:key_pair) { { 'key1' => :value1 } }
    let(:id) { 'V-99165' }
    let(:desc) { 'Disabling DCCP protects the system against exploitation of any flaws in the protocol implementation.' }
    let(:value1) { 'test_value' }
    let(:severity) { 'medium' }
    let(:title) { 'The Oracle Linux operating system must be configured so that the Datagram Congestion Control Protocol (DCCP) kernel module is disabled unless required.' }

    before do
      allow(InspecDelta::Object::Control).to receive(:new).and_return(mocked_control)
      allow(described_class).to receive(:benchmark_tags).and_return(key_pair)
      allow(Inspec::Object::Tag).to receive(:new).with('key1', 'test_value').and_return(mocked_tag)
      allow(mocked_control).to receive(:add_tag)
    end

    it 'Creates the same object' do
      expect(mocked_control).to receive(:add_tag).with(mocked_tag)
      expect(subject.descriptions[:default]).to eq desc
      expect(subject.id).to eq id
      expect(subject.title).to eq title
      expect(subject.impact).to eq InspecDelta::Object::Control.impact(severity)
    end
  end

  describe '.from_ruby' do
    subject { described_class.from_ruby(ruby_control_path) }
    let(:ruby_control_path) { '/path/to/ruby.rb' }

    let(:mocked_parser) { instance_double(RubyParser) }
    let(:control_id) { 'V-123' }
    let(:title) { 'title1' }
    let(:control_string) { "control(#{control_id}) do title(#{title}) end" }
    let(:parsed_ruby) do
      s(:iter,
        s(:call, nil, :control, s(:str, control_id)),
        s(:block,
          s(:call, nil, :title, s(:str, title))))
    end

    before do
      allow(File).to receive(:read).with(ruby_control_path).and_return(control_string)
      allow(RubyParser).to receive(:new).and_return(mocked_parser)
      allow(mocked_parser).to receive(:parse).with(control_string).and_return(parsed_ruby)
      allow(described_class).to receive(:parse_ruby)
    end

    it 'calls parse_ruby' do
      expect(described_class).to receive(:parse_ruby).with(kind_of(InspecDelta::Object::Control), parsed_ruby)
      subject
    end

    it 'sets the @control_string instance variable' do
      expect(subject.instance_variable_get(:@control_string)).to eq(control_string)
    end
  end

  describe '.impact' do
    subject { described_class.impact(severity) }

    context 'when severity is low' do
      let(:severity) { 'low' }

      it { is_expected.to eq(0.3) }
    end

    context 'when severity is medium' do
      let(:severity) { 'medium' }

      it { is_expected.to eq(0.5) }
    end

    context 'when severity is high' do
      let(:severity) { 'high' }

      it { is_expected.to eq(0.7) }
    end

    context 'when severity is a bad value' do
      let(:severity) { 'bad' }

      it { is_expected.to eq('bad') }
    end
  end

  describe '#merge_from' do
    subject { control.merge_from(other_control) }
    let(:control) { InspecDelta::Object::Control.new }
    let(:other_control) { InspecDelta::Object::Control.new }
    let(:id) { 'V-00001' }
    let(:desc) { 'This is the original control' }
    let(:impact) { 0.3 }
    let(:tag) { Inspec::Object::Tag.new('tag_key', 'value') }
    let(:mocked_tags) { [tag] }
    let(:title) { 'Original Title' }
    let(:global_string) { "describe(kernel_module(\"dccp\")) do\n  it { should_not(be_loaded) }\n  it { should(be_blacklisted) }\nend" }
    let(:control_string) { "describe(kernel_module(\"dccp\")) do\n  it { should_not(be_loaded) }\nend" }
    let(:global_array) { [global_string] }
    let(:control_array) { [control_string] }

    before do
      control.id = id
      control.title = title
      control.descriptions[:default] = desc
      control.impact = impact
      control.tags.push(tag)
      control.global_code.push(global_string)
      control.control_code.push(control_string)
    end

    context 'when new control is empty' do
      it 'keeps original values' do
        expect(subject.id).to eq id
        expect(subject.title).to eq title
        expect(subject.descriptions[:default]).to eq desc
        expect(subject.impact).to eq impact
        expect(subject.tags).to match_array mocked_tags
        expect(subject.global_code).to match_array global_array
        expect(subject.control_code).to match_array control_array
      end
    end

    context 'when new control is populated' do
      let(:other_id) { 'V-00002' }
      let(:other_title) { 'New Title' }
      let(:other_desc) { 'This is the new control' }
      let(:other_impact) { 0.5 }
      let(:tag_key1) { 'tag_key' }
      let(:tag_key2) { 'second key' }
      let(:tag_value1) { 'first value' }
      let(:tag_value2) { 'second value' }
      let(:other_tag) { Inspec::Object::Tag.new(tag_key1, tag_value1) }
      let(:new_tag) { Inspec::Object::Tag.new(tag_key2, tag_value2) }
      let(:other_mocked_tags) do
        [have_attributes(key: tag_key1, value: tag_value1),
         have_attributes(key: tag_key2, value: tag_value2)]
      end

      before do
        other_control.id = other_id
        other_control.title = other_title
        other_control.descriptions[:default] = other_desc
        other_control.impact = other_impact
        other_control.tags.push(other_tag)
        other_control.tags.push(new_tag)
      end

      it 'updates values' do
        expect(subject.id).to eq id
        expect(subject.title).to eq other_title
        expect(subject.descriptions[:default]).to eq other_desc
        expect(subject.impact).to eq other_impact
        expect(subject.tags).to match_array(other_mocked_tags)
      end
    end
  end

  describe '.parse_base_control' do
    subject { described_class.send(:parse_base_control, control, rarr) }

    let(:control) { InspecDelta::Object::Control.new }
    let(:ruby_call_string) { ["describe(kernel_module(\"#{value}\"))"] }
    let(:ruby_object_string) { ["describe(kernel_module(\"#{value}\")) do\n  it { should_not(be_loaded) }\n  it { should(be_blacklisted) }\nend"] }
    let(:if_string) { ["this = \"#{value}\" if boolean_var"] }
    let(:lasgn_string) { ["boolean_var = \"#{value}\""] }
    let(:title) { 'title1' }
    let(:desc) { 'desc1' }
    let(:controlId) { 'controlId' }
    let(:impact) { 0.5 }
    let(:val1) { 'str1' }
    let(:val2) { 'str2' }
    let(:tag_string) do
      s(:hash,
        s(:lit, :gtitle),
        s(:str, val1))
    end
    let(:tag_array) do
      s(:hash,
        s(:lit, :satisfies),
        s(:array,
          s(:str, val1),
          s(:str, val2)))
    end
    let(:value) { 'test value' }
    let(:block_object) do
      s(:block,
        s(:call, nil, :title, s(:str, title)),
        s(:call, nil, :desc, s(:str, desc)),
        s(:call, nil, :impact, s(:lit, impact)),
        s(:call, nil, :tag, tag_string),
        s(:call, nil, :tag, tag_array))
    end
    let(:control_object) do
      s(:iter,
        s(:call, nil, :control, s(:str, controlId)),
        0,
        block_object)
    end
    let(:call_object) do
      s(:call, nil, :describe,
        s(:call, nil, :kernel_module,
          s(:str, value)))
    end
    let(:ruby_object) do
      s(:iter,
        s(:call, nil, :describe,
          s(:call, nil, :kernel_module,
            s(:str, value))),
        0,
        s(:block,
          s(:iter,
            s(:call, nil, :it),
            0,
            s(:call, nil, :should_not,
              s(:call, nil, :be_loaded))),
          s(:iter,
            s(:call, nil, :it),
            0,
            s(:call, nil, :should,
              s(:call, nil, :be_blacklisted)))))
    end
    let(:lasgn) { s(:lasgn, :boolean_var, s(:str, value)) }
    let(:ifstmt) do
      s(:if,
        s(:lvar, :boolean_var),
        s(:lasgn, :this,
          s(:str, value)),
        nil)
    end
    let(:rarr) do
      s(:block,
        ruby_object,
        control_object)
    end
    let(:mocked_tags) do
      [have_attributes(key: 'gtitle', value: val1.inspect),
       have_attributes(key: 'satisfies', value: [val1, val2].inspect)]
    end

    context 'when we have a control object' do
      it 'sets id' do
        expect(subject.id).to eq controlId
      end

      it 'sets title' do
        expect(subject.title).to eq title
      end

      it 'sets desc' do
        expect(subject.descriptions[:default]).to eq desc
      end

      it 'sets impact' do
        expect(subject.impact).to eq impact
      end

      it 'adds tag' do
        expect(subject.tags).to match_array(mocked_tags)
      end

      it 'adds code to control_code' do
        expect(subject.control_code).to match_array ruby_object_string
      end
    end

    context 'when we have a call object' do
      let(:rarr) { call_object }
      let(:mocked_tags) { [mocked_tag1, mocked_tag2] }

      it 'adds it to control code' do
        expect(subject.control_code).to match_array ruby_call_string
      end
    end

    context 'when passed an iterative' do
      context 'and iterative is of type control' do
        let(:rarr) { control_object }

        it 'calls parse_base_control and sets controlId' do
          expect(subject.id).to eq controlId
          expect(subject.title).to eq title
          expect(subject.descriptions[:default]).to eq desc
          expect(subject.impact).to eq impact
        end
      end

      context 'and iterative is not a control' do
        let(:rarr) { ruby_object }

        it 'adds to control code' do
          expect(subject.control_code).to match_array ruby_object_string
        end
      end

      context 'when passed a left assign' do
        let(:rarr) { lasgn }

        it 'adds to global code' do
          expect(subject.control_code).to match_array lasgn_string
        end
      end

      context 'when passed an if statement' do
        let(:rarr) { ifstmt }

        it 'adds to global code' do
          expect(subject.control_code).to match_array if_string
        end
      end
    end
  end

  describe '.parse_base_control_call' do
    subject { described_class.send(:parse_base_control_call, control, rarr) }

    let(:control) { InspecDelta::Object::Control.new }
    let(:value) { 'test value' }
    let(:call_object_string) { ["describe(kernel_module(\"#{value}\"))"] }
    let(:title) { 'title1' }
    let(:desc) { 'desc1' }
    let(:controlId) { 'controlId' }
    let(:impact) { 0.5 }
    let(:tag_string) do
      s(:hash,
        s(:lit, :gtitle),
        s(:str, value))
    end
    let(:call_object) do
      s(:call, nil, :describe,
        s(:call, nil, :kernel_module,
          s(:str, value)))
    end
    let(:rarr) do
      call_object
    end
    let(:mocked_tags) do
      [have_attributes(key: 'gtitle', value: value.inspect)]
    end

    context 'when the call is control' do
      let(:rarr) { s(:call, nil, :control, s(:str, controlId)) }

      it 'sets id' do
        expect(subject.id).to eq controlId
      end
    end

    context 'when the call is title' do
      let(:rarr) { s(:call, nil, :title, s(:str, title)) }

      it 'sets title' do
        expect(subject.title).to eq title
      end
    end

    context 'when the call is desc' do
      let(:rarr) { s(:call, nil, :desc, s(:str, desc)) }

      it 'sets default description' do
        expect(subject.descriptions[:default]).to eq desc
      end
    end

    context 'when the call is impact' do
      let(:rarr) { s(:call, nil, :impact, s(:lit, impact)) }

      it 'sets impact' do
        expect(subject.impact).to eq impact
      end
    end

    context 'when the call is tag' do
      let(:rarr) { s(:call, nil, :tag, tag_string) }

      it 'sets tag' do
        expect(subject.tags).to match_array(mocked_tags)
      end
    end

    context 'when code' do
      let(:rarr) { call_object }

      it 'adds code to control_code' do
        expect(subject.control_code).to match_array call_object_string
      end
    end
  end

  describe '.parse_ruby' do
    subject { described_class.send(:parse_ruby, control, rarr) }

    let(:control) { InspecDelta::Object::Control.new }
    let(:mocked_base_control) { double(InspecDelta::Object::Control) }
    let(:call_object_string) { ["describe(kernel_module(\"#{value}\"))"] }
    let(:ruby_object_string) { ["describe(kernel_module(\"#{value}\")) do\n  it { should_not(be_loaded) }\n  it { should(be_blacklisted) }\nend"] }
    let(:lasgn_string) { ["boolean_var = \"#{value}\""] }
    let(:if_string) { ["this = \"#{value}\" if boolean_var"] }
    let(:title) { 'title1' }
    let(:desc) { 'desc1' }
    let(:controlId) { 'controlId' }
    let(:impact) { 0.5 }
    let(:value) { 'test value' }
    let(:control_object) do
      s(:iter,
        s(:call, nil, :control, s(:str, controlId)),
        0,
        s(:block,
          s(:call, nil, :title, s(:str, title)),
          s(:call, nil, :desc, s(:str, desc)),
          s(:call, nil, :impact, s(:lit, impact))))
    end
    let(:call_object) do
      s(:call, nil, :describe,
        s(:call, nil, :kernel_module,
          s(:str, value)))
    end
    let(:ruby_object) do
      s(:iter,
        s(:call, nil, :describe,
          s(:call, nil, :kernel_module,
            s(:str, value))),
        0,
        s(:block,
          s(:iter,
            s(:call, nil, :it),
            0,
            s(:call, nil, :should_not,
              s(:call, nil, :be_loaded))),
          s(:iter,
            s(:call, nil, :it),
            0,
            s(:call, nil, :should,
              s(:call, nil, :be_blacklisted)))))
    end
    let(:lasgn) { s(:lasgn, :boolean_var, s(:str, value)) }
    let(:ifstmt) do
      s(:if,
        s(:lvar, :boolean_var),
        s(:lasgn, :this,
          s(:str, value)),
        nil)
    end
    let(:rarr) do
      s(:block,
        ruby_object,
        control_object)
    end

    before do
      allow(described_class).to receive(:parse_base_control).with(control, control_object).and_return(mocked_base_control)
    end

    context 'when passed a call object' do
      let(:rarr) { call_object }
      it 'adds to global code' do
        expect(subject.global_code).to match_array call_object_string
      end
    end

    context 'when passed a block object' do
      it 'recursively calls itself' do
        expect(subject.global_code).to match_array ruby_object_string
      end
    end

    context 'when passed an iterative' do
      context 'and iterative is of type control' do
        let(:rarr) { control_object }

        it 'calls parse_base_control' do
          expect(described_class).to receive(:parse_base_control).with(kind_of(InspecDelta::Object::Control), control_object)
          subject
        end
      end

      context 'and iterative is not a control' do
        let(:rarr) { ruby_object }

        it 'adds to global code' do
          expect(subject.global_code).to match_array ruby_object_string
        end
      end
    end

    context 'when passed a left assign' do
      let(:rarr) { lasgn }

      it 'adds to global code' do
        expect(subject.global_code).to match_array lasgn_string
      end
    end

    context 'when passed an if statement' do
      let(:rarr) { ifstmt }

      it 'adds to global code' do
        expect(subject.global_code).to match_array if_string
      end
    end
  end

  describe '#to_ruby' do
    subject { control.to_ruby }

    let(:control) { InspecDelta::Object::Control.new }
    let(:id) { 'V-99165' }
    let(:desc) { 'Disabling DCCP protects the system against exploitation of any flaws in the protocol implementation.' }
    let(:impact) { 0.5 }
    let(:tag) { Inspec::Object::Tag.new('tag_key', 'tag_value') }
    let(:title) { 'The Oracle Linux operating system must be configured so that the Datagram Congestion Control Protocol (DCCP) kernel module is disabled unless required.' }
    let(:global_string) { ["describe(kernel_module(\"dccp\")) do\n  it { should_not(be_loaded) }\n  it { should(be_blacklisted) }\nend"] }
    let(:control_string) { ["describe(kernel_module(\"dccp\")) do\n  it { should_not(be_loaded) }\nend"] }
    let(:control_output) do
      <<~'FMTSTR'.strip
        describe(kernel_module("dccp")) do
          it { should_not(be_loaded) }
          it { should(be_blacklisted) }
        end
        control "V-99165" do
          title "The Oracle Linux operating system must be configured so that the Datagram Congestion Control Protocol (DCCP) kernel module is disabled unless required."
          desc  "Disabling DCCP protects the system against exploitation of any flaws in the protocol implementation."
          impact 0.5
          tag tag_key: "tag_value"
        describe(kernel_module("dccp")) do
          it { should_not(be_loaded) }
        end
        end
      FMTSTR
    end
    let(:empty_control_output) do
      <<~'FMTSTR'.strip
        control "V-99165" do
        end
      FMTSTR
    end

    context 'when values are not set' do
      before do
        control.id = id
      end

      it 'does not print the values' do
        expect(subject).to eq empty_control_output
      end
    end

    context 'when values are set' do
      before do
        control.id = id
        control.title = title
        control.descriptions[:default] = desc
        control.impact = impact
        control.tags.push(tag)
        control.global_code.push(global_string)
        control.control_code.push(control_string)
      end

      it 'prints values' do
        expect(subject).to eq control_output
      end
    end
  end
end
