## 0.10.1

- make open plus with click configurable: fix indentation in a function, which
  causes an exception (cannot read property 'dispose' of undefined)

## 0.10.0 

- Add ambigiousOpen handler (it is intended later to present a selection 
  list, if multiple files match the pattern)

- Improve handling of open-plus on word boundaries and in non-word areas

- make open plus with click configurable

## 0.9.1 - Bug fix release

- Fix #14 opening a not-existing path

## 0.9.0 - Implement open on click

- As requested in issue #1.  You click at a file, keep the 
  mousebutton pressed and then press ctrl.

## 0.8.2 - Bug fix release

- Fix issue #19

## 0.8.1 - Add Travis CI

## 0.8.0 - Restructuring

- Change from filename extension method to directory method (see #12)

  Thanks to ChuckPierce :)

- Restructured code for beeing able to run tests

- Fix styles, which caused a display bug in highlighting the selected
  word.


## 0.7.0 - Add scss special file handling with "_"

Thanks to aledemann

## 0.6.0 - New files can be anchored at a folder relative to project root (see #7)

Thanks to ChuckPierce :)

## 0.4.2 - Rename styles to stylesheets

## 0.4.1 - Merged mykz's changes (Compatibility with Atom 1.0 API)

## 0.4.0 - Compatibility to Atom 1.0 API

## 0.3.2 - Compatibility to new Atom API (fix)

## 0.3.1 - Compatibility to new Atom API

## 0.3.0 - Xikij Support
* resolve paths starting with "+" or "-" with xikij (if present)
  before opening

## 0.2.0 -

## 0.1.0 - First release
* Open files of filenames under cursor
* Locations of in files are supported (e.g. file:line:column)
* open binary files external
