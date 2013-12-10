module AdminHelper
  
  def full_name_and_role(user)
    link_to(user.full_name.titleize, user).tap do |out|
      if user.role == 'admin'
        out << "&nbsp;".html_safe + content_tag(:span, 'Admin', :class => "badge badge-square badge-info")
      end
    end.html_safe
  end
  
  def users_tab_li(user_tabs)
    html = ""

    active_set = false
    user_tabs.keys.each do |name|
      li_class = user_tabs.values.size.zero? ? 'no-results' : 'results'
      if params[:tab] == name.downcase.gsub(' ', '-') || params[:tab].nil? && name == "Unvalidated" && !params[:q].present? || params[:q].present? && user_tabs[name].present?
        li_class += ' active' if active_set == false
        active_set = true
      end

      html << content_tag(:li, :class => li_class) do
        link_to(name + "#{user_tabs[name].empty? || params[:q].nil? ? '' : " (" + user_tabs[name].size.to_s + ")"}", "##{name.downcase.gsub(' ', '-')}", :'data-toggle' => 'tab')
      end
    end
    html.html_safe
  end
  
end