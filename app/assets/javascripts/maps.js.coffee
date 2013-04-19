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


window.PreRegistrationMap =
	init: ->
    mapOptions = {
      center: new google.maps.LatLng(DEFAULT_LOCATION[0],DEFAULT_LOCATION[1]),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      streetViewControl: false,
      mapTypeControl: false,
      zoom: 6
    }

    PreRegistrationMap.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
    PreRegistrationMap.infowindow = new google.maps.InfoWindow({maxWidth: 400})
       
    markers = []
    
    oms = new OverlappingMarkerSpiderfier(PreRegistrationMap.map, {keepSpiderfied: true})
    oms.addListener 'click', (marker) ->
      PreRegistrationMap.infowindow.setContent(marker.contentString);
      PreRegistrationMap.infowindow.open(PreRegistrationMap.map, marker);
      
    oms.addListener 'spiderfy', (markers) ->
      PreRegistrationMap.infowindow.close()
        
    for user in PreRegistrationMap.users
      marker = new google.maps.Marker({
          position: new google.maps.LatLng(user.lat_lng[0], user.lat_lng[1]),
          title:user.name
      });
      marker.userId = user.id
      marker.contentString = "<div class='user-infowindow'><h3>#{user.name}</h3><p>#{user.email}<br/>#{user.postcode}<br/>#{user.area}</p></div>"
      
      oms.addMarker(marker)
      markers.push(marker)


    markerClustererOptions =
      gridSize: 50
      maxZoom: 19
    markerClusterer = new MarkerClusterer(PreRegistrationMap.map,markers,markerClustererOptions)
    
   # google.maps.event.addListener marker, 'click', ->
   #      PreRegistrationMap.infowindow.close()
   #      PreRegistrationMap.infowindow.setContent(this.contentString)
   #      PreRegistrationMap.infowindow.open(PreRegistrationMap.map,this);



window.NeedsMap =
	init: (admin)->
    admin ||= false
    mapOptions = {
      center: new google.maps.LatLng(user_lat,user_lng),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      streetViewControl: false,
      mapTypeControl: false,
      maxZoom: 15,      
      zoom: 15
    }
    
    NeedsMap.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
    NeedsMap.infowindow = new google.maps.InfoWindow({maxWidth: 400})

    for need in NeedsMap.needs
      marker = new google.maps.Marker({
        position: new google.maps.LatLng(need.lat, need.lng),
        map: NeedsMap.map,
        title:need.name,
        icon: 
          path: google.maps.SymbolPath.CIRCLE,
          fillColor: "#abd424",
          strokeColor: "#67c621",
          fillOpacity: 0.5,
          strokeOpacity: 0,
          strokeWeight: 1,
          scale: 20
      })
      if admin
        new google.maps.Circle({
          strokeColor: "#0080FF",
          strokeOpacity: 0.8,
          strokeWeight: 1,
          fillColor: "#0080FF",
          fillOpacity: 0.5,
          map: NeedsMap.map,
          center: marker.position,
          radius: need.radius
        })
      marker.needId = need.id
      marker.contentString = "<div class='need-infowindow'><h3>#{need.title}</h3><p>#{need.street_name}</p><a href='/needs/#{need.id}'>View request &rarr;</a></div>"
    
      google.maps.event.addListener marker, 'click', ->
        NeedsMap.infowindow.close()
        NeedsMap.infowindow.setContent(this.contentString)
        NeedsMap.infowindow.open(NeedsMap.map,this)

    for user in NeedsMap.users
      marker = new google.maps.Marker({
        position: new google.maps.LatLng(user.lat, user.lng),
        map: NeedsMap.map,
        title:user.first_name,
        icon: 
          path: google.maps.SymbolPath.CIRCLE,
          fillColor: 'gray',
          fillOpacity: 0.6,
          strokeOpacity: 0,            
          scale: 20
      })
      marker.contentString = "<div class='user-infowindow'><h3>#{user.first_name}</h3><p>#{user.street_name}</p></div>"

      google.maps.event.addListener marker, 'click', ->
        NeedsMap.infowindow.close()
        NeedsMap.infowindow.setContent(this.contentString)
        NeedsMap.infowindow.open(NeedsMap.map,this)
        
    for general_offer in NeedsMap.general_offers
      marker = new google.maps.Marker({
        position: new google.maps.LatLng(general_offer.lat, general_offer.lng),
        map: NeedsMap.map,
        title: general_offer.title,
        icon: 
          path: google.maps.SymbolPath.CIRCLE,
          fillColor: '#f8bb61',
          fillOpacity: 0.8,
          strokeOpacity: 0,            
          scale: 20
      })
      marker.generalOfferId = general_offer.id
      marker.contentString = "<div class='user-infowindow'><h3>#{general_offer.title}</h3><p>#{general_offer.street_name}</p><a href='/general_offers/#{general_offer.id}'>View offer &rarr;</a></div>"

      google.maps.event.addListener marker, 'click', ->
        NeedsMap.infowindow.close()
        NeedsMap.infowindow.setContent(this.contentString)
        NeedsMap.infowindow.open(NeedsMap.map,this)
    

