var FormtasticFormValidations = {

  init: function() {
    ClientSideValidations.formBuilders["FormtasticBootstrap::FormBuilder"] = {
      add: function (element, settings, message) {
        if (element.data('validate') !== false) {
          element.addClass('error').data('validate', false);
          var $parent = element.closest('.controls');
          $parent.parent().addClass('error');
          $('<span/>').addClass('help-inline').text(message).appendTo($parent);
        } else {
          element.parent().find('span.help-inline').text(message);
        }
      },
      remove: function (element, settings) {
        var $parent = element.closest('.controls');
        $parent.parent().removeClass('error');
        $parent.find('span.help-inline').remove();
        element.data("validate", true);
        element.removeClass('error');
      }
    };
  }
  
};
FormtasticFormValidations.init();