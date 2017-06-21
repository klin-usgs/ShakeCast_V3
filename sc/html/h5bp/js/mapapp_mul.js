MAPAPP = (function() {
    // initailise constants
    var DEFAULT_ZOOM = 8;
    
    // initialise variables
    var map = null,
	georss = null,
	detailMapLayer = null,
	mgr = null,
	mc = null,
	fac_mc = null,
	infowindow = null,
        mainScreen = true,
        markerContent = {},
	smOverlay = null,
	smOverlays = [],
	smImg = null,
	smBounds = null,
	epimarker = null,
	epiMarkers = [],
	ControlDiv = null,
	stationMapLayer = null,
	eventMapLayer = null,
	eqTableDiv = null;
    var customDiv = { 'eqCont' : null, 'eqTab': null };
        
    function loadSM(bounds, img, data, opacity) {
        // create a new marker to and display it on the map
		//if (smOverlay) {
		//	smOverlay.setMap(null);
		//	epimarker.setMap(null);
		//}

		smImg = img;
		smBounds = bounds;
		if (smBounds) {
		var smOverlay = new USGSOverlay(bounds, img, map, opacity);

		/*var event = $(data).find("event");
        var epimarker = new google.maps.Marker({
            position: new google.maps.LatLng(event.attr("lat"), event.attr("lon")), 
            map: map,
            title: "Epicenter",
            icon: 'images/epicenter.png',
        });*/
			
        // create a simple info window
		/*var description = "<table border=1><tr bgcolor=#bbbbbb><td colspan=2 align=center><strong>" + 
			event.attr("locstring") + "</strong>" + 
			"<tr><td><table bgcolor=#eeeeee width=100%>" + 
			"<tr><td colspan=3><font size=-1>Event ID: <strong>" + 
			event.attr("id") + "</strong></td></tr>" +
			"<tr><td colspan=2><font size=-1>Magnitude: <strong>" + 
			event.attr("magnitude") + "</strong></td></tr>" +
			"<tr><td><font size=-1>Lat: <strong>" + event.attr("lat") + 
			"<strong></td><td><font size=-1>Lon: <strong>" + event.attr("lon") + "<strong></td>" +
			"<td><font size=-1>Depth: <strong>" + event.attr("depth") + "<strong></td></tr>" +
			"<tr><td colspan=2><font size=-1>Time: <strong>" + event.attr("timestamp") + 
			"<strong></td></tr></table></td></tr></table>";
        var infowindow = new google.maps.InfoWindow({
            content: description
        });*/

        // capture touch click events for the created marker
        /*google.maps.event.addListener(epimarker, 'click', function() {
            infowindow.open(map,epimarker);
        });*/

	//alert(smBounds.toString());
		map.setCenter(smBounds.getCenter(), DEFAULT_ZOOM);
		//google.maps.event.addListener(map, 'click', handleMapClick);	

		}
    } // addMarker
    
    function activateMarker(marker) {
        // iterate through the markers and set to the inactive image
        for (var ii = 0; ii < markers.length; ii++) {
            markers[ii].setIcon('/img/pin-inactive.png');
        } // for
        
        // update the specified marker's icon to the active image
        marker.setIcon('/img/pin-active.png');
            
        // update the navbar title using jQuery
        $('#marker-nav .marker-title')
            .html(marker.getTitle())
            .removeClass('has-detail')
            .unbind('click');
            
        // if content has been provided, then add the has-detail
        // class to adjust the display to be "link-like" and 
        // attach the click event handler
        var content = markerContent[marker.getTitle()];
        if (content) {
            $('#marker-nav .marker-title')
                .addClass('has-detail')
                .click(function() {
                    $('#marker-detail .content').html(content);
                    showScreen('marker-detail');
                });
        } // if
        
        // update the marker navigation controls
        updateMarkerNav(getMarkerIndex(marker));
    } // activateMarker
        
    function addMarker(position, event) {
        // create a new marker to and display it on the map
				var epicenterimage  = new google.maps.MarkerImage("/images/epicenter.png",
														new google.maps.Size(25,25),
														new google.maps.Point(0,0),
														new google.maps.Point(12,12));				
														
				var epicentershadow = new google.maps.MarkerImage("/images/shadow-epicenter.png",
														new google.maps.Size(38,25),
														new google.maps.Point(0,0),
														new google.maps.Point(12,12));			
				
        var marker = new google.maps.Marker({
            position: position, 
			shadow:epicentershadow,
			icon: epicenterimage,
            map: map,
            title: 'M' + event.attr("magnitude") + ' ' + event.attr("event_location_description"),
        });
        
        // save the marker content
        //markerContent[title] = content;
        
        // add the marker to the array of markers
        //markers.push(marker);
        
        // capture touch click events for the created marker
        //google.maps.event.addListener(marker, 'click', function() {
            // activate the clicked marker
        //    activateMarker(marker);
        //});

		/*//var event = $(data).find("event");
        var epimarker = new google.maps.Marker({
            position: new google.maps.LatLng(event.attr("lat"), event.attr("lon")), 
            map: map,
            title: "Epicenter",
            icon: 'images/epicenter.png',
        });*/
			
        // create a simple info window
		var description = "<table border=1><tr bgcolor=#bbbbbb><td colspan=2 align=center><strong>" + 
			event.attr("event_location_description") + "</strong>" + 
			"<tr><td><table bgcolor=#eeeeee width=100%>" + 
			"<tr><td colspan=3><font size=-1>Event ID: <strong>" + 
			event.attr("event_id") + "</strong></td></tr>" +
			"<tr><td colspan=2><font size=-1>Magnitude: <strong>" + 
			event.attr("magnitude") + "</strong></td></tr>" +
			"<tr><td><font size=-1>Lat: <strong>" + event.attr("lat") + 
			"<strong></td><td><font size=-1>Lon: <strong>" + event.attr("lon") + "<strong></td>" +
			"<td><font size=-1>Depth: <strong>" + event.attr("depth") + "<strong></td></tr>" +
			"<tr><td colspan=2><font size=-1>Time: <strong>" + event.attr("event_timestamp") + 
			"<strong></td></tr></table></td></tr></table>";
        var infowindow = new google.maps.InfoWindow({
            content: description,
	    maxWidth: 300
        });

        // capture touch click events for the created marker
        google.maps.event.addListener(marker, 'click', function() {
            infowindow.open(map,marker);
        });

		mc.addMarker(marker);
    } // addMarker
    
    
    function addfacMarkers(markers) {
	var mcOptions = {gridSize: 50, maxZoom: 15
		};
		fac_mc = new MarkerClusterer(map, markers, mcOptions);
    } // clearMarkers
    
    
    function getMarkerIndex(marker) {
        for (var ii = 0; ii < markers.length; ii++) {
            if (markers[ii] === marker) {
                return ii;
            } // if
        } // for 
        
        return -1;
    } // getMarkerIndex
    
    function initScreen() {
        // watch for location hash changes
        setInterval(watchHash, 10);

        // next attach a click handler to all close buttons
        $('button.close').click(showScreen);
    } // initScreen
    
    function showScreen(screenId) {
        mainScreen = typeof screenId !== 'string';
        if (typeof screenId === 'string') {
            $('#' + screenId).css('left', '0px');

            // update the location hash to marker detail
            window.location.hash = screenId;
        }
        else {
            $('div.child-screen').css('left', '100%');
            window.location.hash = '';
        } // if..else
        
        scrollTo(0, 1);
    } // showScreen
    
    function sortMarkers() {
        // sort the markers from top to bottom, left to right
        // remembering that latitudes are less the further south we go
        markers.sort(function(markerA, markerB) {
            // get the position of marker A and the position of marker B
            var posA = markerA.getPosition(),
                posB = markerB.getPosition();

            var result = posB.lat() - posA.lat();
            if (result === 0) {
                result = posA.lng() - posB.lng();
            } // if
            
            return result;
        });
    } // sortMarkers
    
    function updateMarkerNav(markerIndex) {
        
        // find the marker nav element
        var markerNav = $('#marker-nav');
        
        // reset the disabled state for the images and unbind click events
        markerNav.find('img')
            .addClass('disabled')
            .unbind('click');
            
        // if we have more markers at the end of the array, then update
        // the marker state
        if (markerIndex < markers.length - 1) {
            markerNav.find('img.right')
                .removeClass('disabled')
                .click(function() {
                    activateMarker(markers[markerIndex + 1]);
                });
        } // if
        
        if (markerIndex > 0) {
            markerNav.find('img.left')
                .removeClass('disabled')
                .click(function() {
                    activateMarker(markers[markerIndex - 1]);
                });
        } // if
    } // updateMarkerNav
    
    function watchHash() {
        // this function monitors the location hash for a reset to empty
        if ((! mainScreen) && (window.location.hash === '')) {
            showScreen();
        } // if
    } // watchHash

    function updateinfo(marker) {
		infowindow.setContent(marker.description);
		infowindow.open(map, marker);
    } // watchHash

    function addMarkers(markers) {
	var mcOptions = {gridSize: 30, maxZoom: 15,
		styles: [{url:'./images/eqcluster.png', height:32, width:32, anchor:[0,0], textColor: '#cc0000', textSize: 12}]
		};
		mc = new MarkerClusterer(map, markers, mcOptions);

        if (markers[0].evid != lastEQ) {
            lastEQ = markers[0].evid;
	    map.setCenter(markers[0].position, DEFAULT_ZOOM);
        } // for 
    } // clearMarkers
    
    function clearMarkers() {
	mc.clearMarkers();
    } // clearMarkers
    
    function addOverlays(overlays) {
        for (var ii = 0; ii < overlays.length; ii++) {
	    var smOverlay = new USGSOverlay(overlays[ii].bounds, overlays[ii].img, map, overlays[ii].opacity, overlays[ii].description);
            smOverlays.push( smOverlay);

        } // for
	
		
    } // watchHash

    function clearOverlays() {
        for (var ii = 0; ii < smOverlays.length; ii++) {
	    smOverlays[ii].setMap(null);
        } // for
        
	smOverlays = [];
    } // clearMarkers
    
    function addControl(eqTable) {
	// Create the legend and display on map
	ControlDiv = document.createElement('DIV');
	eqTableDiv = document.createElement('DIV');
	var Control = new EQControl(ControlDiv, map, eqTableDiv, eqTable);

	ControlDiv.index = 1;
	eqTableDiv.index = 1;
	customDiv['eqCont'] = map.controls[google.maps.ControlPosition.TOP_RIGHT].push(ControlDiv);
	customDiv['eqTab'] = map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(eqTableDiv);

	//map.setCenter(overlays[0].bounds.getCenter(), DEFAULT_ZOOM);
	// Set CSS for the control border
	// Set CSS for the control border
	var eventDiv = document.createElement('DIV'); 
	eventDiv.style.backgroundColor = 'white';
	eventDiv.style.borderStyle = 'solid';
	eventDiv.style.borderWidth = '1px';
	eventDiv.style.cursor = 'pointer';
	eventDiv.style.textAlign = 'left';
	eventDiv.title = 'Click to toggle background seismicity layer';
	// Set CSS for the control interior
	var eventText = document.createElement('DIV');
	eventText.style.fontFamily = 'Arial,sans-serif';
	eventText.style.fontSize = '12px';
	eventText.style.paddingLeft = '5px';
	eventText.style.paddingRight = '5px';
	eventText.style.paddingTop = '1px';
	eventText.style.paddingBottom = '1px';
	eventText.innerHTML = 'Earthquake Layer';
	eventDiv.appendChild(eventText);
	ControlDiv.appendChild(eventDiv);
	
	var stationDiv = document.createElement('DIV'); 
	stationDiv.style.backgroundColor = 'white';
	stationDiv.style.borderStyle = 'solid';
	stationDiv.style.borderWidth = '1px';
	stationDiv.style.cursor = 'pointer';
	stationDiv.style.textAlign = 'left';
	stationDiv.title = 'Click to toggle station layer';
	// Set CSS for the control interior
	var stationText = document.createElement('DIV');
	stationText.style.fontFamily = 'Arial,sans-serif';
	stationText.style.fontSize = '12px';
	stationText.style.paddingLeft = '5px';
	stationText.style.paddingRight = '5px';
	stationText.style.paddingTop = '1px';
	stationText.style.paddingBottom = '1px';
	stationText.innerHTML = 'Station Layer';
	stationDiv.appendChild(stationText);
	ControlDiv.appendChild(stationDiv);
	
	google.maps.event.addDomListener(eventDiv, 'click', function() {
	  if (map.overlayMapTypes.getAt("1")) {
		  map.overlayMapTypes.setAt("1",null);
		  this.style.backgroundColor = 'white';
	  } else {
		  map.overlayMapTypes.setAt("1",eventMapLayer);
		  this.style.backgroundColor = '#ffbff5';
	  }
	      });
	google.maps.event.addDomListener(stationDiv, 'click', function() {
	  if (map.overlayMapTypes.getAt("0")) {
		  map.overlayMapTypes.setAt("0",null);
		  this.style.backgroundColor = 'white';
	  } else {
		  map.overlayMapTypes.setAt("0",stationMapLayer);
		  this.style.backgroundColor = '#aaaaff';
	  }
	      });
 
    } // watchHash

    function clearControl() {
	ControlDiv = null;
        map.controls[google.maps.ControlPosition.TOP_RIGHT].removeAt(customDiv['eqCont']-1);
	eqTableDiv = null;
        map.controls[google.maps.ControlPosition.LEFT_BOTTOM].removeAt(customDiv['eqTab']-1);
    } // clearMarkers
    
    function addLegend(facTypes) {
	var typeText = '<img src="/images/epicenter.png" /> Earthquake Epicenter<br />';
        for (var ii = 0; ii < facTypes.length; ii++) {
	    typeText = typeText +
	    '<img src="/images/' + facTypes[ii].facility_type + '.png" /> ' + facTypes[ii].name + '<br />';
        } // for
  var tableDiv = document.createElement('DIV');
  var tableControl = new LegendControl(tableDiv, map, typeText);

  tableDiv.index = 1;
  map.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push(tableDiv);


    } // watchHash
    function mapobj() {
		return map;
    } // watchHash

    var module = {
        addMarker: addMarker,
        addMarkers: addMarkers,
        addfacMarkers: addfacMarkers,
	loadSM: loadSM,
        addOverlays: addOverlays,
	map: mapobj,
	updateinfo: updateinfo,
        addControl: addControl,
        addLegend: addLegend,
        clearMarkers: clearMarkers,
        clearOverlays: clearOverlays,
        clearControl: clearControl,
        
        init: function(position, zoomLevel) {
	    var detailsMapLayerOptions = {
		getTileUrl: function(tile, zoom) {
		    //console.debug(X);
		    return "/server_event.php?x="+tile.x+"&y="+tile.y+"&zoom="+zoom; },
		tileSize: new google.maps.Size(256, 256),
		isPng: true
	    };
	    
	    eventMapLayer = new google.maps.ImageMapType(detailsMapLayerOptions);

	    var stationMapLayerOptions = {
		getTileUrl: function(tile, zoom) {
		    //console.debug(X);
		    return "/server_station.php?x="+tile.x+"&y="+tile.y+"&zoom="+zoom; },
		tileSize: new google.maps.Size(256, 256),
		isPng: true
	    };
	    
	    stationMapLayer = new google.maps.ImageMapType(stationMapLayerOptions);

            // define the required options
            var myOptions = {
                zoom: zoomLevel ? zoomLevel : DEFAULT_ZOOM,
                center: position,
                mapTypeControl: true,
                streetViewControl: false,
				panControl: false,
				scaleControl: true,
				overviewMapControl: true,
                mapTypeControlOptions: {
				style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
				},
				mapTypeId: google.maps.MapTypeId.TERRAIN,
            };

            // initialise the map
            map = new google.maps.Map(
                document.getElementById("map_canvas"),
                myOptions);
                
	    //map.overlayMapTypes.insertAt("0",stationMapLayer);
	    map.overlayMapTypes.insertAt("0",null);
	    map.overlayMapTypes.insertAt("1",null);
	    //map.overlayMapTypes.push(detailMapLayer);
			//georss = new google.maps.KmlLayer('http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-depth_src.kmz');
			//georss.setMap(map);

			infowindow = new google.maps.InfoWindow({
				content: '',
			});
			
			google.maps.event.addListener(infowindow, 'domready', function() {
			    $("#tabs").tabs();
			});

			/*var detailsMapLayerOptions = {
				getTileUrl: function(tile, zoom) { return "/server.php?x="+tile.x+"&y="+tile.y+"&zoom="+zoom; },
				tileSize: new google.maps.Size(256, 256),
				isPng: true
			};
			detailMapLayer = new google.maps.ImageMapType(detailsMapLayerOptions);
			map.overlayMapTypes.insertAt(0,detailMapLayer);*/
			
			// initialize logo and ShakeMap legend
			var logoDiv = document.createElement('DIV');
			logoDiv.style.cursor = 'pointer';
			logoDiv.style.textAlign = 'left';
			logoDiv.style.padding = '12px';
			logoDiv.innerHTML = '<img src="../images/neic.jpg"/><br /><img src="http://earthquake.usgs.gov/earthquakes/shakemap/sc/shake/icons/shakemap.png"/>';
			logoDiv.title = 'Click to toggle earthquake table';
			map.controls[google.maps.ControlPosition.TOP_LEFT].push(logoDiv);
			google.maps.event.addDomListener(logoDiv, 'click', function() {
			    $('#marker-detail').css('left', '0px');
			    scrollTo(0, 1);
			});

  

            //initScreen();
			return map;
        },
        
        updateDisplay: function() {
		
			//loadSM(smBounds, smImg, null);
            // get the first marker
            var firstMarker = markers.length > 0 ? markers[0] : null;

            // sort the markers
            sortMarkers();

            // if we have at least one marker in the list, then 
            // initialize the first marker
            if (firstMarker) {
                activateMarker(firstMarker);
            } // if
 
       }
    };
    
    return module;
})();


