class SlideshowsController < ApplicationController
  include YmCms::SlideshowsController

  def create
    if @slideshow.save
      flash_notice(@slideshow)
      redirect_to @slideshow
    else
      if @slideshow.slug == "homepage_slideshow" && @slideshow.errors.full_messages == ["Slug has already been taken"]
        flash[:error] = "You already have a slideshow set to be the homepage slideshow. Please change this setting before making this the homepage slideshow."
      end
      render :action => "new"
    end
  end

  def update
    if @slideshow.update_attributes(params[:slideshow])
      redirect_to @slideshow
    else
      if @slideshow.slug == "homepage_slideshow" && @slideshow.errors.full_messages == ["Slug has already been taken"]
        flash[:error] = "You already have a slideshow set to be the homepage slideshow. Please change this setting before making this the homepage slideshow."
      end
      render :action => "edit"
    end
  end
end
