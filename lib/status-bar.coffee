{vsprintf} = require "sprintf-js"

module.exports =
class StatusBar
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('loading')

    # Create message element
    @message = document.createElement('span')
    @message.classList.add('loading-message')
    @element.appendChild(@message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  setTitle: ->
    @message.textContent = vsprintf(Array.prototype.slice.call(arguments))
