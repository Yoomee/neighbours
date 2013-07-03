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
    if user && current_user.try(:validated?)
      options.merge!(:rel => 'tooltip', :title => user_address_tooltip(user))
    end
    args << options
    link_to(*args, &block)
  end

  def user_address_tooltip(user)
    return nil unless current_user.try(:validated?) && user.try(:street_name).present? && user != current_user
    out = current_user.has_lat_lng? ? " (#{'%g' % current_user.miles_from(user.lat, user.lng)} miles)" : ""
    user.street_name + out
  end
  
end
