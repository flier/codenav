{CompositeDisposable} = require 'atom'

Promise = null
Logger = require 'atom-logger'

module.exports = Codenav =
  codenavView: null
  statusBar: null
  subscriptions: null
  indexer: null
  searcher: null

  config:
    sphinxApi:
      title: 'SphinxApi address'
      description: 'Connect Sphinx at address'
      type: 'string'
      default: '127.0.0.1:9312'
    sphinxPath:
      title: 'Sphinx `searchd` path'
      description: 'Run Sphinx from path'
      type: 'string'
      default: 'searchd'

  activate: (state) ->
    console.log "activate codenav"

    @logger = new Logger atom.config, "codenav"

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', {
      'codenav:toggle': => @createView(state).toggle()
    }

    @setupSphinx()

  deactivate: ->
    console.log "deactivate codenav"

    @subscriptions.dispose()
    @codenavView?.destroy()
    @statusBarTile?.destroy()
    @statusBar?.destroy()

  serialize: ->
    codenavViewState: @codenavView.serialize()

  createView: (state) ->
    unless @codenavView?
      CodenavView = require './codenav-view'
      @codenavView = new CodenavView(state.codenavViewState)
    @codenavView

  createStatusBar: ->
    unless @statusBar?
      StatusBar = require './status-bar'
      @statusBar = new StatusBar()
    @statusBar

  setupSphinx: ->
    @verifySphinx()

    atom.config.observe 'codenav.sphinxPath', (newValue, oldValue) =>
      @logger.info "Sphinx path changed from `%s` to `%s`", oldValue, newValue
      @verifySphinx()

  verifySphinx: ->
    Promise ?= require 'promise'

    promise = new Promise (resolve, reject) =>
      sphinxPath = atom.config.get('codenav.sphinxPath')

      fs.exists sphinxPath (exists) ->
        if exists
          resolve(sphinxPath)
        else
          which = require 'which'

          which 'searchd', (err, resolvedPath) ->
            if err
              reject(err)
            else
              resolve(resolvedPath)

    promise
      .then (sphinxPath) =>
        @logger.info "`searchd` found @", resolvedPath

        atom.config.set 'codenav.sphinxPath', resolvedPath

      .catch (err) =>
        logger.info "`searchd` not found, ", er

  provideIndexService: ->
    unless @indexer?
      console.log "creating index", atom.config.get('codenav.sphinxApi')

      Indexer = require "./indexer"
      @indexer = new Indexer atom.config.get('codenav.sphinxApi')
    @indexer

  provideSearchService: ->
    unless @searcher?
      console.log "creating searcher", atom.config.get('codenav.sphinxApi')

      Searcher = require "./searcher"
      @searcher = new Searcher atom.config.get('codenav.sphinxApi')
    @searcher

  consumeStatusBar: (statusBar) ->
    @statusBarTile = statusBar.addLeftTile(item: @createStatusBar().getElement(), priority: 100)
