module ApplicationHelper
  
  def neighbourhood
    "Maltby"
  end
  
  def show_control_panel?
    return false unless current_user
    !action_name.new? && controller_name.in?(%w{needs neighbourhoods offers})
  end
  
  def messages_badge(message_count)
    if message_count > 0
      out = content_tag(:span, message_count, :class => 'badge')
      out + content_tag(:span, " message#{message_count > 1 ? 's' : ''}", :class => "request-message-text")
    else
      content_tag(:span, "No messages", :class => "request-message-text")
    end
  end
  
  def header_messages_badge(message_count, options = {})
    if message_count > 0
      out = content_tag(:span, message_count, :class => 'badge badge-info')
      out + " message#{message_count > 1 ? 's' : ''}"
    else
      "No messages"
    end
  end
  
end
