# 1.6.2 (2015-06-05)

* Update htmlentities gem in gemspec.

# 1.6.1 (2014-09-20)

* Switched from [pbcopy](https://github.com/JoshCheek/pbcopy) to [clippy](https://github.com/envygeeks/clippy)

# 1.6.0 (2014-09-15)

* Added `-a` flag to automatically create hyperlinks from URLs in pin descriptions
* Added `-l` flag to prompt user to build hyperlinks around URLs in pin descriptions
* Added `-c` flag to automatically copy output to system clipboard

# 1.5.2 (2014-06-07)

* Fixed a small bug with running `tags last`

# 1.5.1 (2014-05-27)

* Fixed a bug with grabbing ignored tags from individual tag templates

# 1.5.0 (2014-05-21)

* Applied default tags and ignored tags to templates, rather than globally
* `last` commands will run every time, even if they've never run before
* Small refactorings

# 1.4.2 (2014-05-16)

* Some small refactorings

# 1.4.1 (2014-05-13)

* Fixed a bug with displaying templates

# 1.4.0 (2014-05-13)

* Modified last_run logic to exist on each template
* Fixed a few small bugs related to template selection

# 1.3.3 (2014-05-13)

* Fixed a bug with datetimestamps in `pins last` and `tags last`

# 1.3.2 (2014-05-08)

* Added ability to list template contents, along with name

# 1.3.1 (2014-05-06)

* Modified last-run to store DateTime, rather than just a Date

# 1.3.0 (2014-05-05)

* Huge refactoring; much cleaner
* Added HTML encoding to pin desriptions
* Fixed bugs with application of tags to both `pins` and `tags` command
* Bumped CLIUtils to version 2.2.3

# 1.2.3 (2014-05-04)

* Fixed a bug where error management failed
* Updated documentation

# 1.2.2 (2014-04-29)

* Fixed a bug in which the configuration wouldn't update as expected

# 1.2.1 (2014-04-29)

* Added `pinpress pins last` functionality
* Refactored pin-getting code to common place
* More documentation

# 1.2.0 (2014-04-29)

* Added `ignored_tags` configuration key
* Several bugfixes

# 1.1.2 (2014-04-29)

* Added the `-t` flag to the `tags` command

# 1.1.1 (2014-04-19)

* Small bugfixes
* Documentation
* Soem file renaming

# 1.1.0 (2014-04-18)

* Added default tags
* Added default number of results
* Rubocop refactoring
* Documentation
* Several bugfixes

# 1.0.1 (2014-04-17)

* Documentation

# 1.0.0 (2014-04-16)

* Initial release
