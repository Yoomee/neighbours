window.MultipleTypeahead =
  init: (selector, source) ->
    $(selector).typeahead
      source: source
      matcher: (item) ->
        tquery = MultipleTypeahead.extractor(this.query)
        if (!tquery) 
          false
        else
          ~item.toLowerCase().indexOf(tquery.toLowerCase())
      updater: (item) ->    
        this.$element.val().replace(/[^,]*$/,'') + " #{item}, "
      highlighter: (item) ->
        query = MultipleTypeahead.extractor(this.query).replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
        item.replace new RegExp("(#{query})", "ig"), ($1, match) ->
          "<strong>#{match}</strong>"
            
  extractor: (query) ->
    result = /([^,]+)$/.exec(query)
    if (result && result[1])
      result[1].trim()
    else
      ''