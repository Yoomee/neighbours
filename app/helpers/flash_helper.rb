module FlashHelper
  
  include YmCore::FlashHelper

  def render_flash
    flash.map do |key, val|
      unless val == "Welcome back!" && current_user && !current_user.fully_registered? && current_user.neighbourhood
        render_modal(val) if key == :modal

        content_tag(:div, dismiss_link('x','alert') + val.try(:html_safe), :class => alert_class(key))
      end
    end.join.html_safe
  end

end