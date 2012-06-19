class WireframesController < ApplicationController
    
  def show
    render :template => "wireframes/#{params[:id]}", :layout => !(params[:layout] == "false")
  end
  
  def index
    wireframes = Dir.new(Rails.root + "app/views/wireframes").entries.select{|f| f.match(/html/)}.map{|f| f.split(/\./)[0]}
     render :inline => "
        <h1>Wireframes</h1>
        <ul>
        <%wireframes.each do |wireframe|%>
          <li>
            <%=link_to(wireframe.titleize, (wireframe_path(wireframe) + (wireframe =~ /_nl$/ ? '?layout=false' : '')), :target => '_blank')%>
          </li>
        <%end%>
      </ul>",
      :locals => { :wireframes => wireframes }
     
  end
  
end