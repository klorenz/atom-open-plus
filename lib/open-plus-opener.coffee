path = require 'path'
fs = require 'fs'
isBinaryFile = require 'isbinaryfile'
{Range} = require 'atom'

class OpenPlusOpener
  constructor: ({@osOpen, @dirOpen, @fileOpen, @appOpen, @ambigiousOpen, @getRootDirs, @filePattern}) ->
    @filePattern ?= /[^\s()!$&'"*+,;={}]+/g # no spaces or sub-delims from url rfc3986

  open: (filename, contextFileName) ->

    if not filename
      return @appOpen()

    # if url scheme match, let system open the file
    if filename.match /^[a-z][\w\-]+:/
      return @osOpen filename

    # remove trailing non-characters
    filename = filename.replace /\W*$/, ''

    # check if there is an encoded position
    opts = {}
    if m = filename.match /(.*?):(\d+)(?::(\d+))?:?$/
      filename = m[1]
      opts.initialLine = parseInt(m[2])
      if m[3]
        opts.initialColumn = parseInt(m[3])-1

    #absolute = path.dirname(contextFileName)

    # check file and open it
    @findAndOpen filename, contextFileName, opts

    #@findFile filename, absolute, opts

  createFile: (filename, opts) ->
    {findMatchingPath, contextFileName} = opts

    if not path.extname filename
      filename += path.extname contextFileName

    currentFileDir = path.dirname(contextFileName)

    newFile = null
    if not findMatchingPath
      newFile = path.resolve currentFileDir, filename

    else
      newFile = path.resolve currentFileDir, filename

      # if there is no relative path in filename
      if path.sep in filename
        pathElements = currentFileDir.split(path.sep).reverse()

        # find relative path of current file to project root
        for prjdir in @getRootDirs()
          if currentFileDir.startsWith prjdir.path
            relpath = path.relative(currentFileDir, prjdir.path)
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
      @fileOpen(newFile, {})

    else
      atom.confirm
        message: 'File '+ newFile + ' does not exist'
        detailedMessage: 'Create it?'
        buttons:
          Ok: -> @fileOpen(newFile, {})
          Cancel: -> return

  findAndOpen: (fileName, contextFileName, opts, absolute) ->
    absolute ?= path.dirname contextFileName

    # if filename is not absolute, make it absolute relative to current dir
    if path.isAbsolute(fileName)
      filename = fileName
    else
      filename = path.resolve absolute, fileName

    # if the file exists
    if fs.existsSync filename
      stat = fs.statSync filename

      if stat.isDirectory()
        return @dirOpen(filename)

      else
        if isBinaryFile(filename)
          return @osOpen filename

        # in case file already opened, initialLine and initialColumn are not
        # used. so set bufferposition here
        return @fileOpen(filename, opts)

    # if file path does not exist
    else

      dirname = path.dirname filename

      # do not create anything for absolute paths
      if path.isAbsolute(fileName)
        @createFile fileName, {findMatchingPath: false, contextFileName}

      # reached the project root path
      else if absolute in (r.path for r in @getRootDirs())
        @createFile fileName, {findMatchingPath: true, contextFileName}

      # find if directory exists while walking the tree
      else if fs.existsSync dirname
        matches = @findMatchingFile dirname, fileName

        info = path.parse(absolute)
        if matches.length is 0 and info.root == info.dir
          for r in @getRootDirs()
            matches += @findMatchingFile r, fileName

          if matches.length == 0
            return @createFile fileName, {findMatchingPath: false, contextFileName}

        if matches.length > 1

          # interactively select correct file
          if @ambigiousOpen?
            return @ambigiousOpen matches, (filename) =>
              @findAndOpen(filename, contextFileName, opts)
          else
            @findAndOpen(matches[0], contextFileName, opts)

        else if matches.length == 1
          @findAndOpen(matches[0], contextFileName, opts)
        else
          absolute = path.resolve absolute, '..'
          # restart the file checking process with either new extension or same filename
          @findAndOpen(filename, contextFileName, opts, absolute)

      else
        absolute = path.resolve absolute, '..'

        @findAndOpen fileName, contextFileName, opts, absolute

  findMatchingFile: (dirname, fileName) ->
    # read the directory and find if there is a file that matches the selected file
    files = fs.readdirSync dirname
    matches = []
    for file in files
      if (index = file.indexOf(path.basename fileName)) > -1
        if index == 1 && file[0] == '_'
          # TODO: do sccs_check
        else if index == 0  # this is the real file
          sep = path.sep
          matches.push dirname + sep + file
        else # fuzzy!
          # TODO: handle fuzzy

#          if matches.length > 1
      # TODO: ambigious filename

    matches

  openFromSelections: (editor) ->
    filePattern = new RegExp @filePattern.source, "g"

    for selection in editor.getSelections()
      range = selection.getBufferRange()

      if range.isEmpty()
        cursor = selection.cursor
        opts = wordRegex: filePattern

        if not cursor.isInsideWord(opts)
          @appOpen()
          continue

        start = cursor.getBeginningOfCurrentWordBufferPosition opts
        end   = cursor.getEndOfCurrentWordBufferPosition opts

        debugger
        # if right of a space and right before a word ...
        range = selection.getBufferRange()
        if range.start.column > 0
          range.start.column -= 1
          if editor.getTextInBufferRange(range) == " "
            cursor.moveRight()
            start = cursor.getBeginningOfCurrentWordBufferPosition opts
            end   = cursor.getEndOfCurrentWordBufferPosition opts
            cursor.moveLeft()

        range = new Range(start, end)
        text = editor.getTextInBufferRange range

        if m = text.match /^\[\[(.*)\]\]$/
          text = m[1]
          if m = text.match /^[^|]+\|(.*)$/
            text = m[1]
          else
            text = text.replace(/\s+/, '-')

        line   = cursor.getCurrentBufferLine()

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

        # opts = wordRegex: @filePattern
        # start = cursor.getBeginningOfCurrentWordBufferPosition opts
        # end   = cursor.getEndOfCurrentWordBufferPosition opts

        #range = new Range(start, end)

      text = editor.getTextInBufferRange range

      if m = text.match /^\[\[(.*)\]\]$/
        text = m[1]
        if m = text.match /^[^|]+\|(.*)$/
          text = m[1]
        else
          text = text.replace(/\s+/, '-')

      # create marker
      do ->
        marker = editor.markBufferRange range
        editor.decorateMarker marker, type: "highlight", class: "open-plus"

        setTimeout (-> marker.destroy()), 2000

      # cursor was at some whitespace
      text = "" if text.match /\s/

      # do this as timeout to have visual feedback of markers
      setTimeout (=> @open text, editor.getPath()), 500

module.exports = {OpenPlusOpener}
