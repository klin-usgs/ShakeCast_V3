MAPAPP = (function() {
    // initailise constants
    var DEFAULT_ZOOM = 11;
    
    // initialise variables
    var map = null,
	detailMapLayer = null,
	mgr = null,
	mc = null,
	fac_mc = null,
	infowindow = null,
	smOverlay = null,
	smImg = null,
	epimarker = null;
        
	infowindow = new google.maps.InfoWindow({
		content: 'content'
	});
	
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

		if (facility.facility_type == "epicenter") {
			lat = parseFloat(facility.origin_lat);
			lon = parseFloat(facility.origin_lon);
		} else {
			lat = parseFloat(facility.lat_min);
			lon = parseFloat(facility.lon_min);
		}
		//MAPAPP.addMarker(new google.maps.LatLng(lat, lon), domdata);
		var markerimage  = new google.maps.MarkerImage("/images/" + facility.facility_type + ".png",
			new google.maps.Size(25,25),
			new google.maps.Point(0,0),
			new google.maps.Point(12,12));				
			
		var markershadow = new google.maps.MarkerImage("/images/shadow-" + facility.facility_type + ".png",
			new google.maps.Size(38,25),
			new google.maps.Point(0,0),
			new google.maps.Point(12,12));			

		var marker = new google.maps.Marker({
			position: new google.maps.LatLng(lat, lon), 
			shadow: markershadow,
			icon: markerimage,
			map: map,
		});
		//facMarkers.push(marker);
        
    } // addMarker
    
    
    var module = {
        addMarker: addMarker,
		loadSM: loadSM,
		DEFAULT_ZOOM: DEFAULT_ZOOM,
		infowindow : infowindow,
        
        init: function(position, zoomLevel) {

            // define the required options
            var myOptions = {
                zoom: zoomLevel ? zoomLevel : DEFAULT_ZOOM,
                center: position,
				disableDefaultUI: true,
				mapTypeId: google.maps.MapTypeId.TERRAIN,
            };

            // initialise the map
            map = new google.maps.Map(
                document.getElementById("map_canvas"),
                myOptions);
              
			google.maps.event.addListener(infowindow, 'domready', function() {
			    $("#accordion").accordion({ autoHeight: false});
			});

			return map;
        },
        
    };
    
    return module;
})();


