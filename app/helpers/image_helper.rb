module ImageHelper
  def image_for_with_validation(object, geo_string, options = {})
    if current_user.try(:validated?) || object_is_a_user_in_the_same_group_as_current_user?(object)
      image_for(object, geo_string, options)
    else
      dragonfly_image_tag(object.default_image, geo_string, options)
    end
  end

  def object_is_a_user_in_the_same_group_as_current_user?(object)
    current_user && object.is_a?(User) && (object.groups & current_user.groups).present?
  end
  
end