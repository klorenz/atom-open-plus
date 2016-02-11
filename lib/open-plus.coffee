"""

$ npm install opener --save
$ npm install isbinaryfile --save
  isbinaryfile@2.0.1 ../node_modules/isbinaryfile
  npm http GET https://registry.npmjs.org/isbinaryfile
  npm http 200 https://registry.npmjs.org/isbinaryfile
"""

path         = require 'path'
fs           = require 'fs'
isBinaryFile = require 'isbinaryfile'
{Range} = require 'atom'

osOpen = require "opener"

module.exports =
  config:
    confirmOpenNewFile:
      type: "boolean"
      default: false

    #searchBackFor


  openPlusView: null
  xikij: null

  filePattern: /[^\s()!$&'"*+,;={}]+/g # no spaces or sub-delims from url rfc3986

  activate: (state) ->
    atom.commands.add "atom-workspace", "open-plus:open", => @openPlus()

  deactivate: ->

  serialize: ->

  # open: (filename) ->
  #   if isBinaryFile(filename)
  #
  openFile: (filename) ->
    console.log "filename: #{filename}"

    if not filename
      view = atom.views.getView(atom.workspace)
      return atom.commands.dispatch view, "application:open-file"

    # if url scheme match, let system open the file
    if filename.match /^[a-z][\w\-]+:/
      #console.log "use os opener"
      # scheme!deb http://repository.spotify.com stable non-free

      osOpen = require "opener"
      return osOpen filename

    # remove trailing non-characters
    filename = filename.replace /\W*$/, ''

    # check if there is an encoded position
    opts = {}
    if m = filename.match /(.*?):(\d+)(?::(\d+))?:?$/
      filename = m[1]
      opts.initialLine = parseInt(m[2])
      if m[3]
        opts.initialColumn = parseInt(m[3])-1

    editor = atom.workspace.getActiveTextEditor()
    absolute = path.dirname(editor.getPath())

    # check file and open it
    @fileCheckAndOpen filename, absolute, editor, opts

    console.log "#{filename} : #{opts}";

  createFile: (filename, opts) ->
    {findMatchingPath, editor} = opts

    if not path.extname filename
      filename += path.extname editor.getPath()

    currentFileDir = path.dirname(editor.getPath())

    newFile = null
    if not findMatchingPath
      newFile = path.resolve currentFileDir, filename

    else
      newFile = path.resolve currentFileDir, filename

      # if there is no relative path in filename
      if path.sep in filename
        pathElements = currentFileDir.split(path.sep).reverse()

        # find relative path of current file to project root
        for prjdir in atom.project.rootDirectories
          if currentFileDir.startsWith prjdir.path
            relpath = path.relative(currentFileDir, prjdir)
            pathElements = relpath.split(path.sep).reverse()
            break

        finalPath    = currentFileDir

        anchor = filename.split(path.sep).shift()

        # loops through the new path backwards until it finds the app root
        # TODO: stop on project root ?
        for aPath in pathElements
          if aPath != anchor
            # move up one in the file structure
            finalPath = path.resolve finalPath, '..'
          else
            # move up one in the file structure one more time
            finalPath = path.resolve finalPath, '..'
            # resolve the finalPath with the path of the new file and open
            newFile = path.resolve finalPath, filename
            break

    return unless newFile

    if not atom.config.get('open-plus.confirmOpenNewFile')
      atom.workspace.open(newFile, opts)

    else
      atom.confirm
        message: 'File '+ newFile + ' does not exist'
        detailedMessage: 'Create it?'
        buttons:
          Ok: -> atom.workspace.open(newFile, opts)
          Cancel: -> return

  fileCheckAndOpen: (file, absolute, editor, opts) ->
    # if filename is not absolute, make it absolute relative to current dir
    if path.isAbsolute(file)
      filename = file
    else
      filename = path.resolve absolute, file

    if not fs.existsSync filename
      filenameExtension = path.extname filename
      currentFileExtension = path.extname editor.getPath()

      # if no extension there, attach extension of current file
      if not filenameExtension
        # if there is no extension, and it is a sass file
        if currentFileExtension == '.scss'
          filenameFile = filename.substring(filename.lastIndexOf('/') + 1, filename.length)
          # if the filename does not already start with _ ... add the underscore.
          # Fixes https://github.com/klorenz/atom-open-plus/issues/15
          if filenameFile.substring(0, 1) != '_'
            filenamePath = filename.substring(0, filename.lastIndexOf('/') + 1)
            filename = filenamePath + '_' + filenameFile + currentFileExtension
        else
          filename += currentFileExtension

    # if the file exists
    if fs.existsSync filename
      stat = fs.statSync filename

      if stat.isDirectory()
        #console.log "open directory"
        return atom.open pathsToOpen: [filename]
      else
        if isBinaryFile(filename)
          return osOpen filename

        # in case file already opened, initialLine and initialColumn are not
        # used. so set bufferposition here
        return atom.workspace.open(filename).then (editor) =>
          if opts.initialLine?
            column = opts.initialColumn ? 0
            editor.setCursorBufferPosition [opts.initialLine-1, column]

    # if file path does not exist
    else
      # do not create anything for absolute paths
      if path.isAbsolute(file)
        @createFile file, findMatchingPath: false, editor: editor

      # reached the project root path
      else if absolute in (r.path for r in atom.project.rootDirectories)
        @createFile file, findMatchingPath: true, editor: editor

      else
        absolute = path.resolve absolute, '..'

        @fileCheckAndOpen file, absolute, editor, opts

  openPlus: ->
    editor = atom.workspace.getActiveTextEditor()

    filePattern = new RegExp @filePattern.source, "g"
    for selection in editor.getSelections()
      #console.log "selection", selection
      range = selection.getBufferRange()

      if range.isEmpty()
        cursor = selection.cursor
        line   = cursor.getCurrentBufferLine()

        col  = cursor.getBufferColumn()
        opts = wordRegex: @filePattern
        start = cursor.getBeginningOfCurrentWordBufferPosition opts
        end   = cursor.getEndOfCurrentWordBufferPosition opts

        range = new Range(start, end)
        text = editor.getTextInBufferRange range

        # if text is no URL
        if not text.match /^[a-z][\w\-]+:/
          if xikij = atom.packages.getActivePackage('atom-xikij')
            xikij = xikij.mainModule
            if m = line.match /^(\s+)[+-]\s(.*)/
              body = xikij.getBody cursor.getBufferRow(), {editor}
              body += "\n" unless body.match /\n$/
              body += m[1] + "  @filepath\n"
              return xikij.request({body}).then (response) =>
                @openFile response.data

        col  = cursor.getBufferColumn()
        opts = wordRegex: @filePattern
        start = cursor.getBeginningOfCurrentWordBufferPosition opts
        end   = cursor.getEndOfCurrentWordBufferPosition opts

        range = new Range(start, end)

      text = editor.getTextInBufferRange range

      # create marker
      (->
        marker = editor.markBufferRange range
        editor.decorateMarker marker, type: "highlight", class: "open-plus"

        setTimeout (-> marker.destroy()), 2000
      )()

      # cursor was at some whitespace
      text = "" if text.match /\s/

      # do this as timeout to have visual feedback of markers
      setTimeout (=> @openFile text), 500

# ../../atom-xikij/
