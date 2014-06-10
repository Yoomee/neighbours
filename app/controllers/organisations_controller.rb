class OrganisationsController < ApplicationController
  load_and_authorize_resource
  
  def index

  end

  def create
    @organisation.attributes = params[:organisation]
    if @organisation.save
      flash_notice(@organisation)
      redirect_to organisations_path
    else
      flash_notice(@organisation)      
      redirect_to edit_organisation_path(@organisation)
    end
  end

  def edit
     
  end

  def update
    @organisation.attributes = params[:organisation]
    if @organisation.save
      flash_notice(@organisation)
      redirect_to organisations_path
    else
      flash_notice(@organisation)      
      redirect_to edit_organisation_path(@organisation)
    end
  end

  def new


  end

  def destroy
    User.where(:organisation_id => @organisation.id).each{|u|u.update_attribute('organisation_id', nil)}
    if @organisation.destroy
      flash_notice(@organisation)
      redirect_to organisations_path
    end    
  end


end