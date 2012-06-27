#  This is a manifest file that'll be compiled into including all the files listed below.
#  Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
#  be included in the compiled file accessible from http://example.com/assets/application.js
#  It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
#  the compiled file.
# 
#= require jquery
#= require jquery_ujs
#= require ym_core
#= require rails.validations
#= require_tree .

$(document).ready () ->
  $("select[multiple='multiple']").chosen(
    persistent_create_option: false,
    create_option_text: "Add",
    create_option: (term) ->
      this.append_option(
        value: term,
        text: term
      )
  )

window.Registration = 
  initValidateLinks: () ->
    $('a.validate-by-link').live 'click', (event) ->
      event.preventDefault()
      $('a.validate-by-link').removeClass('active')
      `$(this)`.addClass('active')
      $('#user_validate_by').val(`$(this)`.data('validate-by'))

window.NewNeedForm = 
  force_submit: false
  init: () ->
    $('#register-modal-login-link, #register-modal-register-link').click (event) ->
      event.preventDefault()
      $('input#return_to').val($(this).attr('href'))
      NewNeedForm.force_submit = true
      $('form#new_need').submit()
    clientSideValidations.callbacks.form.pass = (element, callback) ->
      console.log('hello')
      $('#register-popup').modal('show')
    $('form#new_need').submit () ->
      NewNeedForm.force_submit