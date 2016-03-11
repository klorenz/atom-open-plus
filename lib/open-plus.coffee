"""
"""

{OpenPlusOpener} = require './open-plus-opener.coffee'

module.exports =
  config:
    confirmOpenNewFile:
      type: "boolean"
      default: false

  openPlusView: null
  xikij: null

  filePattern: /[^\s()!$&'"*+,;={}]+/g # no spaces or sub-delims from url rfc3986

  activate: (state) ->
    @openPlusOpener = new OpenPlusOpener {@osOpen, @appOpen,
      @fileOpen, @dirOpen, @getRootDirs, @filePattern}

    atom.commands.add "atom-workspace", "open-plus:open", =>
      @openPlusOpener.openFromSelections atom.workspace.getActiveTextEditor()

    atom.workspace.observeTextEditors (editor) =>
      view = atom.views.getView(editor)

      view.addEventListener 'keydown', (event) =>
        if @clickedPosition? and event.which is 17
          @openPlusOpener.openFromSelections editor

      view.addEventListener 'mousedown', (event) =>
        component = view.component
        @clickedPosition = component.screenPositionForMouseEvent(event)

      view.addEventListener 'mouseup', (event) =>
        @clickedPosition = null

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
