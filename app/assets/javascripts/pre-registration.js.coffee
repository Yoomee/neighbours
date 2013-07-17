window.PreRegistration =
  init: () ->
    $('#pre-register').on 'show', (event) ->
      PreRegistration.trackPage('/join-now-popup')
    $('.modal').on 'click', 'a#pre-register-need-link', (event) ->
      event.preventDefault()
      PreRegistration.trackPage('/join-now-popup/needs/new')
      PreRegistration.showContent('need-form')
    $('.modal').on 'click', 'a#pre-register-general-offer-link', (event) ->
      event.preventDefault()
      PreRegistration.trackPage('/join-now-popup/general_offers/new')
      PreRegistration.showContent('general-offer-form')
    $('.modal').on 'click', 'a#pre-register-groups-link', (event) ->
      PreRegistration.trackPage('/join-now-popup/groups')
    $('.modal').on 'click', 'a.pre-register-back-link', (event) ->
      event.preventDefault()
      PreRegistration.showContent('options')
  showContent: (type) ->
    selector = "#pre-register-#{type}"
    $("#pre-register >:not(#{selector})").hide()
    $(selector).show()
  trackPage: (page) ->
    if typeof _gaq != 'undefined'
      _gaq.push(['_trackPageview', page])