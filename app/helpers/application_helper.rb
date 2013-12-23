module ApplicationHelper
  
  def show_control_panel?
    return false unless current_user
    !action_name.in?(%w{new map news about help}) && controller_name.in?(%w{home groups messages message_threads photos needs neighbourhoods offers}) && @enquiry.nil?
  end
  
  def messages_badge(message_count)
    if message_count > 0
      out = content_tag(:span, message_count, :class => 'badge')
      out + content_tag(:span, " message#{message_count > 1 ? 's' : ''}", :class => "request-message-text")
    else
      content_tag(:span, "No new messages", :class => "request-message-text")
    end
  end
  
  def header_messages_badge(message_count, options = {})
    if message_count > 0
      out = content_tag(:span, message_count, :class => 'badge badge-info')
      out + " message#{message_count > 1 ? 's' : ''}"
    else
      "No new messages"
    end
  end
  
  def neighbourhood_snippet_text(key, text=nil)
    if @neighbourhood
      @neighbourhood.snippet_text(key,text)
    else
      snippet_text(key,text)
    end
  end

  def link_to_with_tooltip(*args, &block)
    options = args.extract_options!
    object = block_given? ? args[0] : args[1]
    user = (object.is_a?(User) ? object : object.try(:user)) || options.delete(:user)
    if tooltip = user_address_tooltip(user)
      options.merge!(:rel => 'tooltip', :title => tooltip)
    end
    args << options
    link_to(*args, &block)
  end

  def user_address_tooltip(user)
    if user && current_user && user != current_user
      user.miles_from_s(current_user)
    end
  end

  def sortable(column, tab=nil)
    title = column
    case column
    when "Date/Time"
      sort = "created_at"
    when "Removed At"
      sort = "removed_at"
    when "Category"
      sort = "category_id"
    when "Resolved"
      sort = "resolved"
    when "Accepted"
      sort = "accepted"
    when "Person Who Offered" , "Person In Need"
      sort = "name"
    when "Person Who Needed", "Person Who Helped"
      sort = "name_secondary"
    else
      sort = Neighbours::SORTABLES[column]
    end

    css_class = "current #{sort_direction}"
    direction = sort_direction == "asc" ? "desc" : "asc"
    if params[:sort] == sort
      link_to title, {:sort => sort, :direction => direction, :tab => (tab if tab.present?)}, {:class => css_class, :icon => sort_direction == "asc" ? "caret-up" : "caret-down"}
    else
      link_to title, {:sort => sort, :direction => direction, :tab => (tab if tab.present?)}, {:class => css_class}
    end
  end
  
end
