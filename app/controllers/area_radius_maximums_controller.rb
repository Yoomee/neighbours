class AreaRadiusMaximumsController < ApplicationController
  load_and_authorize_resource

  def index
    @neighbourhood = Neighbourhood.find_by_name("Sheffield")
    AreaRadiusMaximum.find_all_postcode_fragments_and_create_new_area_radium_maximums
  end

end
