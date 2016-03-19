"""
"""

{CompositeDisposable} = require 'atom'

{OpenPlusOpener} = require './open-plus-opener.coffee'

module.exports =
  config:
    confirmOpenNewFile:
      type: "boolean"
      default: false

    enableClickForOpen:
      type: "boolean"
      default: true
      description: """
        Open a file by clicking at some text, and press `Ctrl` key, before releasing the
        mouse button.
      """

  openPlusView: null
  xikij: null

  filePattern: /[^\s()!$&'"*+,;={}]+|\[\[[^\]]+\]\]/g # no spaces or sub-delims from url rfc3986

  activate: (state) ->
    @clickObserver = null

    @openPlusOpener = new OpenPlusOpener {@osOpen, @appOpen,
      @fileOpen, @dirOpen, @getRootDirs, @filePattern, @ambigiousOpen}

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add "atom-workspace", "open-plus:open", =>
      @openPlusOpener.openFromSelections atom.workspace.getActiveTextEditor()

    @subscriptions.add atom.config.onDidChange 'open-plus.enableClickForOpen', ({newValue,oldValue}) =>
      @disableClickForOpen()
      @enableClickForOpen()

    @enableClickForOpen()


  enableClickForOpen: ->
    return if @clickObserver?

    return unless atom.config.get('open-plus.enableClickForOpen')

    @clickObserver = atom.workspace.observeTextEditors (editor) =>
      view = atom.views.getView(editor)

      @onKeyDown = (event) =>
        if @clickedPosition? and event.which is 17
          @openPlusOpener.openFromSelections editor

      @onMouseDown = (event) =>
        component = view.component
        @clickedPosition = component.screenPositionForMouseEvent(event)

      @onMouseUp = (event) =>
        @clickedPosition = null

      view.addEventListener 'keydown', @onKeyDown
      view.addEventListener 'mousedown', @onMouseDown
      view.addEventListener 'mouseup', @onMouseUp

  disableClickForOpen: ->
    return unless @clickObserver?

    atom.workspace.getTextEditors().forEach (editor) ->
      view = atom.views.getView(editor)
      view.removeEventListener 'mouseup', @onMouseUp
      view.removeEventListener 'mousedown', @onMouseDown
      view.removeEventListener 'keydown', @onKeyDown
      @clickObserver.dispose()
    @clickObserver = null

  deactivate: ->
    @disableClickForOpen()
    @subscriptions.dispose()

  serialize: ->

  ambigiousOpen: (filenames, open) ->
    # here we can interactively select a file
    open filenames[0]

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
    atom.project.rootDirectories


# ../../atom-xikij/
