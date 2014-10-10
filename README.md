open-plus package
=================

Use ctrl-o to open file of filename under cursor.

Open plus opens filenames under cursors or from selections.  Non-absolute
filenames are interpreted relative to filename of current buffer.

Binary files and URLs are opened by external application defined by your OS.

If word under cursor has no extension, and resolved file does not exist,
extension of current file is added to filename.


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
