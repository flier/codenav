module.exports =
class CodenavView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('codenav')

    # Create message element
    message = document.createElement('div')
    message.textContent = "The Codenav package is Alive! It's ALIVE!"
    message.classList.add('message')
    @element.appendChild(message)

    @modalPanel = atom.workspace.addTopPanel(item: @getElement(), visible: false)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()
    @modalPanel.destroy()

  getElement: ->
    @element

  toggle: ->
    console.log 'Codenav was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
