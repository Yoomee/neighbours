class MessageThreadsController < ApplicationController

  include YmMessages::MessageThreadsController

  def index
    if params[:context].present?
      @message_threads = current_user.threads.where(:context => "NCH").order('updated_at DESC').paginate(:per_page => 50, :page => params[:page]) if params[:context] == "NCH"
    else
      @message_threads = current_user.threads.order('updated_at DESC').paginate(:per_page => 50, :page => params[:page])
    end
  end

end