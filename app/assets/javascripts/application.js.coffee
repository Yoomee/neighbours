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
#= require rails.validations.formtastic
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
  $('.link-find-us').tooltip()
  $('*[rel="tooltip"],div[data-tooltip="tooltip"]').tooltip(placement:'bottom')
  #$('.carousel').carousel() # {interval:$('.carousel').data('interval')})
  YmComments.Form.init({submitOnEnter: false})
  FormErrors.scrollToFirstError()
  NewNeedForm.initShowHideDeadline()
  PreRegistration.init()
  PhotoModal.init()
  NotFullyRegisteredModal.init()
  FlagLinks.init()
  SlideshowForm.init()
  Stats.init()
  if (window.addEventListener)
    window.addEventListener('message', Vimeo.handleVimeo, false);
  else
    window.attachEvent('onmessage', Vimeo.handleVimeo, false);

window.Vimeo =
  handleVimeo: (e) ->
        data = JSON.parse(e.data);
        switch (data.event)
          when 'ready' then Vimeo.onReady()
          when 'play' then Vimeo.onPlay()
          when 'finish' then Vimeo.onFinish()
  onReady: ->
        Vimeo.post('addEventListener', 'pause');
        Vimeo.post('addEventListener', 'play');
        Vimeo.post('addEventListener', 'finish');
  post: (action, value)->
    data = { method: action };
    if (value)
      data.value = value;
    $('iframe').each ->
      url = $(this).attr('src').split('?')[0]
      this.contentWindow.postMessage(JSON.stringify(data), url);
  onPlay: ->
    $('#slideshow-carousel').carousel('pause')
  onFinish: ->
    $('#slideshow-carousel').carousel('cycle')
>>>>>>> 3e7c957fa27bd5e2ae2c9c8d328b3973df805013

window.Login =
  init: ->
    if $('.flash_container .alert').text() == "xInvalid email or password."
      $('.flash_container').hide()
window.FlagLinks =
  init: ->
    $('#group-posts').on 'click', 'a.flag-link', (event) ->
      event.preventDefault()
      $('#flag_resource_id').val($(this).data('post-id'))
      $('#inappropriate').modal('show')

window.FullyRegister =
  init: ->
    $("#fully-register").modal "show"

    $("#fully-register").on "hide", ->
      $(".modal-bg").hide()

window.NotFullyRegisteredModal =
  init: ->
    $('a.not-fully-registered-link').click (event) ->
      event.preventDefault()
      nextLink = $('#not-fully-registered').find('a.not-fully-registered-next')
      if nextLink.length
        href = nextLink.attr('href').replace(/\?.*/, '')
        nextLink.attr('href', "#{href}?return_to=#{$(this).data('return-to')}")
      $('#not-fully-registered').modal('show')

window.PhotoModal =
  init: ->
    $('#photo-modal').on 'show', ->
      PhotoModal.loaderHtml = $(this).children('.modal-body').html()
    $('#photo-modal').on 'hidden', ->
      $(this).children('.modal-body').html(PhotoModal.loaderHtml)
      $(this).removeData('modal')

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
    Needs.startCycle "#resolved", 7000
    setTimeout "Needs.startCycle('#unresolved', 7000);", 3500
    $("#resolved,#unresolved").hover ->
      accessor = $(this).attr("id")
      if accessor is "resolved"
        clearInterval Needs.resolvedCycle
      else
        clearInterval Needs.unresolvedCycle
    , ->
      accessor = $(this).attr("id")
      Needs.cycle "\##{accessor}"
      Needs.startCycle "\##{accessor}", 7000

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
    if $('.card-details-form .control-group.error').length
      $('#card-modal').modal()
    $('a.validate-by-link[data-validate-by="credit_card"]').live 'click', (event) ->
      event.preventDefault()
      $('#card-modal').modal()
    $('a.validate-by-link').live 'click', (event) ->
      event.preventDefault()
      Registration.toggleValidateByType($(this).data('validate-by'))
  removeValidateByType: () ->
    $('.organisation-form').hide()
    $('a.validate-by-link').parent().removeClass('alert-info')
    $('#user_validate_by').val('')
  saveValidateByType: (type) ->
    if type == "organisation"
      $('.organisation-form').show()
    $('a.validate-by-link').parent().removeClass('alert-info')
    $("a.validate-by-link[data-validate-by='#{type}']").parent().addClass('alert-info')
    $('#user_validate_by').val(type)
  toggleValidateByType: (type) ->
    currentType = $('#user_validate_by').val()
    Registration.removeValidateByType()
    if type == "credit_card"      
      $('#user_requested_validation_by_credit_card').val(1)
      Registration.saveValidateByType(type)
    else if currentType != type
      Registration.saveValidateByType(type)

