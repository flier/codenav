CodenavView = require './codenav-view'
{CompositeDisposable} = require 'atom'

Logger = null
SphinxClient = null

module.exports = Codenav =
  codenavView: null
  modalPanel: null
  subscriptions: null

  config:
    sphinxApi:
      title: 'SphinxApi address'
      description: 'Connect Sphinx at address'
      type: 'string'
      default: '127.0.0.1:19312'
    sphinxPath:
      title: 'Sphinx `searchd` path'
      description: 'Run Sphinx from path'
      type: 'string'
      default: 'searchd'

  activate: (state) ->
    console.log "activate codenav"

    Logger ?= require 'atom-logger'

    @logger = logger = new Logger(atom.config, "codenav")
    @codenavView = new CodenavView(state.codenavViewState)
    @modalPanel = atom.workspace.addTopPanel(item: @codenavView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'codenav:toggle': => @toggle()

    sphinxPath = atom.config.get('codenav.sphinxPath')

    if fs.existsSync sphinxPath
      logger.info "`searchd` found @ ", sphinxPath
    else
      logger.info "searching for `searchd`"

      which = require 'which'

      which 'searchd', (er, resolvedPath) ->
        if er
          logger.info "`searchd` not found", er
        else
          logger.info "`searchd` found @ ", resolvedPath

          atom.config.set 'codenav.sphinxPath', resolvedPath

  deactivate: ->
    console.log "deactivate codenav"

    @modalPanel.destroy()
    @subscriptions.dispose()
    @codenavView.destroy()

    @statusBarTile?.destroy()
    @statusBarTile = null

  serialize: ->
    codenavViewState: @codenavView.serialize()

  toggle: ->
    console.log 'Codenav was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  consumeStatusBar: (statusBar) ->
    #@statusBarTile = statusBar.addLeftTile(item: myElement, priority: 100)
