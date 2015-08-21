# linter-puppet-parser

This package will lint your `.pp` opened files in Atom through [puppet parser validate](https://puppetlabs.com/blog/verifying-puppet-checking-syntax-and-writing-automated-tests).

## Installation

* Install [puppet](https://puppetlabs.com/puppet/puppet-open-source)
* `$ apm install linter` (if you don't have [linter](https://github.com/AtomLinter/Linter) yet installed)
* `$ apm install linter-puppet-parser`

## Settings
You can configure linter-puppet-parser by editing your ~/.atom/config.cson (on Linux). You can do this from Atom itself by choosing Open Your Config in Atom Edit menu. All the settings are optional and have reasonable defaults.
```
'linter-puppet-parser':
  # eg. --parser future
  # default: --disable_warnings=deprecations
  'puppetArguments': '--parser future'
  # eg '/usr/bin/puppet'
  # default: puppet
  'puppetExecutablePath': '/usr/bin/puppet'
```