window.NeedCategorySelector =
  selectCategory: (categoryId) ->
    categoryId = parseInt(categoryId)
    $('input#category-id').val(categoryId)
    $('input#sub-category-id').val('')
    cat = $.grep(NeedCategorySelector.categories, (e) ->
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
    $('input#sub-category-id').val(subCategoryId)
  init: (typeToSuggest) ->
    $('#suggested-general-offers').on 'ajax:before', '.pagination a', (event) ->
      $('#suggested-general-offers').addClass('loading')
    $('#suggested-needs').on 'ajax:before', '.pagination a', (event) ->
      $('#suggested-needs').addClass('loading')
    $('a.need-category').click (event) ->
      event.preventDefault()
      $('a.need-category').removeClass('btn-primary')
      $(this).addClass('btn-primary')
      categoryId = $(this).data('categoryId')
      unless $('input#category-id').val() == categoryId
        NeedCategorySelector.selectCategory(categoryId)
      if typeToSuggest == 'general_offers'
        suggestedListId = "#suggested-general-offers"
        url = "/need_categories/#{categoryId}/general_offers"
      else
        suggestedListId = "#suggested-needs"
        url = "/need_categories/#{categoryId}/needs"        
      $("#{suggestedListId}").addClass('loading')
      $.ajax
        url: url,
        dataType: 'script'          
        success: () ->
          $("#{suggestedListId}").removeClass('loading')
    $('a.need-sub-category').live 'click', (event) ->
      event.preventDefault()
      $('a.need-sub-category').removeClass('btn-primary')
      $(this).addClass('btn-primary')
      NeedCategorySelector.selectSubCategory($(this).data('subCategoryId'))
    
window.NewNeedForm =
  force_submit: false
  init: (logged_in) ->
    NeedCategorySelector.init('general_offers')
    if logged_in == 0
      $('#register-modal-login-link, #register-modal-register-link').click (event) ->
        event.preventDefault()
        $('input#return_to').val($(this).attr('href'))
        NewNeedForm.force_submit = true
        $('form#new_need').submit()
      ClientSideValidations.callbacks.form.pass = (element, callback) ->
        $('#register-popup').modal('show')        
      $('form#new_need').submit () ->
        NewNeedForm.force_submit
  initShowHideDeadline: ->
    NewNeedForm.showHideDeadline()
    $('#need_need_to_know_by_input input[type="radio"]').change (event) ->
      NewNeedForm.showHideDeadline()
  showHideDeadline: ->
    if $('#need_need_to_know_by_input input[type="radio"]:checked').val() == "date"
      $('#need_deadline_input').css('visibility','visible')
    else
      $('#need_deadline_input select').val(null)
      $('#need_deadline_input').css('visibility','hidden')

window.GeneralOfferForm =
  init: (logged_in) ->
    NeedCategorySelector.init('needs')

window.NeedSelect =
  init: ->
    $('#what-help-select').change ->
      window.location.href = "/need_categories/#{$('#what-help-select').val()}/needs/new"

window.SlideshowForm =
    init:() ->
      if $('input#homepage_checkbox').data('homepage-slideshow')
        $('#homepage_checkbox').attr('checked', true)
        setSlug = ""
      else if $('input#slideshow_slideshow_slug').val()?
        setSlug = $('input#slideshow_slideshow_slug').val()
      else
        $('input#slideshow_slideshow_slug').val(SlideshowForm.generateRandomString())
      $('#homepage_checkbox').change ->
        if $(this).attr('checked')
          $('input#slideshow_slideshow_slug').val('homepage_slideshow')
        else
          if setSlug != ""
            $('input#slideshow_slideshow_slug').val(setSlug)
          else
            $('input#slideshow_slideshow_slug').val(SlideshowForm.generateRandomString())
      # Sets the default value if there's no value in the database
      if $('#slideshow_slideshow_interval').val() == ""
        $('#slideshow_slideshow_interval').val('5000')
    generateRandomString: ->
      text = ""
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
      i = 0

      while i < 12
        text += possible.charAt(Math.floor(Math.random() * possible.length))
        i++
      text
window.Stats =
  init: () ->
    $('.btn-destroy-needs').click (event) ->
      event.preventDefault()
      Stats.handleButtonClick('need', 'destroy', $(this).data('neighbourhood'))
    $('.btn-delete-needs').click (event) ->
      event.preventDefault()
      Stats.handleButtonClick('need', 'delete')
    $('.btn-delete-offers').click (event) ->
      event.preventDefault()
      Stats.handleButtonClick('offer', 'delete')
    $('.btn-destroy-offers').click (event) ->
      event.preventDefault()
      Stats.handleButtonClick('offer', 'destroy')
    $('.btn-destroy-general-offers').click (event) ->
      event.preventDefault()
      Stats.handleButtonClick('general_offer', 'destroy')
    $('.btn-delete-general-offers').click (event) ->
      event.preventDefault()
      Stats.handleButtonClick('general_offer', 'delete')
  handleButtonClick: (resourceType, method, neighbourhood) ->
    ids = []

    $("input[id^='#{resourceType}-select']").each () ->
      ids.push($(this).data('id')) if $(this)[0].checked

    if ids.length!= 0
      if confirm("Are you sure you want to delete #{ids.length} #{resourceType}s?")
        urlMethod = if method is 'destroy' then "destroy" else "remove"
        $.ajax({
          type: if method is 'destroy' then "DELETE" else "PUT"
          url: "/#{resourceType}s/#{urlMethod}_all"
          data: {ids: ids, neighbourhood:neighbourhood}
        }).done (data) ->
          history.go(0)
    else
      alert("You haven't selected anything.")
