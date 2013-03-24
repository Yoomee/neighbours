class PagesController < ApplicationController
  include YmCms::PagesController

  def destroy
    @page.destroy
    flash_notice(@page)
    redirect_to root_path
  end

  def show
    @page_children = @page.children.where('neighbourhood_id IS NULL') || []
    render :action => "views/#{@page.view_name}"
  end

end