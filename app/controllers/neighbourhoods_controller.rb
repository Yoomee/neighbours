class NeighbourhoodsController < ApplicationController
  load_and_authorize_resource
  
  skip_before_filter :set_neighbourhood, :except => [:about, :help, :news]

  helper_method :sort_column, :sort_direction

  include YmSnippets::SnippetsHelper
  
  def about
    @neighbourhood = Neighbourhood.find_by_id(params[:neighbourhood]) || current_user.try(:neighbourhood)
  end

  def help
    @neighbourhood = Neighbourhood.find_by_id(params[:neighbourhood]) || current_user.try(:neighbourhood)
    help_parent = Page.find_or_create_by_slug('neighbourhood_help', :title => "Neighbourhood help pages")
    @page = Page.find_or_create_by_parent_id_and_neighbourhood_id(help_parent.id, @neighbourhood.id, :title => 'Help', :text => Page.find_by_slug('help').text)
    render "/pages/views/#{@page.view_name}"
  end
  
  def news
    @neighbourhood = Neighbourhood.find_by_id(params[:neighbourhood]) || current_user.try(:neighbourhood)
    @page = Page.find_by_slug(:news)
    @page_children = @page.children.where(:neighbourhood_id => @neighbourhood.id) || []
    render "/pages/views/#{@page.view_name}"
  end

  def show
    @neighbourhood = Neighbourhood.find_by_id(params[:id])
    @email_share_params = "neighbourhood=#{@neighbourhood.id}"    
    if current_user.try(:has_lat_lng?)
      @users_json = User.visible_to_user(current_user).to_json(:only => [:id, :lat, :lng, :street_name, :first_name])      
      needs = Need.unresolved.with_lat_lng.visible_to_user(current_user)
      @needs_json = needs.to_json(:only => [:id], :methods => [:lat, :lng, :street_name, :title, :user_first_name])
      general_offers = GeneralOffer.visible_to_user(current_user).order(:created_at).reverse_order
      @general_offers_json = general_offers.to_json(:only => [:id], :methods => [:lat, :lng, :street_name, :title, :user_first_name])
    else
      render :action => 'coming_soon'
    end
  end
  
  def create
    if @neighbourhood.save
       flash_notice @neighbourhood
       redirect_to neighbourhoods_path
    else    
       render :action => "new"
    end
  end
  
  def destroy
    if @neighbourhood.destroy
      flash_notice @neighbourhood
    else
      flash_error @neighbourhood
    end
    redirect_to neighbourhoods_path
  end
  
  def snippets
    @neighbourhood = Neighbourhood.find_by_id(params[:neighbourhood])
    if params[:commit]
      @neighbourhood.update_attributes(params[:slugs])
      flash[:notice]="Updated text snippets for #{@neighbourhood}"
      redirect_to neighbourhoods_path
    else
      @snippets = YmSnippets::Snippet.all
    end
  end
  
  def update
    if @neighbourhood.update_attributes(params[:neighbourhood])
      flash[:message] = "Area maximums updated"
    else
      flash[:error] = "Sorry. Something's gone wrong. Please try again."
    end
    redirect_to neighbourhoods_path
  end

  def all_stats
    @neighbourhoods = Neighbourhood.all

  end

  def stats
    @neighbourhood = Neighbourhood.find_by_id(params[:id])
    case params[:sort]    
    when 'created_at'
      @offers = @neighbourhood.offers.order("created_at #{params[:direction]}")
    when 'accepted'    
      @offers = @neighbourhood.offers.order("accepted #{params[:direction]}")
    else
      @offers = @neighbourhood.offers
    end

    case params[:sort]
    when 'created_at'
      @needs = @neighbourhood.needs.order("created_at #{params[:direction]}")  
    when 'resolved'
      @needs = @neighbourhood.needs.resolved + @neighbourhood.needs.unresolved
    when 'category_id'
      @needs = @neighbourhood.needs.order("category_id")
    else
      @needs = @neighbourhood.needs
    end
    
    @removed_needs = @neighbourhood.needs.where(:removed => 1)
  end

  private

  def sort_column
    %w[].include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end