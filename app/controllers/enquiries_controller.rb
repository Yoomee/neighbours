class EnquiriesController < ApplicationController

  include YmEnquiries::EnquiriesController
  load_and_authorize_resource

  def create
    # debugger
    redirect_to root_url and return if params[:extra_message].present?
    @enquiry = Enquiry.new(params[:enquiry].merge(:form_name => params[:id]))
    if @enquiry.save
      YmEnquiries::EnquiryMailer.new_enquiry(@enquiry).deliver
      flash[:notice] = "#{@enquiry.response_message}"
      redirect_to root_url
    else
      render :action => 'new'
    end
  end


  def new
    if params[:id].nil?
      render_404
    else
      begin
        attrs = {:form_name => params[:id].to_s}
        if attrs[:form_name] == "feedback" && current_user
          attrs.merge!(current_user.attributes.slice("first_name", "last_name", "email"))
        elsif attrs[:form_name] == "other_neighbourhood" && current_user
          attrs.merge!(current_user.attributes.slice("first_name", "last_name", "email"))
        end
        @enquiry = Enquiry.new(attrs)
      rescue NameError
        render_404
      end
    end
  end

end
