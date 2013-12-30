class NeighbourhoodsController < ApplicationController
  load_and_authorize_resource
  
  skip_before_filter :set_neighbourhood, :except => [:about, :help, :news]

  helper_method :sort_direction

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
    @general_offers = GeneralOffer.order("created_at desc")
    @removed_general_offers = GeneralOffer.unscoped.where('removed_at IS NOT NULL').order("removed_at desc")

    case params[:sort]
    when 'created_at'
      @general_offers = GeneralOffer.order("created_at #{params[:direction]}")
    when 'removed_at'
      @removed_general_offers = GeneralOffer.unscoped.where('removed_at IS NOT NULL').order("removed_at #{params[:direction]}")
    when 'category_id'
      @general_offers = GeneralOffer.unscoped.order("category_id #{params[:direction]}")
      @removed_general_offers = GeneralOffer.unscoped.where('removed_at IS NOT NULL').order("category_id #{params[:direction]}")
    when 'name'
      @general_offers = GeneralOffer.unscoped.joins(:user).order("users.last_name, users.first_name")
      @removed_general_offers = GeneralOffer.unscoped.where('removed_at IS NOT NULL').joins(:user).order("users.last_name, users.first_name")
    end
  end

  def stats
    @neighbourhood = Neighbourhood.find_by_id(params[:id])

    @needs_open = @neighbourhood.needs.unresolved.order("created_at desc")
    @needs_resolved = @neighbourhood.needs.resolved.order("created_at desc")
    @needs_removed = @neighbourhood.needs.removed.order("created_at desc")

    @offers_open = @neighbourhood.offers.open_offers.order("created_at desc")
    @offers_accepted = @neighbourhood.offers.accepted.order("created_at desc")
    @offers_removed = @neighbourhood.offers.removed.order("created_at desc")
      
    case params[:sort]
    when 'created_at'
      @needs_open = @neighbourhood.needs.unresolved.order("created_at #{params[:direction]}")
      @needs_resolved = @neighbourhood.needs.resolved.order("created_at #{params[:direction]}")
      @needs_removed = @neighbourhood.needs.removed.order("created_at #{params[:direction]}")

      @offers_open = @neighbourhood.offers.open_offers.order("created_at #{params[:direction]}")
      @offers_accepted = @neighbourhood.offers.accepted.order("created_at #{params[:direction]}")
      @offers_removed = @neighbourhood.offers.removed.order("created_at #{params[:direction]}")
    when 'accepted'    
      @offers_removed = @neighbourhood.offers.order("accepted #{params[:direction]}")
    when 'resolved'
      @needs_removed = @neighbourhood.needs.removed.resolved + @neighbourhood.needs.removed.unresolved
    when 'category_id'
      @needs_open = @neighbourhood.needs.unresolved.joins(:category).order("need_categories.name #{params[:direction]}")
      @needs_resolved = @neighbourhood.needs.resolved.joins(:category).order("need_categories.name #{params[:direction]}")
      @needs_removed = @neighbourhood.needs.removed.joins(:category).order("need_categories.name #{params[:direction]}")

      @offers_open = @neighbourhood.offers.open_offers.joins(:category).order("need_categories.name #{params[:direction]}")
      @offers_accepted = @neighbourhood.offers.accepted.joins(:category).order("need_categories.name #{params[:direction]}")
      @offers_removed = @neighbourhood.offers.removed.joins(:category).order("need_categories.name #{params[:direction]}")
    when 'name'
      @needs_open = @neighbourhood.needs.unresolved.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @needs_resolved = @neighbourhood.needs.resolved.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @needs_removed = @neighbourhood.needs.removed.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")

      @offers_open = @neighbourhood.offers.open_offers.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @offers_accepted = @neighbourhood.offers.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @offers_removed = @neighbourhood.offers.removed.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
    when 'name_secondary'
      @needs_resolved = @neighbourhood.offers.accepted.includes(:need).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:need)

      @offers_open = Need.where(id: @neighbourhood.offers.open_offers.select(:need_id)).joins(:user).includes(:offers).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:offers).flatten.uniq
      @offers_accepted = @neighbourhood.needs.resolved.includes(:accepted_offer).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:accepted_offer)
      @offers_removed = Need.where(id: @neighbourhood.offers.removed.select(:need_id)).joins(:user).includes(:offers).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:offers).flatten.uniq
    end


  end

  private 
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end