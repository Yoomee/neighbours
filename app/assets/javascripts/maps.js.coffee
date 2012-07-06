DEFAULT_LOCATION = [53.426, -1.21]

window.UsersMap =
	init: ->
    mapOptions = {
      center: new google.maps.LatLng(DEFAULT_LOCATION[0],DEFAULT_LOCATION[1]),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      streetViewControl: false,
      mapTypeControl: false,
      zoom: 12
    }
    
    UsersMap.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
    UsersMap.infowindow = new google.maps.InfoWindow({maxWidth: 400})

    for user in UsersMap.users
      marker = new google.maps.Marker({
          position: new google.maps.LatLng(user.lat, user.lng),
          map: UsersMap.map,
          title:user.full_name
      });
      marker.userId = user.id
      marker.contentString = "<div class='user-infowindow'><h3>#{user.full_name}</h3><p>#{user.house_number} #{user.street_name}</p><a href='/users/#{user.id}'>View profile &rarr;</a></div>"

      google.maps.event.addListener marker, 'click', ->
        UsersMap.infowindow.close()
        UsersMap.infowindow.setContent(this.contentString)
        UsersMap.infowindow.open(UsersMap.map,this);

window.NeedsMap =
	init: ->
    mapOptions = {
      center: new google.maps.LatLng(DEFAULT_LOCATION[0],DEFAULT_LOCATION[1]),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      streetViewControl: false,
      mapTypeControl: false,
      zoom: 12
    }
    
    NeedsMap.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
    NeedsMap.infowindow = new google.maps.InfoWindow({maxWidth: 400})

    for need in NeedsMap.needs
      marker = new google.maps.Marker({
          position: new google.maps.LatLng(need.lat, need.lng),
          map: NeedsMap.map,
          title:need.name
      });
      marker.needId = need.id
      marker.contentString = "<div class='need-infowindow'><h3>#{need.title}</h3><p>#{need.street_name}</p><a href='/needs/#{need.id}'>View request &rarr;</a></div>"

      google.maps.event.addListener marker, 'click', ->
        NeedsMap.infowindow.close()
        NeedsMap.infowindow.setContent(this.contentString)
        NeedsMap.infowindow.open(NeedsMap.map,this);
