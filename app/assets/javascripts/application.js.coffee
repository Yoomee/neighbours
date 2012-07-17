#  This is a manifest file that'll be compiled into including all the files listed below.
#  Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
#  be included in the compiled file accessible from http://example.com/assets/application.js
#  It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
#  the compiled file.
# 
#= require jquery
#= require jquery_ujs
#= require ym_core
#= require ym_cms
#= require ym_posts
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
  $('.help-icon').tooltip()
  $('*[rel="tooltip"],div[data-tooltip="tooltip"]').tooltip(placement:'bottom')
  YmComments.Form.init({submitOnEnter: false})

window.Registration = 
  initValidateStep: () ->
    $('form.user').submit () ->
      if $('#user_validate_by').val() != "credit_card"
        $('.card-details-form input, .card-details-form select').each (index) ->
          $(this).val('')
      if $('#user_validate_by').val() != "organisation"
        $('.organisation select').each (index) ->
          $(this).val('')        
      return true
    currentType = $('#user_validate_by').val()
    if currentType.length
      Registration.saveValidateByType(currentType)
    $('a.validate-by-link').live 'click', (event) ->
      event.preventDefault()
      Registration.toggleValidateByType($(this).data('validate-by'))
  removeValidateByType: () ->
    $('.card-details-form, .organisation-form').hide()
    $('a.validate-by-link').parent().removeClass('alert-info')
    $('#user_validate_by').val('')
  saveValidateByType: (type) ->
    if type == "credit_card"
      $('.card-details-form').show()
    else if type == "organisation"
      $('.organisation-form').show()
    $('a.validate-by-link').parent().removeClass('alert-info')
    $("a.validate-by-link[data-validate-by='#{type}']").parent().addClass('alert-info')
    $('#user_validate_by').val(type)
  toggleValidateByType: (type) ->
    currentType = $('#user_validate_by').val()
    Registration.removeValidateByType()
    unless currentType == type
      Registration.saveValidateByType(type)

window.NewNeedForm = 
  force_submit: false
  init: (logged_in) ->
    NewNeedForm.showHideDeadline()
    $('#need_need_to_know_by_input input[type="radio"]').change ->
      NewNeedForm.showHideDeadline()
    if logged_in == 0
      $('#register-modal-login-link, #register-modal-register-link').click (event) ->
        event.preventDefault()
        $('input#return_to').val($(this).attr('href'))
        NewNeedForm.force_submit = true
        $('form#new_need').submit()
      clientSideValidations.callbacks.form.pass = (element, callback) ->
        $('#register-popup').modal('show')
      $('form#new_need').submit () ->
        NewNeedForm.force_submit
  showHideDeadline: ->
    if $('input[name="need[need_to_know_by]"]:checked').val() == "date"
      $('#need_deadline_input').css('visibility','visible')
    else
      $('#need_deadline_input select').val(null)
      $('#need_deadline_input').css('visibility','hidden')
    
      
window.NeedSelect =
  init: ->
    $('#what-help-select').change ->
      window.location.href = "/need_categories/#{$('#what-help-select').val()}/needs/new"
    