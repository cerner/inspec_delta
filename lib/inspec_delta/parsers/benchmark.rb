# frozen_string_literal: true

require 'happy_mapper_tools/stig_attributes'

module InspecDelta
  ##
  # This module represents the objects used in the InspecDelta module
  module Parser
    ##
    # This class represents a modified representation of an STIG benchmark
    # which is a collection of Inspec Controls
    class Benchmark
      # Creates a new Benchmark from a STIG file
      #
      # @param [File] file - the STIG xml file
      #
      # @return [Hash] Hash representation of the benchmark - collection of Controls
      def self.get_benchmark(file)
        benchmark = HappyMapperTools::StigAttributes::Benchmark.parse(File.read(file))
        benchmark_title = "#{benchmark.title} :: Version #{benchmark.version}, #{benchmark.plaintext&.plaintext}"

        mapped_benchmark_group = benchmark.group.map do |b| # rubocop:disable Metrics/BlockLength
          g = {}

          g[:stig_title] = benchmark_title

          g[:id] = b.id
          g[:gtitle] = b.title
          g[:description] = b.description
          g[:gid] = b.id

          rule = b.rule
          g[:rid] = rule.id
          g[:severity] = rule.severity
          g[:stig_id] = rule.version
          g[:title] = rule.title

          description = rule.description.details
          discussion = description.vuln_discussion
          g[:vuln_discussion] = discussion
          g[:false_negatives] = description.false_negatives
          g[:false_positives] = description.false_positives
          g[:documentable] = description.documentable
          g[:mitigations] = description.mitigations
          g[:severity_override_guidance] = description.severity_override_guidance
          g[:potential_impacts] = description.potential_impacts
          g[:third_party_tools] = description.third_party_tools
          g[:mitigation_controls] = description.mitigation_controls
          g[:responsibility] = description.responsibility
          g[:ia_controls] = description.ia_controls
          g[:desc] = discussion.split('Satisfies: ')[0].strip
          if discussion.split('Satisfies: ').length > 1
            g[:satisfies] = discussion.split('Satisfies: ')[1].split(',').map(&:strip)
          end

          reference_group = rule.reference
          g[:dc_identifier] = reference_group.dc_identifier
          g[:dc_publisher] = reference_group.dc_publisher
          g[:dc_source] = reference_group.dc_source
          g[:dc_subject] = reference_group.dc_subject
          g[:dc_title] = reference_group.dc_title
          g[:dc_type] = reference_group.dc_type

          g[:cci] = rule.idents.select { |t| t.start_with?('CCI-') } # XCCDFReader

          g[:fix] = rule.fixtext
          g[:fix_id] = rule.fix.id

          g[:check] = rule.check.content
          g[:check_ref_name] = rule.check.content_ref.name
          g[:check_ref] = rule.check.content_ref.href
          [b.id, g]
        end
        mapped_benchmark_group.to_h
      end
    end
  end
end
