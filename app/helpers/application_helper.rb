module ApplicationHelper
  
  def neighbourhood
    "Maltby"
  end
  
  def show_control_panel?
    return false unless current_user
    controller_name.in?(%w{needs offers})
  end
  
end
