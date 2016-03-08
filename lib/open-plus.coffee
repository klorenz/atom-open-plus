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
    @openPlusOpener = new OpenPlusOpener {@osOpen, @appOpen,
      @fileOpen, @dirOpen, @getRootDirs, @filePattern}

    atom.commands.add "atom-workspace", "open-plus:open", =>
      @openPlusOpener.openFromSelections atom.workspace.getActiveTextEditor()

  deactivate: ->

  serialize: ->

  osOpen: (filename) ->
    (require "opener") filename

  appOpen: () ->
    view = atom.views.getView(atom.workspace)
    atom.commands.dispatch view, "application:open-file"

  fileOpen: (file, opts) ->
    atom.workspace.open(file, opts).then (editor) =>
      if opts.initialLine?
        column = opts.initialColumn ? 0
        editor.setCursorBufferPosition [opts.initialLine-1, column]

  dirOpen: (filename) ->
    atom.open pathsToOpen: [filename]

  getRootDirs: ->
    atom.project.rootDirectories()


# ../../atom-xikij/
