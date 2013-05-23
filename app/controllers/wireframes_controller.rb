class WireframesController < ApplicationController
  
  def show
    wireframe_path = "wireframes/#{params[:id]}"
    show_layout = true
    if template_exists?("#{wireframe_path}_nl")
      wireframe_path = "#{wireframe_path}_nl"
      show_layout = false
    end
    render :template => wireframe_path, :layout => show_layout
  end
  
  def index
    wireframes = Dir.new(Rails.root + "app/views/wireframes").entries.select{|f| f.match(/html/)}.map{|f| f.split(/\./)[0]}
     render :inline => "
        <h1>Wireframes</h1>
        <ul>
        <%wireframes.each do |wireframe|%>
          <li>
            <%=link_to(wireframe.chomp('_nl').titleize, wireframe_path(wireframe.chomp('_nl')), :target => '_blank')%>
          </li>
        <%end%>
      </ul>",
      :locals => { :wireframes => wireframes }
     
  end
  
end