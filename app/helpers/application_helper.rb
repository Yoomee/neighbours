module ApplicationHelper
  
  def neighbourhood
    "Maltby"
  end
  
  def show_control_panel?
    return false unless current_user
    controller_name.in?(%w{needs offers})
  end
  
  def messages_badge(message_count)
    if message_count > 0
      out = content_tag(:span, message_count, :class => 'badge')
      out + content_tag(:span, " Message#{message_count > 1 ? 's' : ''}", :class => "request-message-text")
    else
      content_tag(:span, "0 Messages", :class => "request-message-text")
    end
  end
  
  def header_messages_badge(message_count, options = {})
    if message_count > 0
      out = content_tag(:span, message_count, :class => 'badge badge-info')
      out + " Message#{message_count > 1 ? 's' : ''}"
    else
      "0 Messages"
    end
  end
  
end
