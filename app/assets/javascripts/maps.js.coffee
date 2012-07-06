DEFAULT_LOCATION = [58.031372,-4.086914]

window.UsersMap =
	init: ->
    mapOptions = {
      center: new google.maps.LatLng(DEFAULT_LOCATION[0],DEFAULT_LOCATION[1]),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      streetViewControl: false,
      zoom: 12
    }
    
    UsersMap.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
    UsersMap.infowindow = new google.maps.InfoWindow({maxWidth: 400})

    bounds = new google.maps.LatLngBounds
    for user in UsersMap.users
      marker = new google.maps.Marker({
          position: new google.maps.LatLng(user.lat, user.lng),
          map: UsersMap.map,
          title:user.full_name
      });
      bounds.extend(marker.position)
      marker.userId = user.id
      marker.contentString = "<div class='user-infowindow'><h3>#{user.full_name}</h3><p>#{user.house_number} #{user.street_name}</p><a href='/users/#{user.id}'>View profile &rarr;</a></div>"

      google.maps.event.addListener marker, 'click', ->
        UsersMap.infowindow.close()
        UsersMap.infowindow.setContent(this.contentString)
        UsersMap.infowindow.open(UsersMap.map,this);
    
    if UsersMap.users.length  
      UsersMap.map.setCenter(bounds.getCenter())

window.NeedsMap =
	init: ->
    mapOptions = {
      center: new google.maps.LatLng(DEFAULT_LOCATION[0],DEFAULT_LOCATION[1]),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      streetViewControl: false,
      zoom: 12
    }
    
    NeedsMap.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
    NeedsMap.infowindow = new google.maps.InfoWindow({maxWidth: 400})

    bounds = new google.maps.LatLngBounds
    for need in NeedsMap.needs
      marker = new google.maps.Marker({
          position: new google.maps.LatLng(need.lat, need.lng),
          map: NeedsMap.map,
          title:need.name
      });
      bounds.extend(marker.position)
      marker.needId = need.id
      marker.contentString = "<div class='need-infowindow'><h3>#{need.title}</h3><p>#{need.street_name}</p><a href='/needs/#{need.id}'>View request &rarr;</a></div>"

      google.maps.event.addListener marker, 'click', ->
        NeedsMap.infowindow.close()
        NeedsMap.infowindow.setContent(this.contentString)
        NeedsMap.infowindow.open(NeedsMap.map,this);
    
    if NeedsMap.needs.length  
      NeedsMap.map.setCenter(bounds.getCenter())
