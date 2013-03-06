class NeighbourhoodsController < ApplicationController
  load_and_authorize_resource

  include YmSnippets::SnippetsHelper

  def show
    # if current_user && !current_user.is_in_sheffield?
    if false  
      params[:id] = "other_neighbourhood"
      @enquiry = Enquiry.new(:form_name => "other_neighbourhood", :first_name => current_user.first_name, :last_name => current_user.last_name, :email => current_user.email)
      render :template => "enquiries/new"
    else
      if current_user
        @needs_json = Need.unresolved.with_lat_lng.visible_to_user(current_user).to_json(:only => [:id], :methods => [:lat, :lng, :street_name, :title, :user_first_name])
        @helped = get_at_least(20, Need.resolved.visible_to_user(current_user).order(:created_at).reverse_order)
        @need_help = get_at_least(20,Need.unresolved.visible_to_user(current_user).where("needs.user_id != ?", current_user.id).order(:created_at).reverse_order)
      else
        if @neighbourhood = Neighbourhood.find_by_id(params[:id])
          @email_share_params = "neighbourhood=#{@neighbourhood.id}"
          render :action => "coming_soon"
        else          
          @helped = get_at_least(20, Need.resolved.order(:created_at).reverse_order)
          @need_help = get_at_least(20, Need.unresolved.order(:created_at).reverse_order)
          @unvalidated_map_needs = get_unvalidated_map_needs
          @needs_json = []
        end
      end
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

  private
  def get_at_least(num, needs_sent)
    needs = needs_sent.dup
    needs.pop if needs.size.odd? && needs.size > num
    count = 0
    all_needs = needs
    (num - needs.size).times do |i|
      all_needs << needs[count] if needs[count]
      count = (count >= (needs.size - 1)) ? 0 : count + 1
    end
    all_needs
  end

  def get_unvalidated_map_needs
    unresolved_needs = Need.unresolved.order(:created_at).reverse_order.limit(2).collect {|n| ["/needs/#{n.id}", "#{n.user.to_s} needs help with", n.category]}
    resolved_needs = Need.resolved.order(:created_at).reverse_order.limit(2).collect {|n| ["/needs/#{n.id}", "#{n.accepted_offer.user.to_s} helped #{n.user.to_s}", n.category]}
    snippet_needs = [
      [neighbourhood_neighbourhood_neighbourhood_snippet_text(:unvalidated_map_need_1_url), neighbourhood_neighbourhood_snippet_text(:unvalidated_map_need_1_user), neighbourhood_neighbourhood_snippet_text(:unvalidated_map_need_1_text)],
      [neighbourhood_neighbourhood_snippet_text(:unvalidated_map_need_2_url), neighbourhood_neighbourhood_snippet_text(:unvalidated_map_need_2_user), neighbourhood_neighbourhood_snippet_text(:unvalidated_map_need_2_text)],
      [neighbourhood_neighbourhood_snippet_text(:unvalidated_map_need_3_url), neighbourhood_neighbourhood_snippet_text(:unvalidated_map_need_3_user), neighbourhood_neighbourhood_snippet_text(:unvalidated_map_need_3_text)]
    ]
    [snippet_needs[0], snippet_needs[1], snippet_needs[2], unresolved_needs[0], resolved_needs[0], unresolved_needs[1], resolved_needs[1]]
  end

end