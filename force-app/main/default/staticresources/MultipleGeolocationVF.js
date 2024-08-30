    var directionsService;
    // Define a variable with all map points.
    var _mapPoints;
    var _polyPoints;
    var markerLocationList;
    var GeolocationFromVF = new Array();
    // Define a DirectionsRenderer variable.
    var _directionsRenderer = '';
    
    var map;
    var locMap = new Map();
    var visitDataGeolocation = [];
    var queryString = window.location.search;
    var visitdate = queryString.split("?id=").pop();
    
    function initMap() {
        debugger;
        if(visitdate === "undefined"){
            var currentdate = new Date();
            var inputDateString = currentdate.toLocaleString();
            var inputDate = new Date(inputDateString);
            var formattedDate = inputDate.toISOString().split('T')[0];
            visitdate = formattedDate;
        }
        var datedata = visitdate;
        console.log('datedata ===> '+datedata);
        UservisitTrackingController.fetchPlannedVisitDetails(datedata, function(result, event) {
            debugger;
            if (event.status) {
                if(result !=null){
                    eventss=[...result];
                }
                var objlocation = eventss.map(item => {
                    if(item.Account__c != undefined && item.Account__c != null){
                    return {store_name:item.Account__r.Name, lat: item.Geo_Location__Latitude__s, lng: item.Geo_Location__Longitude__s };                      
                            }
                            else{
                            return {store_name:item.Lead__r.Name, lat: item.Geo_Location__Latitude__s, lng: item.Geo_Location__Longitude__s };
                             }
                          });
                getLocation(objlocation);
            } 
            else if (event.type === 'exception') {
                
            } 
                else {
                    console.log('Unknown error occurred.');
                }
        });
        
        function getLocation(markerLocationList){
            debugger;
            _mapPoints = new Array();
            _polyPoints = new Array();
            var myOptions = {
                zoom: 14,
                center: new google.maps.LatLng(0, 0),
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };
            /* for(var key in completedVisits){
            if(key != 'remove'){
              _polyPoints.push(new google.maps.LatLng(completedVisits[key].lat, completedVisits[key].lng));  
            }
            
        } */
            map = new google.maps.Map(document.getElementById("map"), myOptions);
            /* var flightPath = new google.maps.Polyline({
            path: _polyPoints,
            strokeColor: "black",
            strokeOpacity: 1,
            strokeWeight: 2
        });
        flightPath.setMap(map); */
            
            // debugger;
            directionsService = new google.maps.DirectionsService();
            _directionsRenderer = new google.maps.DirectionsRenderer({
                map: map, suppressMarkers: true,
                // suppressPolylines: true
            });
            /*if (repLat && repLong) {
              markStore(map, {
                   name: 'Your Location',
                   location: new google.maps.LatLng(repLat, repLong)
              }, getMarkerIconURL('CURRENTLOC'));
              // _mapPoints.push(new google.maps.LatLng(repLat, repLong)); //uncomment this line if you want to add route from current loc
         }*/
            
            for (var key in markerLocationList) {
                if (key != 'remove') {
                    markStore(map, {
                        name: markerLocationList[key].store_name,
                        location: new google.maps.LatLng(markerLocationList[key].lat, markerLocationList[key].lng)
                    }, getMarkerIconURL(markerLocationList[key].status));
                    _mapPoints.push(new google.maps.LatLng(markerLocationList[key].lat, markerLocationList[key].lng));
                    if (markerLocationList[key].status === "COMPLETED") {
                        locMap.set("" + markerLocationList[key].lat + markerLocationList[key].lng, markerLocationList[key].status);
                    }
                }
            }
            
            // below method is used to generate maproad with marker
            if (_mapPoints.length > 0) 
                getRoutePointsAndWaypoints();
        }
    }
    
    
    function getRoutePointsAndWaypoints() {
        // debugger;
        // Define a variable for waypoints.
        var _waypoints = new Array();
        if (_mapPoints.length > 2) { // Waypoints will be come.
            for (var j = 1; j < _mapPoints.length - 1; j++) {
                var address = _mapPoints[j];
                if (address !== "") {
                    _waypoints.push({
                        location: address, stopover: true // stopover is used to show marker on map for waypoints
                    });
                }
            }
            // Call a drawRoute() function
            drawRoute(_mapPoints[0], _mapPoints[_mapPoints.length - 1], _waypoints);
        } else if (_mapPoints.length > 1) { // Call a drawRoute() function only for start and end locations
            drawRoute(_mapPoints[_mapPoints.length - 2], _mapPoints[_mapPoints.length - 1], _waypoints);
        } else { // Call a drawRoute() function only for one point as start and end locations.
            drawRoute(_mapPoints[_mapPoints.length - 1], _mapPoints[_mapPoints.length - 1], _waypoints);
        }
    }
    
    function drawRoute(originAddress, destinationAddress, _waypoints) {
        // debugger;
        // Define a request variable for route .
        var _request = '';
        // This is for more then two locatins
        if (_waypoints.length > 0) {
            _request = {
                origin: originAddress,
                destination: destinationAddress,
                waypoints: _waypoints, // an array of waypoints
                optimizeWaypoints: true, // set to true if you want google to determine the shortest route or false to use the order specified.
                travelMode: google.maps.DirectionsTravelMode.DRIVING
            };
        } else { // This is for one or two locations. Here noway point is used.
            _request = {
                origin: originAddress,
                destination: destinationAddress,
                travelMode: google.maps.DirectionsTravelMode.DRIVING
            };
        }
        
        // This will take the request and draw the route and return response and status as output
        directionsService.route(_request, /* customDirectionsRenderer */
                                function (_response, _status) {
                                    if (_status == google.maps.DirectionsStatus.OK) {
                                        _directionsRenderer.setDirections(_response);
                                    }
                                });
    }
    
    function customDirectionsRenderer(response, status) {
        // debugger;
        if (status == google.maps.DirectionsStatus.OK) {
            _directionsRenderer.setDirections(response);
            var bounds = new google.maps.LatLngBounds();
            var route = response.routes[0];
            var path = response.routes[0].overview_path;
            var legs = response.routes[0].legs;
            for (i = 0; i < legs.length; i ++) {
                var polyline = new google.maps.Polyline({map: map, strokeColor: "blue", path: [], strokeWeight: 5})
                debugger;
                if (locMap.has("" + legs[i].start_location.lat() + legs[i].start_location.lng())) {
                    polyline.setOptions({strokeColor: "green"});
                }
                var steps = legs[i].steps;
                for (j = 0; j < steps.length; j ++) {
                    var nextSegment = steps[j].path;
                    for (k = 0; k < nextSegment.length; k ++) {
                        polyline.getPath().push(nextSegment[k]);
                        bounds.extend(nextSegment[k]);
                    }
                }
            }
            polyline.setMap(map);
            map.fitBounds(bounds);
        }
    }
    
    function markStore(map, storeInfo, iconLink) {
        // debugger;
        // Create a marker and set its position.
        var marker = new google.maps.Marker({map: map, position: storeInfo.location, title: storeInfo.name, icon: iconLink});
        // show store info when marker is clicked
        marker.addListener('click', function () {
            showStoreInfo(storeInfo);
            // map.setZoom(8);
            map.setCenter(marker.getPosition());
        });
    }
    
    function getMarkerIconURL(status) {
        // debugger;
        if (status === 'PENDING') 
            return window.location.origin + pendingMarker;
        else if (status === 'COMPLETED') 
            return window.location.origin + completedMarker;
            else if (status === 'INPROGRESS') 
                return window.location.origin + tbMarker;
                else if (status === 'LAPSE') 
                    return window.location.origin + lapseMarker;
                    else 
                        return window.location.origin + currentMarker;
    }
    
    
    // show store info in text box
    function showStoreInfo(storeInfo) {
        debugger;
        var info_div = document.getElementById('info_div');
        info_div.innerHTML = storeInfo.name;
        var content = '<div><span>' + storeInfo.name + '</span>';
        // Create info window
        var infowindow = new google.maps.InfoWindow({
            maxWidth: 350,
            pixelOffset: new google.maps.Size(-10, -25)
        });
        infowindow.setContent(content);
        infowindow.open(map);
        infowindow.setPosition(storeInfo.location);
    }
