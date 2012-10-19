module NeedHelper

  def need_radius_options
    logged_in? ? current_user.radius_options : Need.radius_options.select { |k,v| v <= AreaRadiusMaximum::DEFAULT_MAXIMUM.to_i }
  end

end