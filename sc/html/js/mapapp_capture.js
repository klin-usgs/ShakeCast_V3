MAPAPP = (function() {
    // initailise constants
    var DEFAULT_ZOOM = 8;
    
    // initialise variables
    var map = null,
	detailMapLayer = null,
	mgr = null,
	mc = null,
	fac_mc = null,
	smOverlay = null,
	smImg = null,
	epimarker = null;
        
    function loadSM(bounds, img) {
        // create a new marker to and display it on the map
		if (smOverlay) {
			smOverlay.setMap(null);
		}

		smImg = img;
		smBounds = bounds;
		if (smBounds) {
		smOverlay = new USGSOverlay(bounds, img, map);

		}
		map.setCenter(smBounds.getCenter(), DEFAULT_ZOOM);
    } // addMarker
    
    function addMarker(facility) {
		var lat, lon;
		var icon_type;
		
		if (facility.facility_type == "epicenter") {
			lat = parseFloat(facility.lat);
			lon = parseFloat(facility.lon);
			icon_type =  facility.facility_type;
			icon_type = icon_type.toLowerCase();
		} else {
			lat = parseFloat(facility.latitude);
			lon = parseFloat(facility.longitude);
			icon_type =  facility.facility_type + facility.damage_level;
			icon_type = icon_type.toLowerCase();
		}
		//MAPAPP.addMarker(new google.maps.LatLng(lat, lon), domdata);
		var markerimage  = new google.maps.MarkerImage("/images/" + icon_type + ".png",
			new google.maps.Size(25,25),
			new google.maps.Point(0,0),
			new google.maps.Point(12,12));				
			
		var marker = new google.maps.Marker({
			position: new google.maps.LatLng(lat, lon), 
			icon: markerimage,
			map: map,
		});
		//facMarkers.push(marker);
        
    } // addMarker
    
    
    var module = {
        addMarker: addMarker,
		loadSM: loadSM,
        
        init: function(position, zoomLevel, no_facility) {

            // define the required options
            var myOptions = {
                zoom: zoomLevel ? zoomLevel : DEFAULT_ZOOM,
                center: position,
				//overviewMapControl: true,
                //overviewMapControlOptions: {opened: true},

				disableDefaultUI: true,
				mapTypeId: google.maps.MapTypeId.TERRAIN,
            };

            // initialise the map
            map = new google.maps.Map(
                document.getElementById("map_canvas"),
                myOptions);
                
	    /* var map_questMapLayerOptions = {
	    getTileUrl: function(tile, zoom) {
		    //console.debug(X);
		    //return "/server_event.php?x="+tile.x+"&y="+tile.y+"&zoom="+zoom; },
		    var tilesAtThisZoom = 1 << zoom;
		    var tilex = tile.x % tilesAtThisZoom;
		    if (tilex < 0) {tilex = tilex + tilesAtThisZoom;}
		    //if (zoom > TILE_ZOOM) {
			    //return "/scripts/gmap.pl/event/"+tile.x+","+tile.y+","+zoom;
		    //} else {
			    return "./tiles/map_quest/"+zoom+"/"+tilex+"/"+tile.y+".png";
		    //}
		    },
	    tileSize: new google.maps.Size(256, 256),
	    isPng: true
	    };
	    map_questMapLayer = new google.maps.ImageMapType(map_questMapLayerOptions);
	    map.overlayMapTypes.insertAt("0",map_questMapLayer); */

			var detailsMapLayerOptions = {
			getTileUrl: function(tile, zoom) {
				//console.debug(X);
				//return "/server_event.php?x="+tile.x+"&y="+tile.y+"&zoom="+zoom; },
				var tilesAtThisZoom = 1 << zoom;
				var tilex = tile.x % tilesAtThisZoom;
				//if (zoom > TILE_ZOOM) {
					//return "/scripts/gmap.pl/event/"+tile.x+","+tile.y+","+zoom;
				//} else {
					return "/html/tiles/event/"+zoom+"/"+tilex+"/"+tile.y+".png";
				//}
				},
			tileSize: new google.maps.Size(256, 256),
			isPng: true
			};
			eventMapLayer = new google.maps.ImageMapType(detailsMapLayerOptions);
			//map.overlayMapTypes.insertAt("0",eventMapLayer);
			map.overlayMapTypes.insertAt("1", eventMapLayer);

			var facilityMapLayerOptions = {
			getTileUrl: function(tile, zoom) {
				//console.debug(X);
				//return "/server_event.php?x="+tile.x+"&y="+tile.y+"&zoom="+zoom; },
				//return "/scripts/gmap.pl/facility/"+tile.x+","+tile.y+","+zoom; },
				var tilesAtThisZoom = 1 << zoom;
				var tilex = tile.x % tilesAtThisZoom;
				//if (zoom > TILE_ZOOM) {
				//	return "/scripts/gmap.pl/facility/"+tile.x+","+tile.y+","+zoom;
				//} else {
					return "/html/tiles/facility/"+zoom+"/"+tilex+"/"+tile.y+".png";
				//}
				},
			tileSize: new google.maps.Size(256, 256),
			isPng: true
			};
			facilityMapLayer = new google.maps.ImageMapType(facilityMapLayerOptions);
			if (!no_facility) map.overlayMapTypes.insertAt("2",facilityMapLayer);
			//map.overlayMapTypes.insertAt("1",facilityMapLayer);
        },
        
    };
    
    return module;
})();


