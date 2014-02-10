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

    respond_to do |format|
      format.html {}
      format.xls do
        case params[:type]
          when 'needs'
            @resource = Need.all
          when 'offers'
            @resource = Offer.all
          when 'general_offers'
            @resource = GeneralOffer.all
        end
        headers["Content-Disposition"] = "attachment; filename=\"#{params[:type]} #{Date.today.strftime('%d-%m-%Y')}.xls\""
      end
    end

    @resources = {"Open Needs" => Need.unresolved.order("created_at desc"), "Resolved Needs" => Need.resolved.order("created_at desc"), "Removed Needs" => Need.removed.order("created_at desc"), "General Offers" => GeneralOffer.order("created_at desc"), "Removed General Offers" => GeneralOffer.unscoped.where('removed_at IS NOT NULL').order("removed_at desc"), "Open Offers" => Offer.open_offers.order("created_at desc"), "Accepted Offers" => Offer.accepted.order("created_at desc"), "Removed Offers" => Offer.removed.order("created_at desc")}

    case params[:sort]
    when 'created_at'
      @resources["General Offers"] = GeneralOffer.order("created_at #{params[:direction]}")
      @resources["Open Needs"] = Need.unresolved.order("created_at #{params[:direction]}")
      @resources["Resolved Needs"] = Need.resolved.order("created_at #{params[:direction]}")
      @resources["Removed Needs"] = Need.removed.order("created_at #{params[:direction]}")

      @resources["Open Offers"] = Offer.open_offers.order("created_at #{params[:direction]}")
      @resources["Accepted Offers"] = Offer.accepted.order("created_at #{params[:direction]}")
      @resources["Removed Offers"] = Offer.removed.order("created_at #{params[:direction]}")
    when 'accepted'    
      @resources["Removed Offers"] = Offer.order("accepted #{params[:direction]}")
    when 'resolved'
      @resources["Removed Needs"] = Need.removed.resolved + Need.removed.unresolved
    when 'removed_at'
      @resources["Removed General Offers"] = GeneralOffer.unscoped.where('removed_at IS NOT NULL').order("removed_at #{params[:direction]}")
    when 'category_id'
      @resources["General Offers"] = GeneralOffer.unscoped.order("category_id #{params[:direction]}")
      @resources["Removed General Offers"] = GeneralOffer.unscoped.where('removed_at IS NOT NULL').order("category_id #{params[:direction]}")

      @resources["Open Needs"] = Need.unresolved.joins(:category).order("need_categories.name #{params[:direction]}")
      @resources["Resolved Needs"] = Need.resolved.joins(:category).order("need_categories.name #{params[:direction]}")
      @resources["Removed Needs"] = Need.removed.joins(:category).order("need_categories.name #{params[:direction]}")

      @resources["Open Offers"] = Offer.open_offers.joins(:category).order("need_categories.name #{params[:direction]}")
      @resources["Accepted Offers"] = Offer.accepted.joins(:category).order("need_categories.name #{params[:direction]}")
      @resources["Removed Offers"] = Offer.removed.joins(:category).order("need_categories.name #{params[:direction]}")
    when 'name'
      @resources["General Offers"] = GeneralOffer.unscoped.joins(:user).order("users.last_name, users.first_name")
      @resources["Removed General Offers"] = GeneralOffer.unscoped.where('removed_at IS NOT NULL').joins(:user).order("users.last_name, users.first_name")

      @resources["Open Needs"] = Need.unresolved.joins(:user).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @resources["Resolved Needs"] = Need.resolved.joins(:user).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @resources["Removed Needs"] = Need.removed.joins(:user).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")

      @resources["Open Offers"] = Offer.open_offers.joins(:user).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @resources["Accepted Offers"] = Offer.joins(:user).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @resources["Removed Offers"] = Offer.removed.joins(:user).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
    when 'name_secondary'
      @resources["Resolved Needs"] = Offer.accepted.joins(:user).includes(:need).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:need)

      @resources["Open Offers"] = Need.where(id:Offer.open_offers.select(:need_id)).joins(:user).includes(:offers).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:offers).flatten.uniq
      @resources["Accepted Offers"] = Need.resolved.joins(:user).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:accepted_offer)
      @resources["Removed Offers"] = Need.where(id: Offer.removed.select(:need_id)).joins(:user).includes(:offers).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:offers).flatten.uniq
    when 'postcode'
      @resources["General Offers"] = GeneralOffer.joins(:user).order("users.postcode #{params[:direction]}")
      @resources["Removed General Offers"] = GeneralOffer.unscoped.where('removed_at IS NOT NULL').joins(:user).order("users.postcode #{params[:direction]}")


      @resources["Open Needs"] = Need.unresolved.joins(:user).order("users.postcode #{params[:direction]}")
      @resources["Resolved Needs"] = Need.resolved.joins(:user).order("users.postcode #{params[:direction]}")
      @resources["Removed Needs"] = Need.removed.joins(:user).order("users.postcode #{params[:direction]}")

      @resources["Open Offers"] = Offer.open_offers.joins(:need_user).order('users.postcode')
      @resources["Accepted Offers"] = Offer.accepted.joins(:need_user).order('users.postcode')
      @resources["Removed Offers"] = Offer.removed.joins(:need_user).order('users.postcode')
    end

  end

  def stats
    @neighbourhood = Neighbourhood.find_by_id(params[:id])

    @resources = {"Open Needs" => @neighbourhood.needs.unresolved.order("created_at desc"), "Resolved Needs" => @neighbourhood.needs.resolved.order("created_at desc"), "Removed Needs" => @neighbourhood.needs.removed.order("created_at desc"), "Open Offers" => @neighbourhood.offers.open_offers.order("created_at desc"), "Accepted Offers" => @neighbourhood.offers.accepted.order("created_at desc"), "Removed Offers" => @neighbourhood.offers.removed.order("created_at desc")}
      
    case params[:sort]
    when 'created_at'
      @resources["Open Needs"] = @neighbourhood.needs.unresolved.order("created_at #{params[:direction]}")
      @resources["Resolved Needs"] = @neighbourhood.needs.resolved.order("created_at #{params[:direction]}")
      @resources["Removed Needs"] = @neighbourhood.needs.removed.order("created_at #{params[:direction]}")

      @resources["Open Offers"] = @neighbourhood.offers.open_offers.order("created_at #{params[:direction]}")
      @resources["Accepted Offers"] = @neighbourhood.offers.accepted.order("created_at #{params[:direction]}")
      @resources["Removed Offers"] = @neighbourhood.offers.removed.order("created_at #{params[:direction]}")
    when 'accepted'    
      @resources["Removed Offers"] = @neighbourhood.offers.order("accepted #{params[:direction]}")
    when 'resolved'
      @resources["Removed Needs"] = @neighbourhood.needs.removed.resolved + @neighbourhood.needs.removed.unresolved
    when 'category_id'
      @resources["Open Needs"] = @neighbourhood.needs.unresolved.joins(:category).order("need_categories.name #{params[:direction]}")
      @resources["Resolved Needs"] = @neighbourhood.needs.resolved.joins(:category).order("need_categories.name #{params[:direction]}")
      @resources["Removed Needs"] = @neighbourhood.needs.removed.joins(:category).order("need_categories.name #{params[:direction]}")

      @resources["Open Offers"] = @neighbourhood.offers.open_offers.joins(:category).order("need_categories.name #{params[:direction]}")
      @resources["Accepted Offers"] = @neighbourhood.offers.accepted.joins(:category).order("need_categories.name #{params[:direction]}")
      @resources["Removed Offers"] = @neighbourhood.offers.removed.joins(:category).order("need_categories.name #{params[:direction]}")
    when 'name'
      @resources["Open Needs"] = @neighbourhood.needs.unresolved.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @resources["Resolved Needs"] = @neighbourhood.needs.resolved.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @resources["Removed Needs"] = @neighbourhood.needs.removed.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")

      @resources["Open Offers"] = @neighbourhood.offers.open_offers.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @resources["Accepted Offers"] = @neighbourhood.offers.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
      @resources["Removed Offers"] = @neighbourhood.offers.removed.order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}")
    when 'name_secondary'
      @resources["Resolved Needs"] = @neighbourhood.offers.accepted.includes(:need).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:need)

      @resources["Open Offers"] = Need.where(id: @neighbourhood.offers.open_offers.select(:need_id)).joins(:user).includes(:offers).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:offers).flatten.uniq
      @resources["Accepted Offers"] = @neighbourhood.needs.resolved.includes(:accepted_offer).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:accepted_offer)
      @resources["Removed Offers"] = Need.where(id: @neighbourhood.offers.removed.select(:need_id)).joins(:user).includes(:offers).order("users.last_name #{params[:direction]}, users.first_name #{params[:direction]}").collect(&:offers).flatten.uniq
    end


  end

  private 
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end