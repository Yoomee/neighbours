window.PreRegistration =
  init: () ->
    $('.modal').on 'click', 'a#pre-register-need-link', (event) ->
      event.preventDefault()
      PreRegistration.showContent('need-form')
    $('.modal').on 'click', 'a#pre-register-general-offer-link', (event) ->
      event.preventDefault()
      PreRegistration.showContent('general-offer-form')
    $('.modal').on 'click', 'a.pre-register-back-link', (event) ->
      event.preventDefault()
      PreRegistration.showContent('options')
  showContent: (type) ->
    selector = "#pre-register-#{type}"
    $("#pre-register >:not(#{selector})").hide()
    $(selector).show()