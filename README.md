PinPress
========
[![Gem Version](https://badge.fury.io/rb/pinpress.svg)](http://badge.fury.io/rb/pinpress)

PinPress is a simple CLI to create templates (HTML, Markdown, or otherwise) of Pinboard pins and tags.

# Why?

Every two weeks, I create a "link mash" for my website; this link mash consists of URLs that I find interesting and want to share with my readers. Previously, I would save those interesting URLs to an Evernote note and, every two weeks, manually create my link mash for use in Wordpress. <barf/>

When I began using [Pinboard](http://pinboard.in "Pinboard") to save interesting links, I knew I needed a better method. This tool is the result: **Pin** board + Word **press**.

# Prerequisites

In addition to Git (which, given you being on this site, I'll assume you have), Ruby (v. 1.9.3 or greater) is needed.

# Installation

```
gem install pinpress
```

# Usage

Syntax and usage can be accessed by running `pinpress help`:

```
$ pinpress help
NAME
    pinpress - A Pinboard application that allows for the creation of
    "pin templates" in almost any conceivable format.

SYNOPSIS
    pinpress [global options] command [command options] [arguments...]

VERSION
    1.2.0

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

# Initialization

```
$ pinpress init
```

Initialization will prompt you to enter your Pinboard API token. Once, entered, this (and other pertinent data) will be stored in `~/.pinpress`.

# Getting Pins

```
$ pinpress pins
```

This simple command will return all pins from the user's account and output them based on the [Pin Template](#pin-templates "Pin Templates") provided.

Pinpress also provides some flags that allow a user to define specific pins to grab:

* `-s`: the start date to use (uses [Chronic](https://github.com/mojombo/chronic "Chronic"), which allows dates like "last Tuesday")
* `-e`: the end date to use (also uses [Chronic](https://github.com/mojombo/chronic "Chronic"))
* `-n`: the number of pins to return (e.g., 20)
* `-t`: a CSV list of tags (e.g., "tag1,tag2") that must exist for the returned pins

Naturally, these switches can be combined in any number of ways.

## Getting Pins From a Date Forward

```
$ pinpress pins -s 2014-01-01
```

...returns all pins from January 1, 2014 to the current day.

## Getting Pins Until a Date

```
$ pinpress pins -e 2014-01-01
```

...returns all pins up to January 1, 2014.

## Getting Pins Between a Date Range

```
$ pinpress pins -s 2014-01-01 -e 2014-01-31
```

## Getting Tagged Pins

```
$ pinpress pins -t "ruby,cli"
```

...returns all pins tagged "ruby" *and* "cli".

# Getting Tags

Pinpress can also work with tags in a Pinboard account:

```
$ pinpress tags
```

This simple command will return all tags from the user's account and output them based on the [Tag Template](https://github.com/bachya/PinPress#tag-templates "Tag Templates") provided.

Pinpress also provides some flags that allow a user to define specific tags to grab:

* `-s`: the start date to use (uses [Chronic](https://github.com/mojombo/chronic "Chronic"), which allows dates like "last Tuesday")
* `-e`: the end date to use (also uses [Chronic](https://github.com/mojombo/chronic "Chronic"))
* `-t`: a CSV list of tags (e.g., "tag1,tag2") to examine for association (see [below](#getting-tags-that-have-been-used-with-other-tags)).

## Getting Tags From a Date Forward

```
$ pinpress tags -s 2014-01-01
```

...returns all tags used from January 1, 2014 to the current day. Note that for each tag returned, the data includes both the tag name and the number of times it was used.

## Getting Tags Until a Date

```
$ pinpress tags -e 2014-01-01
```

...returns all tags used up to January 1, 2014.

## Getting Tags Between a Date Range

```
$ pinpress tags -s 2014-01-01 -e 2014-01-31
```

## Getting Tags that Have Been Used With Other Tags

```
$ pinpress tags -t 'tag1,tag2' -s 2014-01-01
```

...returns all tags that have been used *alongside* `tag1` and `tag2`, starting on Jarnuary 1, 2014.

# Templates

Templates are used to define how data should be output to the terminal and are defined in `~/.pinpress`. They come in two forms: **Pin Templates** and **Tag Templates**.

## Pin Templates

Pin Templates define how a pin from Pinboard should be output.

### Schema

Pin Templates are placed under the `pin_templates` section of the `~/.pinpress` config file -- as an example:

```YAML
pin_templates:
- name: pinpress_default
  opener: "<ul\n"
  closer: "</ul>"
  item: "<li><b><a title=\"<%= description %>\" href=\"<%= href %>\" target=\"_blank\"><%=
    description %></a>.</b> <%= extended %></li>\n"
```

A Pin Template can have several different sub-keys:

* `name` (**required**): the name of the template
* `opener` (*optional*): the text that should exist above the pins
* `closer` (*optional*): the text that should exist below the pins
* `item` (**required**): the formatted text that should be output for every pin

### Available Tokens

Additionally, a Pin Template can make use of several different tokens that are filled by a pin's values:

* `<%= href %>`: the URL of the pin
* `<%= description %>`: the description of the pin
* `<%= extended %>`: the pin's longer assocated description
* `<%= tag %>`: the CSV list of tags that apply to the pin
* `<%= time %>`: the time the pin was added to Pinboard
* `<%= replace %>`: the replacement status of the pin
* `<%= shared %>`: the privacy status of the pin
* `<%= toread %>`: the "to-read" status of the pin

### Usage

Pin Templates can be used in two ways: they can either be called dynamically:

```
$ pinpress pins template_name
```

...or a default template can be specified in `~/.pinpress`:

```
---
pinpress:
  config_location: "/Users/abach/.pinpress"
  default_pin_template: pinpress_default
  # ... other keys ...
pin_templates:
- name: pinpress_default
  opener: "<ul>\n"
  closer: "</ul>"
  item: "<li><b><a title=\"<%= description %>\" href=\"<%= href %>\" target=\"_blank\"><%=
    description %></a>.</b> <%= extended %></li>\N"
```

The default template will be used when the `pins` command is run without any arguments:

```
$ pinpress pins
```

## Tag Templates

Tag Templates are exactly like Pin Templates, but are used for tags.

### Schema

They, too, are defined in `~/.pinpress`:

```YAML
tag_templates:
- name: pinpress_default
  item: "<%= tag %> (<%= count %>),"
```

A Pin Template can have several different sub-keys:

* `name` (**required**): the name of the template
* `opener` (*optional*): the text that should exist above the tag string
* `closer` (*optional*): the text that should exist below the tag string
* `item` (**required**): the formatted text that should be output for every tag

### Available Tokens

Additionally, like a Pin Template, a Tag Template can make use of a few tokens:

* `<%= tag %>`: the name of the tag
* `<%= count %>`: the number of times the tag has been used in the range

### Usage

Pin Templates can be used in two ways: they can either be called dynamically:

```
$ pinpress tags template_name
```

...or a default template can be specified in `~/.pinpress`:

```
---
pinpress:
  config_location: "/Users/abach/.pinpress"
  default_tag_template: pinpress_default
  # ... other keys ...
pin_templates:
  # ... other keys ...
tag_templates:
- name: pinpress_default
  item: "<%= tag %> (<%= count %>),"
```

So, knowing the above, both:

```
$ pinpress tags
```

...and:

```
$ pinpress tags pinpress_default
```

...will output tag data in the format specified by that template:

```
link-mash (15),app (2),ios (3),productivity (1),launch-center-pro (1),drafts (2),
```

# Other Configuration Options

You can place special keys in the `pinpress` section of `~/.pinpress` to automate some actions:

```YAML
pinpress:
  # ...other keys...

  # The default `pins` template to use
  default_pin_template

  # The default `tags` template to use
  default_tag_template

  # The default tags to be used when getting pins or associated tags
  default_tags: ['tag1', 'tag2']

  # The tags to ignore when executing either `pins` or `tags`
  ignored_tags: ['bad-tag', 'bad-tag2']

  # The default number of results to return
  default_num_results: 5

  # ...other keys...
```

Do note:

* The `default_tags` key can be overridden by the `-t` flag.
* The `default_num_results` key can be overridden by the `-n` flag.

# Link Mash Config File

For your reference, here's my `~/.pinpress` (which is used to generate a [Link Mash on my blog](http://www.bachyaproductions.com/tag/link-mash/ "Bachya Productions Link Mash Archives")):

```YAML
---
pinpress:
  config_location: "/Users/abach/.pinpress"
  default_pin_template: pinpress_default
  default_tag_template: pinpress_default
  default_tags: ['link-mash']
  ignored_tags: ['buffer']
  log_level: WARN
  version: 1.1.1
  api_token: bachya:1234567890
pin_templates:
- name: pinpress_default
  opener: >
    <em>The weekly Link Mash is a curated selection of tools, stories, and
    other links that I found during my travels on the web. All of my curated
    links can be found on <a title="Bachya's Pinboard: Link Mash"
    href="https://pinboard.in/u:bachya/t:link-mash/" target="_blank">
    my Pinboard</a>; you can also find the Link Mash archives <a
    href="http://www.bachyaproductions.com/tag/link-mash/">here</a>.
    </em>
    <ul>
  item: >
    <li>
    <b><a title="<%= description %>" href="<%= href %>" target="_blank">
    <%= description %>
    </a>.</b> <%= extended %>
    </li>
  closer: >
    </ul>
    <hr/>
    <em>This Link Mash was generated by <a title="PinPress"
    href="https://github.com/bachya/pinpress" target="_blank">PinPress</a>,
    a simple tool to generate text templates from <a title="Pinboard"
    href="https://pinboard.in" target="_blank">Pinboard</a> data.</em>"
tag_templates:
- name: pinpress_default
  item: "<%= tag %>,"
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
