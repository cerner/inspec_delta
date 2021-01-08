# Contributing

Help us to make this project better by contributing. Whether it's new features, bug fixes, or simply improving documentation, your contributions are welcome. Please start with logging a [github issue][1] or submit a pull request.

Before you contribute, please review these guidelines to help ensure a smooth process for everyone.

Thanks.

## Issue Reporting

* Please browse our [existing issues][1] before logging new issues.
* Check that the issue has not already been fixed in the `master` branch.
* Open an issue with a descriptive title and a summary.
* Please be as clear and explicit as you can in your description of the problem.
* Please state the version of {technical dependencies} and `inspec_delta` you are using in the description.
* Include any relevant code in the issue summary.

## Pull Requests

* Read [how to properly contribute to open source projects on Github][2].
* Fork the project.
* Use a feature branch.
* Write [good commit messages][3].
* Use the same coding conventions as the rest of the project.
* Commit locally and push to your fork until you are happy with your contribution.
* Make sure to add tests and verify all the tests are passing when merging upstream.
* Add an entry to the [Changelog][4] accordingly.
* Please add your name to the [CONTRIBUTORS.md][8] file. Adding your name to the [CONTRIBUTORS.md][8] file signifies agreement to all rights and reservations provided by the [License][5].
* [Squash related commits together][6].
* Open a [pull request][7].
* The pull request will be reviewed by the community and merged by the project committers.

[1]: https://github.com/cerner/inspec_delta/issues
[2]: http://gun.io/blog/how-to-github-fork-branch-and-pull-request
[3]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[4]: ./CHANGELOG.md
[5]: ./LICENSE
[6]: http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html
[7]: https://help.github.com/articles/using-pull-requests
[8]: ./CONTRIBUTORS.md

## Dependencies

- Gems:
  - [facets] (https://github.com/rubyworks/facets)
  - [inspec-objects] (https://github.com/inspec/inspec-objects)
  - [inspec-tools] (https://github.com/mitre/inspec_tools)
  - [rubocop](https://github.com/bbatsov/rubocop)
  - [ruby2ruby] (https://github.com/seattlerb/ruby2ruby)
  - [ruby_parser] (https://github.com/seattlerb/ruby_parser)
  - [thor](http://whatisthor.com/)


## Installation (Window Platform)
For development and testing in window, please follow below steps after installation,

  1. Download rubyinstaller and DevKit from this link [rubyinstaller](http://rubyinstaller.org/downloads/). Please make sure you download appropriate versions for your operating system.
  2. Follow below commands

  ```terminal
    Extract DevKit to path C:{ruby-installation-folder}\DevKit
    > cd C:{ruby-installation-folder}\DevKit

    > ruby dk.rb init

    > ruby dk.rb review

    > ruby dk.rb install

    > gem install json --platform=ruby
  ```

## Development and Testing
  After performing installation(ruby) steps described on [readme](README.md), perform below steps for development.

### Linux & Window
```terminal
  > bundle exec rspec   # Generates  directory "coverage" with unit test report

  > rake rubocop    # Generates directory "lint_report"

  > gem build inspec_delta.gemspec   # Builds the gem for project

  > gem install inspec_delta(-version).gem    # Installs inspec_delta gem on computer.

  > inspec_delta    # Runs gem
```