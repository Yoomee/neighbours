module ImageHelper
  def image_for_with_validation(object, geo_string, options = {})
    if current_user.validated?
      image_for(object, geo_string, options)
    else
      dragonfly_image_tag(object.default_image, geo_string, options)
    end
  end
  
end