PinPress
========
[![Build Status](https://travis-ci.org/bachya/PinPress.svg?branch=master)](https://travis-ci.org/bachya/PinPress)
[![Gem Version](https://badge.fury.io/rb/pinpress.svg)](http://badge.fury.io/rb/sifttter-redux)

PinPress is a simple CLI to create templates (HTML, Markdown, or otherwise) of Pinboard pins and tags.

# Why?

Every two weeks, I create a "link mash" for my website; this link mash consists of URLs that I find interesting and want to share with my readers. Previously, I would save those interesting URLs to an Evernote note and, every two weeks, manually create my link mash. <barf/>

When I began using [Pinboard](http://pinboard.in "Pinboard") to save interesting links, I knew I needed a better method. This tool is the result.

# Prerequisites

In addition to Git (which, given you being on this site, I'll assume you have), Ruby (v. 1.9.3 or greater) is needed.

# Installation

```
gem install sifttter-redux
```

# Usage

Syntax and usage can be accessed by running `srd help`:

```
$ pinpress help
NAME
    pinpress - A Pinboard application that allows for the creation of "pin templates" in almost any conceivable format.

SYNOPSIS
    pinpress [global options] command [command options] [arguments...]

VERSION
    1.0.0

GLOBAL OPTIONS
    --help    - Show this message
    --version - Display the program version

COMMANDS
    help      - Shows a list of commands or help for one command
    init      - Install and initialize dependencies
    pins      - Get posts from Pinboard
    tags      - Get tags from Pinboard
    templates - Work with templates for pin output
```

Note that each command's options can be revealed by adding the `--help` switch after the command. For example:

```
$ pinpress pins --help
NAME
    pins - Get posts from Pinboard

SYNOPSIS
    pinpress [global options] pins [command options]

COMMAND OPTIONS
    -e arg - The end date to pull pins to (default: none)
    -n arg - The number of results to return (default: none)
    -s arg - The start date to pull pins from (default: none)
    -t arg - The tags to use (e.g., "ruby,pinboard") (default: none)
```

## Initialization

```
$ pinpress init
```

Initialization will prompt you to enter your Pinboard API token. Once, entered, this (and other pertinent data) will be stored in `~/.pinpress`.

## Templates

The first stop on the PinPress journey is templates. Templates are used to define how data should be output and are defined in `~/.pinpress` and come in two forms: **Pin Templates** and **Tag Templates**. 

### Pin Templates

Pin Templates are placed under the `pin_templates` section of the `~/.pinpress` config file -- as an example:

```YAML
pin_templates:
- name: pinpress_default
  opener: "<ul>"
  item: "<li><b><a title=\"<%= description %>\" href=\"<%= href %>\" target=\"_blank\"><%=
    description %></a>.</b> <%= extended %></li>"
  item_separator: "\n"
  closer: "</ul>"
```

# Known Issues & Future Releases

Check out the Pinpress roadmap via the [Trello Board](https://trello.com/b/lmuC8TT0/pinpress "Pinpress Trello Board").

Bugs, issues, and enhancement requests can be submitted on the [Issues Page](https://github.com/bachya/Pinpress/issues "Open Items").

# Bugs and Feature Requests

To report bugs with or suggest features/changes for Sifttter Redux, please use the [Issues Page](http://github.com/bachya/PinPress/issues).

Contributions are welcome and encouraged. To contribute:

* [Fork Sifttter Redux](http://github.com/bachya/PinPress/fork).
* Create a branch for your contribution (`git checkout -b new-feature`).
* Commit your changes (`git commit -am 'Added this new feature'`).
* Push to the branch (`git push origin new-feature`).
* Create a new [Pull Request](http://github.com/bachya/PinPress/compare/).

# License

(The MIT License)

Copyright © 2014 Aaron Bach <bachya1208@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.