module FlashHelper
  
  include YmCore::FlashHelper

  def render_flash
    flash.map do |key, val|
      if key == :modal
        render_modal(val)
      else
        if val == "Welcome back!" && current_user && !current_user.fully_registered? && current_user.neighbourhood
          val = "Welcome back " + current_user.first_name + "! You haven't fully registered yet. #{link_to "Find out more about registration", about_pre_registrations_path, :class => "no-color underline"}"
        end
        content_tag(:div, dismiss_link('x','alert') + val.html_safe, :class => alert_class(key))
      end
    end.join.html_safe
  end

end