/**
 * The HomeControl adds a control to the map that
 * returns the user to the control's defined home.
 */

// Define a property to hold the Home state
LegendControl.prototype.home_ = null;

// Define setters and getters for this property
LegendControl.prototype.getHome = function() {
  return this.home_;
}

LegendControl.prototype.setHome = function(home) {
  this.home_ = home;
}

function LegendControl(controlDiv, map, facTypes) {
 
  // We set up a variable for this since we're adding
  // event listeners later.
  var control = this;
  
  // Set the home property upon construction
  control.facTypes_ = facTypes;
 
  // Set CSS styles for the DIV containing the control
  // Setting padding to 5 px will offset the control
  // from the edge of the map
  controlDiv.style.padding = '5px';
 
  // Set CSS for the control border
  var goHomeUI = document.createElement('DIV'); 
  goHomeUI.style.backgroundColor = 'white';
  goHomeUI.style.borderStyle = 'solid';
  goHomeUI.style.borderWidth = '1px';
  goHomeUI.style.cursor = 'pointer';
  goHomeUI.style.textAlign = 'left';
  goHomeUI.title = 'Click to set the map to Home';
  controlDiv.appendChild(goHomeUI);
 
  // Set CSS for the control interior
  var goHomeText = document.createElement('DIV');
  goHomeText.style.fontFamily = 'Arial,sans-serif';
  goHomeText.style.fontSize = '12px';
  goHomeText.style.paddingLeft = '4px';
  goHomeText.style.paddingRight = '4px';
  goHomeText.innerHTML = '<img src="/images/eqcluster.png" /> Earthquake Cluster<br /><img src="/images/m3.png" /> Facility Cluster<p />';
  goHomeUI.appendChild(goHomeText);
  
  // Set CSS for the setHome control border
  var setHomeUI = document.createElement('DIV');
  setHomeUI.style.backgroundColor = 'white';
  setHomeUI.style.borderStyle = 'solid';
  setHomeUI.style.borderWidth = '1px';
  setHomeUI.style.cursor = 'pointer';
  setHomeUI.style.textAlign = 'left';
  setHomeUI.title = 'Click to set Home to the current center';
  controlDiv.appendChild(setHomeUI);
 
  // Set CSS for the control interior
  var setHomeText = document.createElement('DIV');
  setHomeText.style.fontFamily = 'Arial,sans-serif';
  setHomeText.style.fontSize = '12px';
  setHomeText.style.paddingLeft = '4px';
  setHomeText.style.paddingRight = '4px';
  setHomeText.style.paddingTop = '1px';
  setHomeText.style.paddingBottom = '1px';
  setHomeText.innerHTML = facTypes;
  setHomeUI.appendChild(setHomeText);
 
  // Setup the click event listener for Home:
  // simply set the map to the control's current home property.
  google.maps.event.addDomListener(goHomeUI, 'click', function() {
    var currentHome = control.getHome();
    map.setCenter(currentHome);
  });
  
  // Setup the click event listener for Set Home:
  // Set the control's home to the current Map center.
  google.maps.event.addDomListener(setHomeUI, 'click', function() {
    /*var newHome = map.getCenter();
    control.setHome(newHome);*/
    $('#marker-detail').css('left', '0px');
    scrollTo(0, 1);
  });

}
 
