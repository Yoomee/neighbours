module AdminHelper
  
  def full_name_and_role(user)
    link_to(user.full_name.titleize, user).tap do |out|
      if user.role == 'admin'
        out << "&nbsp;".html_safe + content_tag(:span, 'Admin', :class => "badge badge-square badge-info")
      end
    end.html_safe
  end
  
  def users_tab_li(name, users)
    li_class = users.size.zero? ? 'no-results' : 'results'
    if @active_tab.blank? && users.size.nonzero?
      @active_tab = name
      active_class = 'active'
    end
    content_tag(:li, :class => li_class) do
      link_to(name, "##{name.downcase.gsub(' ', '-')}", :'data-toggle' => 'tab')
    end
  end
  
end