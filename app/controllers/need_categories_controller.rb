class NeedCategoriesController < ApplicationController
  load_and_authorize_resource
  
  def index
    @need_categories = NeedCategory.order(:name)
  end
  
  def create
    if @need_category.save
      redirect_to need_categories_path
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @need_category.destroy
    redirect_to need_categories_path
  end
  
  def update
    if @need_category.update_attributes(params[:need_category])
      redirect_to need_categories_path
    else
      render :action => 'edit'
    end
  end
end