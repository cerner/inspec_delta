# frozen_string_literal: true

module InspecDelta
  ##
  # This module represents the objects used in the InspecDelta module
  module Object
    # This class will take care of operations related to profile manipulation
    class Profile
      # Internal: Initializes the Profile object upon instantiation
      #
      # profile_path: String, path to the inspec profile's root directory.
      # _options: Unused, contains extraneous parameters that may be passed to the initializer
      #
      # Returns: Nothing
      def initialize(profile_path)
        @profile_path = profile_path
        raise StandardError, "Profile directory at #{@profile_path} not found" unless Dir.exist?(@profile_path)
      end

      # Formats a the ruby controls using rubocop with the rubo config file in the profile
      #
      def format
        control_dir = File.join(File.expand_path(@profile_path), 'controls')
        rubo_file = File.join(File.expand_path(@profile_path), '.rubocop.yml')
        raise StandardError, "Rubocop configuration file at #{rubo_file} not found" unless File.exist?(rubo_file)

        `rubocop -a #{control_dir} -c #{rubo_file}`
      end

      # Updates a profile metadata with definitions from a STIG xml file
      #
      # @param [profile_path] String - path to the inspec profile's root directory.
      # @param [stig_file_path] String - The STIG file to be applied to profile.
      def update(stig_file_path, rule_id)
        raise StandardError, "STIG file at #{stig_file_path} not found" unless File.exist?(stig_file_path)
        control_dir = "#{@profile_path}/controls"
        benchmark = InspecDelta::Parser::Benchmark.get_benchmark(stig_file_path)
        benchmark.each do |control_id, control|
          benchmark_control = InspecDelta::Object::Control.from_benchmark(control)
          control_filename = (rule_id || control[:legacy].nil? || control[:legacy].empty?) ? "#{control_id}.rb" : 
            "#{control[:legacy].select{ |x| x.start_with? ('V-') }.first}.rb"
          profile_control_path = File.join(File.expand_path(control_dir), control_filename)
          if File.file?(profile_control_path)
            update_existing_control_file(profile_control_path, benchmark_control)
          else
            create_new_control_file(profile_control_path, benchmark_control)
          end
        end
      end

      # Updates ONLY the filenames of the profile's controls metadata with definitions from a STIG xml file
      #
      # @param [profile_path] String - path to the inspec profile's root directory.
      # @param [stig_file_path] String - The STIG file to be applied to profile.
      def update_id(stig_file_path)
        raise StandardError, "STIG file at #{stig_file_path} not found" unless File.exist?(stig_file_path)
          control_dir = "#{@profile_path}/controls"
          benchmark = InspecDelta::Parser::Benchmark.get_benchmark(stig_file_path)
          benchmark.each do |control_id, control| unless control[:legacy].nil? || control[:legacy].empty?
            benchmark_control = InspecDelta::Object::Control.from_benchmark(control)
            control_filename = "#{control[:legacy].select{ |x| x.start_with? ('V-') }.first}.rb"
            profile_control_path = File.join(File.expand_path(control_dir), control_filename)
            #require 'pry'; binding.pry
            if File.file?(profile_control_path)
              puts "Updating \"#{control_filename}\" ==> \"#{control[:id]}.rb\""
              updated_path = profile_control_path.sub(
                /[^\/\\]+.rb/,
                control[:id] + '.rb'
              )
              system("cd #{@profile_path} && git mv #{profile_control_path} #{updated_path}")
              #require 'pry'; binding.pry
            end
          end
        end
        puts "Done updating."
      end


      # Updates a control file with the updates from the stig
      #
      # @param [profile_control_path] String - The location of the Inspec profile on disk
      # @param [benchmark_control] Control - Control built from the Inspec Benchmark
      def update_existing_control_file(profile_control_path, benchmark_control)
        profile_control = InspecDelta::Object::Control.from_ruby(profile_control_path)
        updated_control = profile_control.apply_updates(benchmark_control)
        updated_path = profile_control_path.sub(
          /[^\/\\]+.rb/,
          updated_control[:id] + '.rb'
        )
        if updated_path != profile_control_path
          #require 'pry'; binding.pry
          system("cd #{@profile_path} && git mv #{profile_control_path} #{updated_path}")
          profile_control_path = updated_path
        end
        File.open(profile_control_path, 'w') { |f| f.puts updated_control[:control_string] }
      end

      # Creates a control file with the string representation of the benchmark control
      #
      # @param [profile_control_path] String - The location of the Inspec profile on disk
      # @param [benchmark_control] Control - Control built from the Inspec Benchmark
      def create_new_control_file(profile_control_path, benchmark_control)
        File.open(profile_control_path, 'w') { |f| f.puts benchmark_control.to_ruby }
      end
    end
  end
end
