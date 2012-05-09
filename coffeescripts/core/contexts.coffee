define ["jquery.custom"], ($) ->
  class Contexts
    # Arguments:
    # * api - editor API
    # * contexts - array of selectors
    constructor: (@api, @contexts) ->
      @$el = $(@api.el)
      @currentContexts = {}
      @api.on("activate.editor", @activate)
      @api.on("deactivate.editor", @deactivate)

    activate: =>
      @$el.on("keyup", @onkeyup)
      @$el.on("mouseup", @onmouseup)
      @updateContexts()

    deactivate: =>
      @$el.off("keyup", @onkeyup)
      @$el.off("mouseup", @onmouseup)
      @api.trigger("update.contexts", contexts: {}, removed: @contexts)

    onkeyup: (e) =>
      # Key code 13 is 'ENTER'.
      # Key code 33 to 40 are all navigation keys.
      @updateContexts() if e.which == 13 or 33 <= e.which <= 40

    onmouseup: (e) =>
      @updateContexts()

    updateContexts: =>
      matchedContexts = $(@api.getParentElement()).contexts(@contexts, @api.el)
      removedContexts = @getRemovedContexts(matchedContexts)
      @currentContexts = matchedContexts
      @api.trigger("update.contexts", contexts: matchedContexts, removed: removedContexts)

    getRemovedContexts: (matchedContexts) ->
      removedContexts = []
      for context, el of @currentContexts
        removedContexts.push(context) unless matchedContexts[context]
      return removedContexts

  return Contexts