class PhotosController < ApplicationController

  load_resource :group
  load_and_authorize_resource :through => :group

  def create
    @photo = @group.photos.build(params[:photo])
    if @photo.save
      flash[:notice] = "Photo uploaded"
      redirect_to group_photos_path(@group)
    else
      render :action => 'new'
    end
  end

  def index
    @photos = @group.photos
  end
  
  def new
  end
  
  def show
    render :layout => false
  end

end