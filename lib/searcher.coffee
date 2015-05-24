SphinxService = require "./sphinx"

module.exports =
class Searcher extends SphinxService
  findSymbol: (name) ->
    @logger.info "finding symbol", name
