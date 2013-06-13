module AdminHelper
  
  def full_name_and_role(user)
    link_to(user.full_name.titleize, user).tap do |out|
      if user.role == 'admin'
        out << "&nbsp;" + content_tag(:span, 'Admin', :class => "badge badge-square badge-info")
      end
    end.html_safe
  end
  
end