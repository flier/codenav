SphinxService = require "./sphinx"

module.exports = 
class Indexer extends SphinxService
  watching = {}

  indexProject: (project) ->
    @logger.info "indexing project", project

    for dir in project.getDirectories()
      @indexDirectory dir

    @watching["/"]?.dispose()
    @watching["/"] = project.onDidChangePaths () =>
      @indexProject project

  indexDirectory: (dir) ->
    @logger.info "indexing directory", dir.getPath()

    dir.getEntries (err, entries) =>
      for entry in entries
        if entry.isFile()
          @indexFile entry
        else
          @indexDirectory entry

    @watching[dir.getPath()]?.dispose()
    @watching[dir.getPath()] = dir.onDidChange () =>
      @indexDirectory dir

  indexFile: (file) ->
    @logger.info "indexing file", file.getPath()

    @watching[dir.getPath()]?.watcher.dispose()
    @watching[dir.getPath()] = file.onDidChange () =>
      @indexFile file
