# {Emitter} = require 'atom'
# {OpenPlusOpener} = require '../lib/open-plus-opener'
#
# ncp = require('ncp').ncp
# tmp = require('tmp');
# fs = require('fs')
# path = require('path')
#
# rmdirSync = (dir,file) ->
#   p = if file then path.join(dir,file) else dir
#   if fs.lstatSync(p).isDirectory()
#     fs.readdirSync(p).forEach(rmdirSync.bind(null,p))
#     fs.rmdirSync(p)
#   else
#     fs.unlinkSync(p)
#
# # Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
# #
# # To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# # or `fdescribe`). Remove the `f` to unfocus the block.
#
# describe "OpenPlus", ->
#   [workspaceElement, activationPromise, editor, editorElement] = []
#
#   openerOpts = {}
#   emitter = null
#
#   beforeEach ->
#     emitter = new Emitter()
#
#     ['osOpen', 'appOpen', 'fileOpen', 'dirOpen'].forEach (opener) ->
#       openerOpts[opener] = (filename, opts) ->
#         console.log "emit", 'did-open', opener, filename, opts
#         emitter.emit 'did-open', {opener, filename, opts}
#
#   describe "opening files in same folder, inheriting suffix", ->
#     tmpobj = null
#     projectDir = null
#
#     opener = null
#
#     beforeEach ->
#       filesCopiedPromise = new Promise (resolve, reject) =>
#         tmpobj = tmp.dirSync();
#         projectDir = "#{tmpobj.name}/project1"
#
#         ncp "#{__dirname}/fixtures/project1", tmpobj.name, (err) =>
#           if err
#             reject(err)
#           else
#             resolve()
#
#       waitsForPromise ->
#         filesCopiedPromise
#
#       runs ->
#         openerOpts.getRootDirs = -> [ projectDir ]
#
#         opener = new OpenPlusOpener openerOpts
#
#     afterEach ->
#       rmdirSync tmpobj.name
#
#     # it dispatches to application:open-file if nothing under cursor
#
#     # it calls osOpen for managing URLs
#
#     # it opens a file at correct line
#
#     # it opens a file at correct line, column
#
#     # absolute filenam under cursor
#
#     # relative filename under cursor
#
#     # binary file calls osOpen
#
#     # it "can open an existing file"
#
#     it "can open an existing file", ->
#       atom.workspace.open("#{projectDir}/index.rst").then (editor) ->
#         debugger
#         editor.setCursorBufferPosition [3, 5]
#
#         flag = false
#
#         # emitter.on 'did-open', ({opener, filename, opts}) ->
#         #   console.log("Help1")
#         #
#         #   expect(opener).toBe 'fileOpen'
#         #   expect(filename).toBe 'x'
#         #   expect(opts).toEqual {}
#         #   flag = true
#
#         opener.openFromSelections editor
#
#         waitsFor -> flag
#
#         runs ->
#           expect(flag).toBe true
#
#     it "can open an existing file (internal)", ->
#       atom.workspace.open("#{projectDir}/index.rst")
#       .then (editor) ->
#         editor.setCursorBufferPosition [3, 5]
#
#         flag = false
#
#         emitter.on 'did-open', ({opener, filename, opts}) ->
#           console.log("Help2")
#           expect(opener).toBe 'fileOpen'
#           expect(filename).toEqual "#{projectDir}/existing.rst"
#           expect(opts).toEqual {}
#           flag = true
#
#         OpenPlus.openFile("existing")
#
#         waitsFor -> flag
#
#       .catch (err) ->
#         console.log err
#
#         #atom.commands.dispatch atom.views.getView(editor), "open-plus:open"
