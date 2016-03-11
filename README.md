open-plus package
=================

[![Build Status](https://travis-ci.org/klorenz/atom-open-plus.svg?branch=master)](https://travis-ci.org/klorenz/atom-open-plus)

Use ctrl-o to open file specified by filename under cursor.

Open plus opens filenames under cursors or from selections.  Non-absolute
filenames are interpreted relative to filename of current buffer.

Binary files and URLs are opened by external application defined by your OS.

If word under cursor has no extension, and resolved file does not exist,
extension from current file is added to filename.

If you click at a filename, keep the left mouse-button pressed and then hit the
(left) ctrl-key, it will also open the file, you clicked at.


Xikij Support
-------------

There is special support for [xikij](http://github.com/klorenz/atom-xikij)
package.  If you are on a path like

```
    /etc
       + fstab
```

You can hit ctrl+o and file opens in atom or external if binary.


Use Cases
---------

- open or create files from toctree directive in Sphinx Documentation
- open file in `doc` role of Sphinx Documentation
- open file specified in require or include statements (if relative to current)
- if opened a build output, quickly jump to files in errors
- jump to files from stacktraces