/**
 * The tableControl adds a control to the map that
 * returns the user to the control's defined home.
 */

// Define a property to hold the Home state
EQControl.prototype.eqTable_ = null;

EQControl.prototype.setTable = function(eqTable) {
  this.eqTable_ = eqTable;
}

function EQControl(controlDiv, map, eqTableDiv, eqTable) {
 
  // We set up a variable for this since we're adding
  // event listeners later.
  var control = this;
  
  // Set the home property upon construction
  control.eqTable_ = eqTable;
  control.div_ = null;
 
  // Set CSS styles for the DIV containing the control
  // Setting padding to 5 px will offset the control
  // from the edge of the map
  controlDiv.style.padding = '5px';
 
  // Set CSS for the control border
  var goHomeUI = document.createElement('DIV'); 
  goHomeUI.style.backgroundColor = 'white';
  goHomeUI.style.borderStyle = 'solid';
  goHomeUI.style.borderWidth = '1px';
  goHomeUI.style.cursor = 'pointer';
  goHomeUI.style.textAlign = 'left';
  goHomeUI.title = 'Click to toggle ShakeMap table';
  controlDiv.appendChild(goHomeUI);
 
  // Set CSS for the control interior
  var goHomeText = document.createElement('DIV');
  goHomeText.style.fontFamily = 'Arial,sans-serif';
  goHomeText.style.fontSize = '12px';
  goHomeText.style.paddingLeft = '5px';
  goHomeText.style.paddingRight = '5px';
  goHomeText.style.paddingTop = '1px';
  goHomeText.style.paddingBottom = '1px';
  goHomeText.innerHTML = 'ShakeMap Table';
  goHomeUI.appendChild(goHomeText);
  
  // Set CSS for the control border
  var eqTableUI = document.createElement('DIV'); 
  eqTableUI.style.backgroundColor = 'white';
  eqTableUI.style.borderStyle = 'solid';
  eqTableUI.style.borderWidth = '2px';
  eqTableUI.style.cursor = 'pointer';
  eqTableUI.style.textAlign = 'center';
  eqTableUI.title = 'Click to toggle earthquake table';
  eqTableUI.style.visibility = "hidden";
  eqTableDiv.appendChild(eqTableUI);
 
  // Set CSS for the control border
  var eqTableicon = document.createElement('DIV'); 
  /*eqTableUI.style.backgroundColor = 'white';
  eqTableUI.style.borderStyle = 'solid';
  eqTableUI.style.borderWidth = '2px';
  eqTableUI.style.cursor = 'pointer';
  eqTableUI.style.textAlign = 'center';
  eqTableUI.title = 'Click to toggle earthquake table';
  eqTableUI.style.visibility = "hidden";*/
  eqTableicon.innerHTML = '<span class="ui-icon ui-icon-circle-close" style="float:right;"></span>';
  eqTableUI.appendChild(eqTableicon);
 
  // Set CSS for the control interior
  var eqTableText = document.createElement('DIV');
  eqTableText.style.fontFamily = 'Arial,sans-serif';
  eqTableText.style.fontSize = '12px';
  eqTableText.style.paddingLeft = '5px';
  eqTableText.style.paddingRight = '5px';
  eqTableText.style.paddingTop = '1px';
  eqTableText.style.paddingBottom = '1px';
  eqTableText.innerHTML = '<table cellpadding="0" cellspacing="0" border="0" class="display" id="eqTable"></table>';
  eqTableUI.appendChild(eqTableText);
  
  eqTableDiv.appendChild(eqTableUI);

  control.div_ = eqTableUI;
		  //$("#eqTable").dataTable(eqTable);
  // Setup the click event listener for Home:
  // simply set the map to the control's current home property.
  google.maps.event.addDomListener(goHomeUI, 'click', function() {
    if (control.div_) {
      if (control.div_.style.visibility == "hidden") {
		  control.div_.style.visibility = "visible";
		  $("#eqTable").dataTable(eqTable);
		  $("#eqTable tbody tr").live('click', function () {
		    var nTds = $('td', this);
		    var sLat = parseFloat($(nTds[2]).text());
		    var sLon = parseFloat($(nTds[3]).text());
		    map.panTo(new google.maps.LatLng(sLat, sLon));
		    });
		  //$(control.div_).show(1000);
		    goHomeUI.style.backgroundColor = 'lightgrey';
	  } else {
        $(control.div_).slideToggle(1000);
		    if (goHomeUI.style.backgroundColor == 'white') {
			goHomeUI.style.backgroundColor = 'lightgrey';
		    } else {
			goHomeUI.style.backgroundColor = 'white';
		    }
		}
	}
	});
  google.maps.event.addDomListener(eqTableicon, 'click', function() {
    if (control.div_) {
      if (control.div_.style.visibility == "hidden") {
		  control.div_.style.visibility = "visible";
		  $("#eqTable").dataTable(eqTable);
		  $("#eqTable tbody tr").live('click', function () {
		    var nTds = $('td', this);
		    var sLat = parseFloat($(nTds[2]).text());
		    var sLon = parseFloat($(nTds[3]).text());
		    map.panTo(new google.maps.LatLng(sLat, sLon));
		    });
		  //$(control.div_).show(1000);
		    goHomeUI.style.backgroundColor = 'lightgrey';
	  } else {
        $(control.div_).slideToggle(1000);
		    if (goHomeUI.style.backgroundColor == 'white') {
			goHomeUI.style.backgroundColor = 'lightgrey';
		    } else {
			goHomeUI.style.backgroundColor = 'white';
		    }
		}
	}
	});
}
