module NeedHelper

  def need_radius_options
    logged_in? ? current_user.radius_options : Need.radius_options(Neighbourhood::DEFAULT_MAX_RADIUS)
  end
  
  def show_deadline(need)
    if need.need_to_know_by == 'date'
      "by #{need.deadline.to_s(:long)}"
    else
      need.need_to_know_by
    end
  end

end