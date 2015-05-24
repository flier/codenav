SphinxClient = require "sphinxapi"

Logger = require 'atom-logger'

module.exports =
class SphinxService
  constructor: (addr) ->
    unless typeof addr is 'string'
      throw new TypeError('`addr` must be a string')

    @logger = logger = new Logger atom.config, "codenav"

    [@host, @port] = @parseAddress(addr)

    @client = new SphinxClient
    @client.SetServer(@host, @port)
    @client.Status (err, rows) =>
      if err
        atom.notifications.addWarning "fail to connect Sphinx @", @host, ":", @port, ", error=", err.message

        @logger.info "fail to connect Sphinx @", @host, ":", @port, ", error=", err.message, ", stack=", err.stack
      else
        atom.notifications.addSuccess "connected to Sphinx ", rows

  parseAddress: (addr) ->
    [host, port] = addr.split(':', 2)

    [host, Number.parseInt(port)]
