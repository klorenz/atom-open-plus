{OpenPlusOpener} = require "../lib/open-plus-opener.coffee"

describe "OpenPlusOpener", ->
  status = null
  openerOpts = {}
  opener = null

  # create environmentn for opener.  Store only what would be opened
  # to check if opener, opens correct path
  "osOpen appOpen dirOpen fileOpen".split(/\s+/g).forEach (method) ->
    openerOpts[method] = (filename, opts) ->
      status = {filename, method, opts}

  # reset status and opener
  beforeEach ->
    status = null
    opener = new OpenPlusOpener openerOpts

  describe "opening in reStructuredText Project", ->
    rootDir = null

    beforeEach ->
      rootDir = "#{__dirname}/fixtures/rstProject"
      opener.getRootDirs = -> [ rootDir ]

    checkOpen = (fileToOpen) ->
      opener.open fileToOpen, "#{rootDir}/index.rst"

      waitsFor ->
        status

      runs ->
        {filename, method, opts} = status
        expect(filename).toBe "#{rootDir}/#{fileToOpen}.rst"
        expect(method).toBe "fileOpen"
        expect(opts).toEqual {}

    it "can open an existing file", ->
      checkOpen "existing"

    it "can open a non-existing file", ->
      checkOpen "not-exists"

    it "dispatches to application's opener if file to open is empty", ->
      opener.open("", "#{rootDir}/index.rst")
      waitsFor ->
        status
      runs ->
        expect(status.method).toBe "appOpen"

    it "calls osOpen for managing URLs", ->
      opener.open("http://www.google.com", "#{rootDir}/index.rst")
      waitsFor ->
        status
      runs ->
        expect(status.filename).toBe "http://www.google.com"
        expect(status.method).toBe "osOpen"

    it "opens a file at correct line", ->
      opener.open("existing.rst:4", "#{rootDir}/index.rst")
      waitsFor ->
        status
      runs ->
        expect(status.filename).toBe "#{rootDir}/existing.rst"
        expect(status.method).toBe "fileOpen"
        expect(status.opts).toEqual {initialLine: 4}

    it "opens a file at correct line and column", ->
      opener.open("existing.rst:4:2", "#{rootDir}/index.rst")
      waitsFor ->
        status
      runs ->
        expect(status.filename).toBe "#{rootDir}/existing.rst"
        expect(status.method).toBe "fileOpen"
        expect(status.opts).toEqual {initialLine: 4, initialColumn: 1}

    fit "crawls folders up trying to find the path to open", ->
      opener.open("module/dir/include", "#{rootDir}/somedir/deeper/test.coffee")
      waitsFor ->
        status
      runs ->
        expect(status.filename).toBe "#{rootDir}/module/dir/include.coffee"
        expect(status.method).toBe "fileOpen"


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
