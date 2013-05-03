/*
  Client Side Validations - Formtastic - v2.0.0
  https://github.com/dockyard/client_side_validations-formtastic

  Copyright (c) 2012 DockYard, LLC
  Licensed under the MIT license
  http://www.opensource.org/licenses/mit-license.php
*/
(function(){ClientSideValidations.formBuilders["Formtastic::FormBuilder"]={add:function(e,t,n){var r,i;return e.data("valid")!==!1?(i=e.closest("li"),r=$("<p/>",{"class":t.inline_error_class,text:n}),i.addClass("error"),i.append(r)):e.parent().find("p."+t.inline_error_class).text(n)},remove:function(e,t){var n,r;return r=e.closest("li.error"),n=r.find("p."+t.inline_error_class),r.removeClass("error"),n.remove()}}}).call(this);