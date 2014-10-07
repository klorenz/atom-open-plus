"""

$ npm install opener --save
$ npm install isbinaryfile --save
  isbinaryfile@2.0.1 ../node_modules/isbinaryfile
  npm http GET https://registry.npmjs.org/isbinaryfile
  npm http 200 https://registry.npmjs.org/isbinaryfile
"""

path    = require 'path'
fs      = require 'fs'
isBinaryFile = require 'isbinaryfile'
{Range} = require 'atom'


module.exports =
  openPlusView: null

  filePattern: /[^\s()!$&'*+,;=]+/g # no spaces or sub-delims from url rfc3986

  activate: (state) ->
    atom.workspaceView.command "open-plus:open", => @openPlus()

  deactivate: ->

  serialize: ->

  open: (filename) ->
    if isBinaryFile(filename)

  openFile: (filename) ->
    #console.log "filename: #{filename}"

    if not filename
      return atom.workspaceView.trigger "application:open-file"

    # if url scheme match, let system open the file
    if filename.match /^[a-z][\w\-]+:/
      #console.log "use os opener"
      # scheme!
      osOpen = require "opener"
      return osOpen filename

    # remove trailing non-characters
    filename = filename.replace /\W*$/, ''

    # check if there is an encoded position
    opts = {}
    if m = filename.match /(.*?):(\d+)(?::(\d+))?:?$/
      filename = m[1]
      opts.initialLine = m[2]
      if m[3]
        opts.initialColumn = m[3]

    editor = atom.workspace.getActiveEditor()

    # if filename is not absolute, make it absolute relative to current dir
    if path.resolve(filename) != filename
      filename = path.resolve path.dirname(editor.getPath()), filename

    if not fs.existsSync filename
      # if no extension there, attach extension of current file
      if not path.extname filename
        filename += path.extname editor.getPath()

    # if file exists, open it
    if fs.existsSync filename
      stat = fs.statSync filename
      if stat.isDirectory()
        #console.log "open directory"
        return atom.open pathsToOpen: [filename]
      else
        if isBinaryFile(filename)
          return osOpen filename

        #console.log "open file"
        return atom.workspace.open(filename, opts).then (editor) =>
          editor.scrollToCursorPosition()

    # open new file
    atom.workspace.open(filename, opts).then (editor) =>
      editor.scrollToCursorPosition()

  openPlus: ->
    editor = atom.workspace.getActiveEditor()

    filePattern = new RegExp @filePattern.source, "g"
    for selection in editor.getSelections()
      #console.log "selection", selection
      range = selection.getBufferRange()

      if range.isEmpty()
        cursor = selection.cursor

        line = cursor.getCurrentBufferLine()
        col  = cursor.getBufferColumn()
        opts = wordRegex: @filePattern
        start = cursor.getBeginningOfCurrentWordBufferPosition opts
        end   = cursor.getEndOfCurrentWordBufferPosition opts

        range = new Range(start, end)

      text = editor.getTextInBufferRange range

      # cursor was at some whitespace
      text = "" if text.match /\s/

      @open text
