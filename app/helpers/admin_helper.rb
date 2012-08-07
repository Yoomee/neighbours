module AdminHelper
  
  def name_and_role(user)
    user.full_name.tap do |out|
      if user.role == 'admin'
        out << "&nbsp;" + content_tag(:span, 'Admin', :class => "badge badge-square badge-info")
      end
    end.html_safe
  end
  
end