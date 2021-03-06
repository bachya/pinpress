PinPress
========
[![Build Status](https://travis-ci.org/bachya/pinpress.svg?branch=master)](https://travis-ci.org/bachya/pinpress)
[![Gem Version](https://badge.fury.io/rb/pinpress.svg)](http://badge.fury.io/rb/pinpress)

PinPress is a simple CLI to create templates (HTML, Markdown, or otherwise) of
Pinboard pins and tags.

# Why?

Every week, I create a [link mash for my blog](#link-mash-config-file); this
link mash consists of URLs that I find interesting and want to share with my
readers. Previously, I would save those interesting URLs to an Evernote note
and, every week, manually create my link mash for use in Wordpress. `<barf/>`

When I began using [Pinboard](http://pinboard.in "Pinboard") to save
interesting links, I knew I needed a better method. This tool is the result:
**Pin** board + Word **press**.

# Prerequisites

In addition to Git (which, given you being on this site, I'll assume you have),
Ruby (v. 1.9.3 or greater) is needed.

# Installation

```bash
gem install pinpress
```

# Usage

Syntax and usage can be accessed by running `pinpress help`:

```bash
$ pinpress help
NAME
    pinpress - A Pinboard application that allows for the creation of
    "pin templates" in almost any conceivable format.

SYNOPSIS
    pinpress [global options] command [command options] [arguments...]

VERSION
    1.6.3

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

Note that each command's options can be revealed by adding the `--help` switch
after the command. For example:

```bash
$ pinpress pins --help
NAME
    pins - Get posts from Pinboard

SYNOPSIS
    pinpress [global options] pins [command options]

COMMAND OPTIONS
    -a     - Auto-links any URLs found in a pin description
    -c     - Copy final output to the system clipboard
    -e arg - The end date to pull pins to (default: none)
    l      - Allows the user to create <a> links around detected URLs
    -m arg - The pin template to use (default: none)
    -n arg - The number of results to return (default: none)
    -s arg - The start date to pull pins from (default: none)
    -t arg - The tags to use (e.g., "ruby,pinboard") (default: none)

COMMANDS
    <default> -
    last      - Gets all pins from the last run date + 1
```

# Initialization

```bash
$ pinpress init
```

Initialization will prompt you to enter your Pinboard API token. Once, entered,
this (and other pertinent data) will be stored in `~/.pinpress`.

# Getting Pins

```bash
$ pinpress pins
```

This simple command will return all pins from the user's account and output them
based on the [Pin Template](#pin-templates "Pin Templates") provided.

Pinpress also provides some flags that allow a user to define specific pins to
grab:

* `-s`: the start date to use (uses [Chronic](https://github.com/mojombo/chronic "Chronic"), which allows dates like "last Tuesday")
* `-e`: the end date to use (also uses [Chronic](https://github.com/mojombo/chronic "Chronic"))
* `-m`: the PinPress template to use
* `-n`: the number of pins to return (e.g., 20)
* `-t`: a CSV list of tags (e.g., "tag1,tag2") that must exist for the returned pins

## Output

By default, pin template text will be output to the terminal; you can use the
`-c` switch to output it to the system clipboard instead. This flag makes use
of the [clippy](https://github.com/envygeeks/clippy) gem, which
allows for cross-platform system clipboard access. Make sure you read its
[README](https://github.com/envygeeks/clippy/blob/master/Readme.md).

## Getting Pins From a Date Forward

```bash
$ pinpress pins -s 2014-01-01
```

...returns all pins from January 1, 2014 to the current day.

## Getting Pins Until a Date

```bash
$ pinpress pins -e 2014-01-01
```

...returns all pins up to January 1, 2014.

## Getting Pins Between a Date Range

```bash
$ pinpress pins -s 2014-01-01 -e 2014-01-31
```

## Getting Tagged Pins

```bash
$ pinpress pins -t "ruby,cli"
```

...returns all pins tagged "ruby" *and* "cli".

**Naturally, these flags can be combined in any number of ways.**

## Getting Pins Created Since Last Run

```bash
$ pinpress pins last
```

...will get all the pins created since you last ran that command (e.g., if you'd
last run `pinpress pins` on 2014-01-01, this command would return all pins
created from 2014-01-02 onward).

# Getting Tags

Pinpress can also work with tags in a Pinboard account:

```bash
$ pinpress tags
```

This simple command will return all tags from the user's account and output them
based on the [Tag Template](#tag-templates "Tag Templates") provided.

Pinpress also provides some flags that allow a user to define specific tags to
grab:

* `-m`: the PinPress template to use
* `-s`: the start date to use (uses [Chronic](https://github.com/mojombo/chronic "Chronic"), which allows dates like "last Tuesday")
* `-e`: the end date to use (also uses [Chronic](https://github.com/mojombo/chronic "Chronic"))

## Output

By default, pin template text will be output to the terminal; you can use the
`-c` switch to output it to the system clipboard instead. This flag makes use
of the [clippy](https://github.com/envygeeks/clippy) gem, which
allows for cross-platform system clipboard access. Make sure you read its
[README](https://github.com/envygeeks/clippy/blob/master/Readme.md).

## Getting Tags From a Date Forward

```bash
$ pinpress tags -s 2014-01-01
```

...returns all tags used from January 1, 2014 to the current day. Note that for
each tag returned, the data includes both the tag name and the number of times
it was used.

## Getting Tags Until a Date

```bash
$ pinpress tags -e 2014-01-01
```

...returns all tags used up to January 1, 2014.

## Getting Tags Between a Date Range

```bash
$ pinpress tags -s 2014-01-01 -e 2014-01-31
```

## Getting Tags Used Since Last Run

```bash
$ pinpress tags last
```

...will get all the tags used since you last ran the command (e.g., if you'd
last run `pinpress tags` on 2014-01-01, this command would return all tags used
from 2014-01-02 onward).

# Templates

Templates are used to define how data should be output to the terminal and are
defined in `~/.pinpress`. They come in two forms: **Pin Templates** and **Tag
Templates**.

## Pin Templates

Pin Templates define how a pin from Pinboard should be output.

### Schema

Pin Templates are placed under the `pin_templates` section of the `~/.pinpress`
config file -- as an example:

```yaml
pin_templates:
- pinpress_default:
    opener: "<ul>\n"
    item: >
      <li>
      <b><a title="<%= description %>" href="<%= href %>" target="_blank">
      <%= description %></a>.</b>
      <%= extended %>
      </li>
    closer: "</ul>"
# ... other templates ...
```

A Pin Template can have several different sub-keys:

* `opener` (*optional*): the text that should exist above the pins
* `closer` (*optional*): the text that should exist below the pins
* `item` (**required**): the formatted text that should be output for every pin

### Available Tokens

Additionally, a Pin Template can make use of several different tokens that are
filled by a pin's values:

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

```bash
$ pinpress pins -m template_name
```

...or a default template can be specified in `~/.pinpress`:

```yaml
---
pinpress:
  config_location: "/Users/abach/.pinpress"
  default_pin_template: pinpress_default
  # ... other keys ...
pin_templates:
- pinpress_default:
    opener: "<ul>\n"
    item: >
      <li>
      <b><a title="<%= description %>" href="<%= href %>" target="_blank">
      <%= description %></a>.</b>
      <%= extended %>
      </li>
    closer: "</ul>"
# ... other templates ...
```

So, knowing the above, both:

```bash
$ pinpress pins
```

...and:

```bash
$ pinpress pins -m pinpress_default
```

...will output pin data in the format specified by that template:

```html
<ul>
  <li>
    <b>
      <a href="http://www.macstories.net/tutorials/launch-center-pro-guide/">
        Automating iOS: A Comprehensive Guide to Launch Center Pro
      </a>.
    </b>
    This the most amazing article I've seen in a long time. So many tips, tricks,
    and automations to make productivity easier.
  </li>
  <!-- ... -->
</ul>
```

(Note that the nice indenting is for Github's sake; the actual output will
conform to the formatting in `~/.pinpress`.)

## Tag Templates

Tag Templates are exactly like Pin Templates, but are used for tags.

### Schema

They, too, are defined in `~/.pinpress`:

```yaml
tag_templates:
- pinpress_default:
    item: "<%= tag %> (<%= count %>),"
```

A Tag Template makes use of the same sub-keys as Pin Template:

* `opener` (*optional*): the text that should exist above the tag string
* `closer` (*optional*): the text that should exist below the tag string
* `item` (**required**): the formatted text that should be output for every tag

### Available Tokens

Additionally, like a Pin Template, a Tag Template can make use of a few tokens:

* `<%= tag %>`: the name of the tag
* `<%= count %>`: the number of times the tag has been used (depending on the
range used)

### Usage

Pin Templates can be used in two ways: they can either be called dynamically:

```bash
$ pinpress tags -m template_name
```

...or a default template can be specified in `~/.pinpress`:

```yaml
---
pinpress:
  config_location: "/Users/abach/.pinpress"
  default_tag_template: pinpress_default
  # ... other keys ...
pin_templates:
  # ... other keys ...
tag_templates:
  # ... other keys ...
# ... other templates ...
```

So, knowing the above, both:

```bash
$ pinpress tags
```

...and:

```bash
$ pinpress tags -m pinpress_default
```

...will output tag data in the format specified by that template:

```bash
link-mash (15),app (2),ios (3),productivity (1),launch-center-pro (1),drafts (2),
```

# URL Linking

I often run into the situation where I want to take a URL from a pin's description
and add an `<a>` tag around it (since Pinboard doesn't allow you to embed the HTML
within the pin description itself). PinPress provides two mechanisms to accomplish
this: automatic linking and manual linking.

## Automatic URL Linking

### Using It

To use automatic linking, simply use the `-a` switch when running PinPress.

Alternatively, to always use automatic linking, include a `auto_link` key/value
in `~/.pinpress`:

```yaml
pinpress:
  auto_link: true
```

Note that the `auto_link` configuration key can be overridden by using a different
URL linking switch (such as `-l`).

### How It Works

Using this method, PinPress will scan each pin that is being requested for URLs.
Upon finding a URL, PinPress will automatically wrap it in an `<a>` tag.

For example, given a description that looks like this:

```html
...this is some text with a URL: http://www.google.com.
```

...PinPress will modify the description such that the following is output
instead:

```html
...this is some text with a URL: <a href="http://www.google.com" target="_blank">http://www.google.com</a>.
```

Finally, this link gets stored in `~/.pinpress`:

```yaml
links:
  # This ID is a combination of the URL
  # and the pin in which it is found.
  853d65b7e76a57955040e97902fc2b3c:
    title: Pin with Google
    url: http://www.google.com
    link_text: http://www.google.com
```

This happens for two reasons:

1. Going forward, any request that returns this pin will use the data found
in `~/.pinpress` (so that it doesn't have to be recalculated).
2. If you want to modify the text that gets used for this link in this pin,
you can do it here.

## Manual URL Linking

### Using It

To use automatic linking, simply use the `-l` switch when running PinPress.

Alternatively, to always use automatic linking, include a `manual_link` key/value
in `~/.pinpress`:

```yaml
pinpress:
  manual_link: true
```

Note that the `manual_link` configuration key can be overridden by using a different
URL linking switch (such as `-a`).

### How It Works

This method is similar to automatic linking in that it will search each pin in the
output for URLs in its description. When found, the user is prompted to enter the
text that will create the link.

For example, given a description that looks like this:

```html
Check out https://gifyoutube.com/!
```

...imagine that the user types in `GIF Youtube`; the result will look like this:

```html
Check out <a href="https://gifyoutube.com/" target="_blank">GIF Youtube</a>!
```

Like automatic linking, the results of this URL/pin combo are stored in
`~/.pinpress` for easy lookup and future editing.

# Other Configuration Options

## Global Keys

You can place special keys in the `pinpress` section of `~/.pinpress` to
automate some actions:

```yaml
pinpress:
  # ...other keys...

  # The default pins template to use
  default_pin_template: template_name

  # The default tags template to use
  default_tag_template: template_name

  # Automatic URL linking; note that this
  # cannot exist eat the same time as manual
  # URL linking
  auto_link: true

  # Manual URL linking; note that this
  # cannot exist eat the same time as auto
  # URL linking
  manual_link: true

  # ...other keys...
```

## Template Keys

Individual templates can carry some special keys, too:

```yaml
pin_templates:
- template_name:
    # ...other keys...

    # The default tags to be used when running `pinpress pins`
    default_tags: ['tag1', 'tag2']

    # The tags to that are removed from the results when running `pinpress tags`
    ignored_tags: ['bad-tag', 'bad-tag2']

    # The default number of results to return
    default_num_results: 5

    # ...other keys...
```

Do note:

* The `default_tags` key is overridden by the `-t` flag.
* The `default_num_results` key is overridden by the `-n` flag.

# Link Mash Config File

For your reference, here's my `~/.pinpress` (which is used to generate a
[Link Mash on my blog](http://www.bachyaproductions.com/tag/link-mash/ "Bachya Productions Link Mash Archives")):

```yaml
---
pinpress:
  config_location: "/Users/abach/.pinpress"
  default_pin_template: pinpress_default
  default_tag_template: pinpress_default
  log_level: WARN
  version: 1.6.0
  api_token: bachya:1234567890987654321
  manual_link: true
pin_templates:
- pinpress_default:
    opener: |
      <em>The weekly Link Mash is a curated selection of tools, stories, and other links that I found during my travels on the web. All of my links can be found on <a title="Bachya's Pinboard: Link Mash" href="https://pinboard.in/u:bachya/t:link-mash/" target="_blank">my Pinboard</a>; you can also find the Link Mash archives <a href="http://www.bachyaproductions.com/tag/link-mash/">here</a>.</em><ul>
    item: |
      <li><b><a title="<%= description %>" href="<%= href %>" target="_blank"><%= description %></a>.</b> <%= extended %></li>
    closer: |
      </ul><hr/><em>This Link Mash was generated by <a title="PinPress" href="https://github.com/bachya/pinpress" target="_blank">PinPress</a>, a simple tool to generate text templates from <a title="Pinboard" href="https://pinboard.in" target="_blank">Pinboard</a> data.</em>
    last_run: '2014-05-20T15:22:10Z'
    default_tags:
    - link-mash
    ignored_tags:
    - buffer
tag_templates:
- pinpress_default:
    item: "<%= tag %>,"
    last_run: '2014-05-20T15:22:10Z'
```

# Known Issues & Future Releases

Check out the Pinpress roadmap via the
[Trello Board](https://trello.com/b/lmuC8TT0/pinpress "Pinpress Trello Board").

Bugs, issues, and enhancement requests can be submitted on the
[Issues Page](https://github.com/bachya/Pinpress/issues "Open Items").

# Bugs and Feature Requests

To report bugs with or suggest features/changes for PinPress, please use the
[Issues Page](http://github.com/bachya/PinPress/issues).

Contributions are welcome and encouraged. To contribute:

* [Fork PinPress](http://github.com/bachya/PinPress/fork).
* Create a branch for your contribution (`git checkout -b new-feature`).
* Commit your changes (`git commit -am 'Added this new feature'`).
* Push to the branch (`git push origin new-feature`).
* Create a new [Pull Request](http://github.com/bachya/PinPress/compare/).

# License

(The MIT License)

Copyright © 2014 Aaron Bach <bachya1208@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
