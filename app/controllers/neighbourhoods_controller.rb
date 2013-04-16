class NeighbourhoodsController < ApplicationController
  load_and_authorize_resource
  
  skip_before_filter :set_neighbourhood, :except => [:about, :help, :news]

  include YmSnippets::SnippetsHelper
  
  def about
    @neighbourhood = Neighbourhood.find_by_id(params[:neighbourhood]) || current_user.try(:neighbourhood)
  end

  def area
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

  def help
    @neighbourhood = Neighbourhood.find_by_id(params[:neighbourhood]) || current_user.try(:neighbourhood)
    help_parent = Page.find_or_create_by_slug('neighbourhood_help', :title => "Neighbourhood help pages")
    @page = Page.find_or_create_by_parent_id_and_neighbourhood_id(help_parent.id, @neighbourhood.id, :title => 'Help')
    render "/pages/views/#{@page.view_name}"
  end
  
  def news
    @neighbourhood = Neighbourhood.find_by_id(params[:neighbourhood]) || current_user.try(:neighbourhood)
    @page = Page.find_by_slug(:news)
    @page_children = @page.children.where(:neighbourhood_id => @neighbourhood.id) || []
    render "/pages/views/#{@page.view_name}"
  end

  def show
    @neighbourhood = Neighbourhood.find_by_id(params[:id]) || current_user.try(:neighbourhood)
    @helped = get_at_least(20, Need.resolved.order(:created_at).reverse_order)
    @need_help = get_at_least(20, Need.unresolved.order(:created_at).reverse_order)
    @unvalidated_map_needs = get_unvalidated_map_needs
    @needs_json = []
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
  
  def new_email
    
  end
  
  def create_email
    if params[:subject].blank? || params[:email_body].blank?
      render :action => 'new_email'
    else
      @neighbourhood.pre_registrations.each do |pre_registration|
        PreRegistrationMailer.delay.custom_email(pre_registration, params[:subject], params[:email_body])
      end
      flash[:notice] = "Sent #{@neighbourhood.pre_registrations.count} emails"
      redirect_to neighbourhoods_path
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
      [snippet_text(:unvalidated_map_need_1_url), snippet_text(:unvalidated_map_need_1_user), snippet_text(:unvalidated_map_need_1_text)],
      [snippet_text(:unvalidated_map_need_2_url), snippet_text(:unvalidated_map_need_2_user), snippet_text(:unvalidated_map_need_2_text)],
      [snippet_text(:unvalidated_map_need_3_url), snippet_text(:unvalidated_map_need_3_user), snippet_text(:unvalidated_map_need_3_text)]
    ]
    [snippet_needs[0], snippet_needs[1], snippet_needs[2], unresolved_needs[0], resolved_needs[0], unresolved_needs[1], resolved_needs[1]]
  end

end