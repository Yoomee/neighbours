class MessagesController < ApplicationController

  include YmMessages::MessagesController

  def create
    @message.user = current_user
    @message.send(:set_thread)
    authorize!(:create, @message)
    if @message.save
      flash[:notice] = 'Your message has been sent'
      @message.thread.update_attribute(:context, "NCH") if params[:context] == "1"
      redirect_to @message.thread
    elsif @message.thread.messages.count > 0
      @message_thread = @message.thread
      @messages = @message_thread.messages.reorder('messages.created_at DESC').paginate(:per_page => 10, :page => params[:page])
      @last_message = @messages.first
      render :template => 'message_threads/show'
    else
      render :action => 'new'
    end
  end

end