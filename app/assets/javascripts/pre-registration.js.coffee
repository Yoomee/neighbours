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
      $('#ready_for_pre_register_signup').val('0')
      $('.modal.in').modal('hide')    
      $('#pre-register').modal('show')
    $('.pre-register-need-link').click (event) ->
      event.preventDefault()
      $('#pre-register').modal('show')
      PreRegistration.showSignupModal('need')
    $('.pre-register-general-offer-link').click (event) ->
      event.preventDefault()
      $('#pre-register').modal('show')
      PreRegistration.showSignupModal('general-offer')
  showSignupModal: (type) ->
    if type == 'signup'
      $('#ready_for_pre_register_signup').val('1')
      $('input#pre_register_need_or_offer').val('')
    else
      $('#ready_for_pre_register_signup').val('0')      
      $('input#pre_register_need_or_offer').val(type.replace('-', '_'))
    $('#pre-register-signup form').children().hide()
    $("#pre-register-#{type}-fields").show()
    $('.modal.in').modal('hide')
    $('#pre-register-signup').modal('show')