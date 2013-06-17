window.PreRegistration =
  init: () ->
    $('.modal').on 'click', 'a#pre-register-need-link', (event) ->
      event.preventDefault()
      PreRegistration.showSignupModal('need')
    $('.modal').on 'click', 'a#pre-register-general-offer-link', (event) ->
      event.preventDefault()
      PreRegistration.showSignupModal('general-offer')
    $('.modal').on 'click', 'a#pre-register-signup-link', (event) ->
      event.preventDefault()
      PreRegistration.showSignupModal('signup')
    $('.modal').on 'click', 'a.pre-register-back-link', (event) ->
      event.preventDefault()
      $('.modal.in').modal('hide')    
      $('#pre-register').modal('show')
  showSignupModal: (type) ->
    need_or_offer = type.replace('-', '_')
    need_or_offer = '' if type == 'signup'
    $('input#pre_register_need_or_offer').val(need_or_offer)
    $('#pre-register-signup form').children().hide()
    $("#pre-register-#{type}-fields").show()
    $('.modal.in').modal('hide')
    $('#pre-register-signup').modal('show')