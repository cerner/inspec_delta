# frozen_string_literal: true

require_relative 'commands/profile'

module InspecDelta
  # Public: Various commands issued for the user to interact with. These will
  # be shown when they run inspec_delta.
  class Command < Thor
    # This will cause the return value of inspec_delta to be non-zero when an execution failure occurs.
    # It is necessary to define this to suprress warning messages from Thor. They plan on making
    # the 2.0 release of Thor remove the need to define this.
    # GitHub Issue: https://github.com/erikhuda/thor/issues/244
    def self.exit_on_failure?
      true
    end

    # Contains subcommands for working with Inspec Profiles
    desc 'profile', 'Subcommands: update'
    subcommand 'profile', InspecDelta::Commands::Profile
  end
end
