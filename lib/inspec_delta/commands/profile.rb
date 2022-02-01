# frozen_string_literal: true

module InspecDelta
  module Commands
    # This class will take care of operations related to profile manipulation
    class Profile < Thor
      desc 'update', 'Update profile from STIG file'
      method_option :profile_path,
                    aliases: %w[-p --pr],
                    desc: 'The path to the directory that contains the profile to modify.',
                    required: true
      method_option :stig_file_path,
                    aliases: %w[-s --st],
                    desc: 'The path to the stig file to apply to the profile.',
                    required: true
      method_option :rule_id,
                    aliases: '-r',
                    desc: 'Sets inspec_delta to use STIG Rule IDs (SV-XXXXXX) as the primary key for comparison between the benchmark and the profile. Set to false to use the Vuln ID (V-XXXXXX) as the comparator.',
                    type: :boolean,
                    default: true

      def update
        prof = InspecDelta::Object::Profile.new(options[:profile_path])
        prof.update(options[:stig_file_path], options[:rule_id])
        prof.format
      end

      desc 'update_id', 'Relabel the controls in the profile with the updated IDs from the benchmark. Run this first if the profile uses the old-stlye V-XXXXXX IDs and you want to rename the files with the right IDs in a separate commit.'
      method_option :profile_path,
                    aliases: %w[-p --pr],
                    desc: 'The path to the directory that contains the profile to modify.',
                    required: true
      method_option :stig_file_path,
                    aliases: %w[-s --st],
                    desc: 'The path to the stig file to apply to the profile.',
                    required: true
      def update_id
        prof = InspecDelta::Object::Profile.new(options[:profile_path])
        prof.update_id(options[:stig_file_path])
        prof.format
      end
    end
  end
end
