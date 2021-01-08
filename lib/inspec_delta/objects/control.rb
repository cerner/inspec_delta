# frozen_string_literal: true

require 'facets/string'
require 'inspec-objects'
require 'ruby_parser'
require 'ruby2ruby'

module InspecDelta
  ##
  # This module represents the objects used in the InspecDelta module
  module Object
    ##
    # This class represents a modified representation of an Inspec Control
    class Control < Inspec::Object::Control
      MAX_LINE_LENGTH = 120
      WORD_WRAP_INDENT = 4

      attr_accessor :global_code, :control_code
      attr_reader :control_string

      ##
      # Creates a new Control based on the Inspec Object Control definition
      def initialize
        super

        @global_code = []
        @control_code = []
        @control_string = ''
      end

      # Updates a string representation of a Control with string substitutions
      #
      # @param [Control] other - The Control to be merged in
      #
      # @return [control_string] String updated string with the changes from other
      def apply_updates(other)
        apply_updates_title(other.title)
        apply_updates_desc(other.descriptions[:default])
        apply_updates_impact(other.impact)
        apply_updates_tags(other)
        @control_string
      end

      # Updates a string representation of a Control's title with string substitutions
      #
      # @param [String] title - The title to be applied to the Control
      def apply_updates_title(title)
        return if title.to_s.empty?

        wrap_length = MAX_LINE_LENGTH - WORD_WRAP_INDENT

        @control_string.sub!(
          /title\s+(((").*?(?<!\\)")|((').*?(?<!\\)')|((%q{).*?(?<!\\)[}])|(nil))\n/m,
          "title %q{#{title}}".word_wrap(wrap_length).indent(WORD_WRAP_INDENT)
        )
      end

      # Updates a string representation of a Control's description with string substitutions
      #
      # @param [Control] desc - The description to be applied to the Control
      def apply_updates_desc(desc)
        return if desc.to_s.empty?

        wrap_length = MAX_LINE_LENGTH - WORD_WRAP_INDENT

        @control_string.sub!(
          /desc\s+(((").*?(?<!\\)")|((').*?(?<!\\)')|((%q{).*?(?<!\\)[}])|(nil))\n/m,
          "desc %q{#{desc}}".word_wrap(wrap_length).indent(WORD_WRAP_INDENT)
        )
      end

      # Updates a string representation of a Control's impact with string substitutions
      #
      # @param [Decimal] impact - The impact to be applied to the Control
      def apply_updates_impact(impact)
        return if impact.nil?

        @control_string.sub!(/impact\s+\d\.\d/, "impact #{impact}")
      end

      # Updates a string representation of a Control's tags with string substitutions
      #
      # @param [Control] other - The Control to be merged in
      def apply_updates_tags(other)
        other.tags.each do |ot|
          tag = @tags.detect { |t| t.key == ot.key }
          next unless tag

          if ot.value.instance_of?(String)
            apply_updates_tags_string(ot)
          elsif ot.value.instance_of?(Array)
            apply_updates_tags_array(ot)
          elsif ot.value.instance_of?(FalseClass) || ot.value.instance_of?(TrueClass)
            apply_updates_tags_bool(ot)
          end
        end
      end

      # Updates a string representation of a Control's tags with string substitutions
      #
      # @param [Tag] ot - The Tag to be merged in
      def apply_updates_tags_string(tag)
        if tag.value.empty?
          @control_string.sub!(
            /tag\s+['"]?#{tag.key}['"]?:\s+(((").*?(?<!\\)")|((').*?(?<!\\)')|((%q{).*?(?<!\\)[}])|(nil))\n/m,
            "tag '#{tag.key}': nil\n"
          )
        else
          wrap_length = MAX_LINE_LENGTH - WORD_WRAP_INDENT

          @control_string.sub!(
            /tag\s+['"]?#{tag.key}['"]?:\s+(((").*?(?<!\\)")|((').*?(?<!\\)')|((%q{).*?(?<!\\)[}])|(nil))\n/m,
            "tag '#{tag.key}': %q{#{tag.value}}".word_wrap(wrap_length).indent(WORD_WRAP_INDENT)
          )
        end
      end

      # Updates a string representation of a Control's tags with string substitutions
      #
      # @param [Tag] ot - The Tag to be merged in
      def apply_updates_tags_array(tag)
        wrap_length = MAX_LINE_LENGTH - WORD_WRAP_INDENT

        @control_string.sub!(
          /tag\s+['"]?#{tag.key}['"]?:\s+(((%w\().*?(?<!\\)(\)))|((\[).*?(?<!\\)(\]))|(nil))\n/m,
          "tag '#{tag.key}': #{tag.value}".word_wrap(wrap_length).indent(WORD_WRAP_INDENT)
        )
      end

      # Updates a string representation of a Control's tags with string substitutions
      #
      # @param [Tag] ot - The Tag to be merged in
      def apply_updates_tags_bool(tag)
        @control_string.sub!(
          /tag\s+['"]?#{tag.key}['"]?:\s+(true|false|'')\n/,
          "tag '#{tag.key}': #{tag.value}\n"
        )
      end

      # Hash of tags we want to read from the benchmark
      #
      # @return [hash] benchmark_tags
      def self.benchmark_tags
        {
          'severity' => :severity,
          'gtitle' => :gtitle,
          'satisfies' => :satisfies,
          'gid' => :gid,
          'rid' => :rid,
          'stig_id' => :stig_id,
          'fix_id' => :fix_id,
          'cci' => :cci,
          'false_negatives' => :false_negatives,
          'false_positives' => :false_positives,
          'documentable' => :documentable,
          'mitigations' => :mitigations,
          'severity_override_guidance' => :severity_override_guidance,
          'potential_impacts' => :potential_impacts,
          'third_party_tools' => :third_party_tools,
          'mitigation_controls' => :mitigation_controls,
          'responsibility' => :responsibility,
          'ia_controls' => :ia_controls,
          'check' => :check,
          'fix' => :fix
        }
      end

      # Creates a new Control from a benchmark hash definition
      #
      # @param [Hash] benchmark - Hash representation of a benchmark
      #
      # @return [Control] Control representation of the benchmark
      def self.from_benchmark(benchmark)
        control = new
        control.descriptions[:default] = benchmark[:desc]
        control.id     = benchmark[:id]
        control.title  = benchmark[:title]
        control.impact = impact(benchmark[:severity])
        benchmark_tags.each do |tag, benchmark_key|
          control.add_tag(Inspec::Object::Tag.new(tag, benchmark[benchmark_key]))
        end
        control
      end

      # Creates a new Control from a ruby definition
      #
      # @param [String] ruby_control_path - path to the ruby file that contains the control
      #
      # @return [Control] Control parsed from file
      def self.from_ruby(ruby_control_path)
        control = new
        control_file_string = File.read(File.expand_path(ruby_control_path))
        send(:parse_ruby, control, RubyParser.new.parse(control_file_string))
        control.instance_variable_set(:@control_string, control_file_string)
        control
      end

      # Converts the string severity into a decimal representation
      #
      # @param [String] severity - string representation of the severity
      #
      # @return [decimal] numerical representation of the severity if match is found
      # @return [string] severity if no match is found
      def self.impact(severity)
        {
          'low' => 0.3,
          'medium' => 0.5,
          'high' => 0.7
        }.fetch(severity) { severity }
      end

      # Merges another controll into self
      #
      # Currently we are only mergings objects from the base Inspec::Objects::Control
      # as that is what will be used for updated STIG merges
      # id is not updated as that should be the unique identifier
      #
      # @param [Control] other - another control to take values from.
      #
      # @return [Control] self - updated with values from other control
      def merge_from(other)
        @title = other.title unless other.title.to_s.empty?
        @descriptions[:default] = other.descriptions[:default] unless other.descriptions[:default].to_s.empty?
        @impact = other.impact unless other.impact.nil?
        other.tags.each do |ot|
          tag = @tags.detect { |t| t.key == ot.key }
          tag ? tag.value = ot.value : @tags.push(ot)
        end
        self
      end

      # Takes an Sexp that is an S-exp representation of a ruby control, and parse it into a control
      #
      # @param [Control] control - A Control that we want to load the ruby Sexp into
      # @param [Sexp] ruby_object - An Sexp representation of a ruby object
      # <syntax>:
      # s(:iter,
      #   s(:call, nil, :control, s(:str, <controlId>)),
      #   s(:block,
      #     s(:call, nil, :title, s(:str, <title>)),
      #     s(:call, nil, :desc, s(:str, <desc>)),
      #     s(:call, nil, :impact, s(:lit, <impact>)),
      #     [<tag>,<RubyCode>](see <Tag> definition)
      #     ))
      #
      # <Tag>:
      # s(:call, nil, :tag,
      #   s(:hash,
      #     s(:lit, :gtitle),
      #       <string> || <array_of_strings> || <comment_hash>))
      # <string>:
      #   s(:str, 'str1')
      # <array_of_strings>:
      #   s(:array,
      #     s(:str, 'str1'),
      #     s(:str, 'str2')
      # <comment_hash>
      #   s(:hash,
      #     s(:lit, :"Regular Expression Usage"),
      #     s(:str, "RegEx Definition"))
      #
      # @return [Control] control - A Control that has been filled from the ruby_object
      private_class_method def self.parse_base_control(control, ruby_object)
        case ruby_object[0]
        when :call
          send(:parse_base_control_call, control, ruby_object)
        when :block
          ruby_object.each { |x| send(:parse_base_control, control, x) }
        when :iter
          if ruby_object[1][2] == :control
            control.id = ruby_object[1][3][1]
            send(:parse_base_control, control, ruby_object[3])
          else
            control.control_code.push(Ruby2Ruby.new.process(ruby_object.deep_clone))
          end
        else
          control.control_code.push(Ruby2Ruby.new.process(ruby_object.deep_clone)) if ruby_object.instance_of?(Sexp)
        end
        control
      end

      # Takes an Sexp that is an S-exp representation of a ruby control with a type of call, and parse it into a control
      #
      # @param [Control] control - A Control that we want to load the ruby Sexp into
      # @param [Sexp] ruby_object - An Sexp representation of a ruby object with a call type
      # <syntax> (multiple examples):
      # s(:call, nil, :control, s(:str, <title>))
      # s(:call, nil, :title, s(:str, <title>))
      # s(:call, nil, :desc, s(:str, <desc>))
      # s(:call, nil, :impact, s(:lit, <impact>))
      # <tag> (see <Tag> parameter)
      # <RubyCode>
      #
      # <Tag>:
      # s(:call, nil, :tag,
      #   s(:hash,
      #     s(:lit, :gtitle),
      #       <string> || <array_of_strings> || <comment_hash>))
      # <string>:
      #   s(:str, 'str1')
      # <array_of_strings>:
      #   s(:array,
      #     s(:str, 'str1'),
      #     s(:str, 'str2')
      # <comment_hash>
      #   s(:hash,
      #     s(:lit, :"Regular Expression Usage"),
      #     s(:str, "RegEx Definition"))
      #
      # @return [Control] control - A Control that has been filled from the ruby_object
      private_class_method def self.parse_base_control_call(control, ruby_object)
        case ruby_object[2]
        when :control
          control.id = ruby_object[3][1]
        when :title
          control.title = ruby_object[3][1]
        when :desc
          control.descriptions[:default] = ruby_object[3][1]
        when :impact
          control.impact = ruby_object[3][1]
        when :tag
          control.add_tag(
            Inspec::Object::Tag.new(ruby_object[3][1][1].to_s, Ruby2Ruby.new.process(ruby_object[3][2].deep_clone))
          )
        else
          control.control_code.push(Ruby2Ruby.new.process(ruby_object.deep_clone))
        end
        control
      end

      # Takes an Sexp that is an S-exp representation of a customized ruby control, and parse it into a control
      #
      # @param [Control] control - A Control that we want to load the ruby Sexp into
      # @param [Sexp] ruby_object - An Sexp representation of a ruby object
      # <syntax>:
      # s(:block,
      #   s([<RubyCode>[0-9],<Control>,<RubyCode>[0-9]]))
      #
      # @return [Control] control - A Control that has been filled from the ruby_object
      private_class_method def self.parse_ruby(control, ruby_object)
        case ruby_object[0]
        when :call
          control.global_code.push(Ruby2Ruby.new.process(ruby_object.deep_clone))
        when :block
          ruby_object.each { |x| send(:parse_ruby, control, x) }
        when :iter
          case ruby_object[1][2]
          when :control
            send(:parse_base_control, control, ruby_object)
          else
            control.global_code.push(Ruby2Ruby.new.process(ruby_object.deep_clone))
          end
        else
          # Anything that doesn't fall into the other scenarios is pure ruby code that falls outside of the control
          # we want to add this code to the global code to be preserved as code.
          control.global_code.push(Ruby2Ruby.new.process(ruby_object.deep_clone)) if ruby_object.instance_of?(Sexp)
        end
        control
      end

      # Converts the Control object into a string representation of a Ruby Object
      #
      # unable to use the super function as it is already converted to a string
      #
      # @return [string] the control as a ruby string
      def to_ruby
        res = []
        res.push global_code unless global_code.empty?
        res.push "control #{id.inspect} do"
        res.push "  title #{title.inspect}" unless title.to_s.empty?
        res.push "  desc  #{descriptions[:default].inspect}" unless descriptions[:default].to_s.empty?
        res.push "  impact #{impact}" unless impact.nil?
        tags.each do |t|
          res.push("  #{t.to_ruby}")
        end
        res.push control_code unless control_code.empty?
        res.push 'end'
        res.join("\n")
      end
    end
  end
end
