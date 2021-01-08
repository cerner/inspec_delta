# Inspec Delta

This Gem aims to make the maintenance of Inspec profiles representing security benchmarks less of a burden by providing helpful command line tools.

For information on STIGs visit the [DoD Cyber Exchange](https://public.cyber.mil/stigs/).

For stig definition files visit the [DoD Cyber Exchange Document Library](https://public.cyber.mil/stigs/downloads/).

## Commands

### inspec_delta help
  - This will list all the commands along with their descriptions.

### inspec_delta profile update
  This command updates an existing Inspec profile for a STIG with the metadata from a new revision to that STIG. 
  It reads through the XCCDF XML file from the new revision and updates the existing profile's controls as needed.

  #### Usage
  > inspec_delta profile update -p /path/to/profile -s /path/to/stig.xml

  #### Options
  ```ruby

      -p, --pr, [--profile_path=PROFILE_PATH]    # Specified path to the root directory of the existing Inspec profile.
      -s, --st, [--stig_file_path=STIG_PATH]     # Specified path to the XCCDF XML file from the new STIG revision we are updating to.
  ```