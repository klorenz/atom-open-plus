module.exports = (opts) ->
#function(testPaths, buildAtomEnvironment, applicationDelegate, window, document, enablePersistence, buildDefaultApplicationDelegate, logFile, headless, legacyTestRunner) {
  {legacyTestRunner} = opts;
  legacyTestRunner(opts);
