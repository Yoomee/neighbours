class PagesController < ApplicationController
  include YmCms::PagesController

  def destroy
    @page.destroy
    flash_notice(@page)
    redirect_to root_path
  end

  def show
    if @page == Page.find_by_slug(:get_involved)
      @page_children =  @page.children.where('neighbourhood_id IS NULL').order(:position) || []
    elsif current_user
      @page_children = @page.children.where("neighbourhood_id IS NULL OR neighbourhood_id = #{current_user.neighbourhood_id || 0} ").latest || []
    else
      @page_children = @page.children.where("neighbourhood_id IS NULL").latest || []
    end
    render :action => "views/#{@page.view_name}"
  end

  def new
    unless current_user.validated?
      flash[:notice] = "You will be able to access this page once you are validated."
      redirect_to root_path
    end
  end

end