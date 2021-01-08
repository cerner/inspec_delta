# frozen_string_literal: true

require 'spec_helper'
require 'inspec_tools'

describe InspecDelta::Parser::Benchmark do
  describe '.get_benchmark' do
    subject(:get_benchmark) { described_class.get_benchmark('test_file.xml') }

    let(:benchmark) { instance_double(HappyMapperTools::StigAttributes::Benchmark) }
    let(:group) { instance_double(HappyMapperTools::StigAttributes::Group) }
    let(:rule) { instance_double(HappyMapperTools::StigAttributes::Rule) }
    let(:description) { instance_double(HappyMapperTools::StigAttributes::Description) }
    let(:details) { instance_double(HappyMapperTools::StigAttributes::DescriptionDetails) }
    let(:ref_group) { instance_double(HappyMapperTools::StigAttributes::ReferenceInfo) }
    let(:fix) { instance_double(HappyMapperTools::StigAttributes::Fix) }
    let(:check) { instance_double(HappyMapperTools::StigAttributes::Check) }
    let(:content_ref) { instance_double(HappyMapperTools::StigAttributes::ContentRef) }
    let(:plaintext) { instance_double(HappyMapperTools::StigAttributes::Plaintext) }
    let(:groups) { [group] }

    before do
      allow(File).to receive(:read)
      allow(HappyMapperTools::StigAttributes::Benchmark).to receive(:parse).and_return(benchmark)
      allow(benchmark).to receive(:title).and_return(title)
      allow(benchmark).to receive(:version).and_return(version)
      allow(benchmark).to receive(:plaintext).and_return(plaintext)
      allow(benchmark).to receive(:group).and_return(groups)
      allow(plaintext).to receive(:plaintext).and_return(ptcontent)
      allow(group).to receive(:id).and_return(controlID)
      allow(group).to receive(:title).and_return(title)
      allow(group).to receive(:description).and_return(gdescription)
      allow(group).to receive(:rule).and_return(rule)
      allow(rule).to receive(:id).and_return(rid)
      allow(rule).to receive(:check).and_return(check)
      allow(rule).to receive(:fix).and_return(fix)
      allow(rule).to receive(:fixtext).and_return(fixtext)
      allow(rule).to receive(:severity).and_return(severity)
      allow(rule).to receive(:version).and_return(version)
      allow(rule).to receive(:reference).and_return(ref_group)
      allow(rule).to receive(:title).and_return(title)
      allow(rule).to receive(:description).and_return(description)
      allow(rule).to receive(:idents).and_return(idents)
      allow(description).to receive(:details).and_return(details)
      allow(details).to receive(:vuln_discussion).and_return(vuln_discussion)
      allow(details).to receive(:false_negatives).and_return(false_negatives)
      allow(details).to receive(:false_positives).and_return(false_positives)
      allow(details).to receive(:documentable).and_return(documentable)
      allow(details).to receive(:mitigations).and_return(mitigations)
      allow(details).to receive(:severity_override_guidance).and_return(severity_override_guidance)
      allow(details).to receive(:potential_impacts).and_return(potential_impacts)
      allow(details).to receive(:third_party_tools).and_return(third_party_tools)
      allow(details).to receive(:mitigation_controls).and_return(mitigation_controls)
      allow(details).to receive(:responsibility).and_return(responsibility)
      allow(details).to receive(:ia_controls).and_return(ia_controls)
      allow(ref_group).to receive(:dc_identifier).and_return(dc_identifier)
      allow(ref_group).to receive(:dc_publisher).and_return(dc_publisher)
      allow(ref_group).to receive(:dc_source).and_return(dc_source)
      allow(ref_group).to receive(:dc_subject).and_return(dc_subject)
      allow(ref_group).to receive(:dc_title).and_return(dc_title)
      allow(ref_group).to receive(:dc_type).and_return(dc_type)
      allow(fix).to receive(:id).and_return(fid)
      allow(check).to receive(:content).and_return(content)
      allow(check).to receive(:content_ref).and_return(content_ref)
      allow(content_ref).to receive(:name).and_return(content_ref_name)
      allow(content_ref).to receive(:href).and_return(content_ref_href)
    end

    context 'when group values are set' do
      subject(:control) { get_benchmark[controlID] }
      let(:controlID) { 'controlID' }
      let(:title) { 'testTitle' }
      let(:version) { '1.0' }
      let(:ptcontent) { 'PlainText' }
      let(:gdescription) { 'This is the description of the Group/Control' }
      let(:rid) { 'ruleID' }
      let(:severity) { 'medium' }
      let(:vuln_discussion) { 'Satisfies: SRG-OS-000023-GPOS-00006, CCI-001384, CCI-001385, CCI-001386, CCI-001387, CCI-001388' }
      let(:expected_satisfies) { %w[SRG-OS-000023-GPOS-00006 CCI-001384 CCI-001385 CCI-001386 CCI-001387 CCI-001388] }
      let(:false_negatives) { 'false Negatives' }
      let(:false_positives) { 'false Positives' }
      let(:documentable) { 'documentable' }
      let(:mitigations) { 'mitigations' }
      let(:severity_override_guidance) { 'sev override' }
      let(:potential_impacts) { 'impacts' }
      let(:third_party_tools) { 'open source tools' }
      let(:mitigation_controls) { ' mitigation controls' }
      let(:responsibility) { 'who is responsibile' }
      let(:ia_controls) { 'I A Controls' }
      let(:dc_identifier) { ' d c Identifier' }
      let(:dc_publisher) { ' d c pub' }
      let(:dc_source) { ' d c src' }
      let(:dc_subject) { ' d c sub' }
      let(:dc_title) { ' d c title' }
      let(:dc_type) { ' d c type' }
      let(:idents) { %w[SRG-OS-000023-GPOS-00006 CCI-001384 CCI-001385 CCI-001386 CCI-001387 CCI-001388] }
      let(:expected_idents) { %w[CCI-001384 CCI-001385 CCI-001386 CCI-001387 CCI-001388] }
      let(:fixtext) { 'fix text' }
      let(:fid) { 'fixId' }
      let(:content) { 'check content' }
      let(:content_ref_name) { 'content ref name' }
      let(:content_ref_href) { 'content url' }

      it 'sets values' do
        expect(control[:stig_title]).to eq("#{title} :: Version #{version}, #{ptcontent}")

        expect(control[:id]).to eq(controlID)
        expect(control[:gtitle]).to eq(title)
        expect(control[:description]).to eq(gdescription)
        expect(control[:gid]).to eq(controlID)

        expect(control[:rid]).to eq(rid)
        expect(control[:severity]).to eq(severity)
        expect(control[:stig_id]).to eq(version)
        expect(control[:title]).to eq(title)

        expect(control[:satisfies]).to eq(expected_satisfies)
        expect(control[:false_negatives]).to eq(false_negatives)
        expect(control[:false_positives]).to eq(false_positives)
        expect(control[:documentable]).to eq(documentable)
        expect(control[:mitigations]).to eq(mitigations)
        expect(control[:severity_override_guidance]).to eq(severity_override_guidance)
        expect(control[:potential_impacts]).to eq(potential_impacts)
        expect(control[:third_party_tools]).to eq(third_party_tools)
        expect(control[:mitigation_controls]).to eq(mitigation_controls)
        expect(control[:responsibility]).to eq(responsibility)
        expect(control[:ia_controls]).to eq(ia_controls)

        expect(control[:dc_identifier]).to eq(dc_identifier)
        expect(control[:dc_publisher]).to eq(dc_publisher)
        expect(control[:dc_source]).to eq(dc_source)
        expect(control[:dc_subject]).to eq(dc_subject)
        expect(control[:dc_title]).to eq(dc_title)
        expect(control[:dc_type]).to eq(dc_type)

        expect(control[:cci]).to eq(expected_idents)

        expect(control[:fix]).to eq(fixtext)
        expect(control[:fix_id]).to eq(fid)

        expect(control[:check]).to eq(content)
        expect(control[:check_ref_name]).to eq(content_ref_name)
        expect(control[:check_ref]).to eq(content_ref_href)
      end
    end
  end
end
