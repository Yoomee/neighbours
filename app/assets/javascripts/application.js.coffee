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
#= require cocoon
#= require jquery.scrollTo
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
  FormErrors.scrollToFirstError()

window.IntroPageNav =
  init: ->
    $(window).scroll ->
      if $("body").scrollTop() > 160
        $('#header-intro').addClass('header-intro-fixed')
        $('#header-intro-placeholder').height(160)
      else
        $('#header-intro').removeClass('header-intro-fixed')
        $('#header-intro-placeholder').height(0)

window.Needs =
  init: ->
    Needs.startCycle "#resolved", 3000
    setTimeout "Needs.startCycle('#unresolved', 3000);", 1500
    $("#resolved,#unresolved").hover ->
      accessor = $(this).attr("id")
      if accessor is "resolved"
        clearInterval Needs.resolvedCycle
      else
        clearInterval Needs.unresolvedCycle
    , ->
      accessor = $(this).attr("id")
      Needs.cycle "\##{accessor}"
      Needs.startCycle "\##{accessor}", 3000

  startCycle: (accessor, interval) ->
    if accessor is "#resolved"
      Needs.resolvedCycle = setInterval("Needs.cycle('" + accessor + "');", interval)
    else
      Needs.unresolvedCycle = setInterval("Needs.cycle('" + accessor + "');", interval)

  cycle: (accessor) ->
    $(accessor).animate
      top: "-112px",
      2000,
      ->
        $(this).css "top", "0px"
        $(this).children("li:first").appendTo $(this).show()


window.FormErrors =
  scrollToFirstError: () ->
    YmCore.scrollTo($('form .control-group.error:first'), {offset: 10})

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
    if type == "credit_card"
      $('#user_requested_validation_by_credit_card').val(1)
      $('#card-modal').modal()
    else
      unless currentType == type
        Registration.saveValidateByType(type)

window.NewNeedForm =
  force_submit: false
  selectCategory: (categoryId) ->
    $('input#need_category_id').val(categoryId)
    $('input#need_sub_category_id').val('')    
    cat = $.grep(NewNeedForm.categories, (e) ->
      e.id is categoryId
    )[0]
    if cat && cat.sub_categories.length
      $("#need-sub-categories .help-tags").empty()
      $.each cat.sub_categories, (idx, subCat) ->
        subCatLink = $("<a href='#' class='help-tag btn need-sub-category' data-sub-category-id=#{subCat.id}>#{subCat.name}</>")
        $("#need-sub-categories .help-tags").append($('<li>').append(subCatLink))
      $("#need-sub-categories").show()
    else
      $("#need-sub-categories").hide()
  selectSubCategory: (subCategoryId) ->
    $('input#need_sub_category_id').val(subCategoryId)
  init: (logged_in) ->
    NewNeedForm.showHideDeadline()
    $('a.need-category').click (event) ->
      event.preventDefault()
      categoryId = $(this).data('categoryId')
      unless $('input#need_category_id').val() == categoryId
        NewNeedForm.selectCategory(categoryId)
    $('a.need-sub-category').live 'click', (event) ->
      event.preventDefault()
      $('a.need-sub-category').removeClass('btn-primary')
      $(this).addClass('btn-primary')
      NewNeedForm.selectSubCategory($(this).data('subCategoryId'))
    NewNeedForm.selectCategory($('input#need_category_id').val())
      
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