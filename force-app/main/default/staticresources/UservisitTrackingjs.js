var app = angular.module('userVisit', []);
app.controller('userVisitController', function ($scope, $window, $location) {
     debugger;
     $scope.today = currentDate === '' ? new Date() : new Date(currentDate);
     console.log("today---", $scope.today);
     // $scope.today = new Date();
     $scope.accounts = [];
     $scope.position = {
          lat: 0.0,
          lng: 0.0
     };
     $scope.userId = userId; 
     $scope.temp = [];
     $scope.compVisit = [];
     $scope.pendingVisit = [];
     $scope.disableTodayVisit = false;
     $scope.startVisitLocation = [{
               "lat": "",
               "lng": ""
          }];
     $scope.visitData = true;
     $scope.newVisitDate = '';
     $scope.amendVisitDate = '';
     $scope.amendVisitId = '';
     $scope.amendVisitHandling = false;
     $scope.userName = userName;
     $scope.dayVisitPlanId;
     debugger;


     $scope.getGeoLocation = () => {
          debugger;
          console.log('getGeoLocation');
          var options = {
               maximumAge: Infinity,
               timeout: 60000,
               enableHighAccuracy: false
          };

          function _onSuccess(callback, position) {
               console.log('LAT: ' + position.coords.latitude + ' - LON: ' + position.coords.longitude);
               $scope.position.lat = position.coords.latitude;
               $scope.position.lng = position.coords.longitude;
               // $scope.init($scope.today, $scope.position.lat, $scope.position.lng);
          }
          function _onError(callback, error) {
               console.log(error);
               if (callback) 
                    callback();
               

          }
          function _getLocation(callback) {
               navigator.geolocation.getCurrentPosition(_onSuccess.bind(this, callback), _onError.bind(this, callback), options);
          }
          _getLocation();
    }
    $scope.getGeoLocation();

     $scope.counter = 1;
     $scope.addDays = function (date, days) {
          const copy = new Date(Number(date))
          copy.setDate(date.getDate() + days)
          return copy;
     }

     let getSelected = (dateToValidate) => {
          debugger;
          return dateToValidate.getDate() == $scope.today.getDate() && dateToValidate.getMonth() == $scope.today.getMonth() && dateToValidate.getFullYear() == $scope.today.getFullYear();
     }
    
    $scope.monthName = '';
     $scope.year = '';
     $scope.selectedDate;
     $scope.updateWeek = function () {
          debugger;
          $scope.currentDateArray = [];
          $scope.currentDateMap = [];
          console.log($scope.counter);
          console.log($scope.counter * 7 - 7);
          let curr = new Date($scope.today); // new Date();

          console.log('Current----', curr);
          let week = []

          let selectedIndex = 0;

          for (let i = 0; i <= 6; i++) { // let first = Math.abs(curr.getDate() - curr.getDay() + i);

               let date = new Date($scope.today);
               date.setDate(date.getDate() + i);

               let thatDate = new Date(`${
                    date.getFullYear()
               }-${
                    date.getMonth() + 1
               }-${
                    date.getDate()
               }`);
               let day = thatDate.getDate();

               let first = day;

               let weekDate = new Date(curr.setDate(first)).toISOString().slice(0, 10)
               week.push(weekDate);
               let isSelected = getSelected(curr);
               $scope.currentDateMap.push({day: first, date: weekDate, selected: isSelected});
               if (isSelected) {
                    selectedIndex = i;
                    debugger;
               }
          }

          console.log('CurrenDateMap-----', $scope.currentDateMap);
          // var secondNextMonday = new Date(curr).getNextWeekDay(1);
          // console.log('secondNextMonday::'+secondNextMonday);
          /*for(var i=$scope.counter*7-7; i < $scope.counter*7; i++){
            var currDate = $scope.addDays($scope.today,i);
            $scope.currentDateMap.push({day: currDate.getDate(), date: currDate, selected : getSelected(currDate)});
        }*/
          console.log($scope.currentDateMap);
          const date = curr; // 2009-11-10
          const month = date.toLocaleString('default', {month: 'long'});
          const year = date.toLocaleString('default', {year: 'numeric'});
          console.log('month' + month);
          $scope.monthName = month;
          $scope.year = year;

          getVisit(selectedIndex);
          /*Date.prototype.getNextWeekDay = function(d) {
            if (d) {
                var next = this;
                next.setDate(this.getDate() - this.getDay() + 7 + d);
                return next;
            }
        }*/
     }

     $scope.updateWeek();

     $scope.visitDetail = function (visitId) {
          debugger;
          let mainURL = window.location.origin + '/apex';
          window.location.replace(mainURL + "/VisitPlanningDetailPage?id=" + visitId);
     }

     function getVisit(index) {
          debugger;
          let objIndex = $scope.currentDateMap.findIndex((date => date.selected == true));
          if (objIndex != -1) 
               $scope.currentDateMap[objIndex].selected = false;
          
          $scope.currentDateMap[index].selected = true;
          let curr = new Date($scope.currentDateMap[index].date);
          console.log('curr::' + curr);
          const month = curr.toLocaleString('default', {month: 'long'});
          const year = curr.toLocaleString('default', {year: 'numeric'});
          console.log('month' + month);
          $scope.monthName = month;
          $scope.year = year;
          $scope.selectedDate = $scope.currentDateMap[index].date;
          $scope.dayVisitPlanId = undefined;
          $scope.dayHasEnded = false;
          $scope.pendingVisit = [];
          $scope.compVisit = [];
         UservisitTrackingController.userPopulated($scope.currentDateMap[index].date, $scope.userId, $scope.position.lat, $scope.position.lng, function (result, event) {
             debugger;
               console.log('result::' + result);
               console.log(result);
               debugger;
               $scope.disableTodayVisit = false;
               let currentVisitEnabled = false;

               result.visitList.forEach((item, index) => {
                    debugger;
                    if (item.CheckIn__c && item.Check_Out__c) {
                         item.disabled = true;
                    } else if (item.CheckIn__c && !item.Check_Out__c && ! currentVisitEnabled) {
                         item.disabled = false;
                         currentVisitEnabled = true;
                    } else if (!item.CheckIn__c && !item.Check_Out__c && ! currentVisitEnabled) {
                         item.disabled = false;
                    } else {
                         item.disabled = true;
                    }

                    if (!item.Visit_Plan__c) {
                         $scope.disableTodayVisit = true;
                    }

                    if (item.Visit_Plan__c && item.Visit_Plan__r.End_Location__Latitude__s) {
                         $scope.disableTodayVisit = true;
                         $scope.dayHasEnded = true;
                    }

                    if (item.Visit_Plan__c && ! $scope.dayVisitPlanId) 
                         $scope.dayVisitPlanId = item.Visit_Plan__c;
                    

               });

               // nextLocationList = result.markerLocationList;
               // completedVisit = result.visitCompstr;
               $scope.pendingVisit = result.visitList;
               $scope.compVisit = result.visitCompList;
               $scope.$apply();
               initMap(result.markerLocationList, $scope.position.lat, $scope.position.lng);

               if (! $scope.dayVisitPlanId && result.visitList.length > 0) {
                    Swal.fire({
                         title: 'Welcome',
                         text: 'Please Start Your Day!'
                    }, function (isConfirm) {
                         console.log('ISCONFIRM', isConfirm);
                         // if(isConfirm){
                         //     $scope.amendVisitHandling = true;
                         //     $scope.$apply();
                         // }
                    })

               }
               console.log("UseerVisitMap-----", $scope.pendingVisit);
               console.log("TODAYVISIT----", $scope.disableTodayVisit);
          }, {escape: false});
     }

     $scope.getVisits = function (index) {
          debugger;
          let objIndex = $scope.currentDateMap.findIndex((date => date.selected == true));
          if (objIndex != -1) 
               $scope.currentDateMap[objIndex].selected = false;
          
          $scope.currentDateMap[index].selected = true;
          let curr = new Date($scope.currentDateMap[index].date);
          console.log('curr::' + curr);
          const month = curr.toLocaleString('default', {month: 'long'});
          const year = curr.toLocaleString('default', {year: 'numeric'});
          console.log('month' + month);
          $scope.monthName = month;
          $scope.year = year;
          $scope.selectedDate = $scope.currentDateMap[index].date;
          $scope.dayVisitPlanId = undefined;
          $scope.dayHasEnded = false;
          $scope.pendingVisit = [];
          $scope.compVisit = [];
         UservisitTrackingController.userPopulated($scope.currentDateMap[index].date, $scope.userId, $scope.position.lat, $scope.position.lng, function (result, event) {
             debugger;
               console.log('result::' + result);
               console.log(result);
               debugger;
               $scope.disableTodayVisit = false;
               let currentVisitEnabled = false;

               result.visitList.forEach((item, index) => {
                    debugger;
                    if (item.CheckIn__c && item.Check_Out__c) {
                         item.disabled = true;
                    } else if (item.CheckIn__c && !item.Check_Out__c && ! currentVisitEnabled) {
                         item.disabled = false;
                         currentVisitEnabled = true;
                    } else if (!item.CheckIn__c && !item.Check_Out__c && ! currentVisitEnabled) {
                         item.disabled = false;
                    } else {
                         item.disabled = true;
                    }

                    if (!item.Visit_Plan__c) {
                         $scope.disableTodayVisit = true;
                    }

                    if (item.Visit_Plan__c && item.Visit_Plan__r.End_Location__Latitude__s) {
                         $scope.disableTodayVisit = true;
                         $scope.dayHasEnded = true;
                    }

                    if (item.Visit_Plan__c && ! $scope.dayVisitPlanId) 
                         $scope.dayVisitPlanId = item.Visit_Plan__c;
                    

               });

               // nextLocationList = result.markerLocationList;
               // completedVisit = result.visitCompstr;
               $scope.pendingVisit = result.visitList;
               $scope.compVisit = result.visitCompList;
               $scope.$apply();
               initMap(result.markerLocationList, $scope.position.lat, $scope.position.lng);

               if (! $scope.dayVisitPlanId && result.visitList.length > 0) {
                    Swal.fire({
                         title: 'Welcome',
                         text: 'Please Start Your Day!'
                    }, function (isConfirm) {
                         console.log('ISCONFIRM', isConfirm);
                         // if(isConfirm){
                         //     $scope.amendVisitHandling = true;
                         //     $scope.$apply();
                         // }
                    })

               }
               console.log("UseerVisitMap-----", $scope.pendingVisit);
               console.log("TODAYVISIT----", $scope.disableTodayVisit);
          }, {escape: false});
          // $scope.init($scope.currentDateMap[index].date, $scope.position.lat, $scope.position.lng);
     }

     // utility Functions
     var nextCounter = 0;
     var prevCounter = 0;
    $scope.nextWeek = function () {
         debugger;
          ++ nextCounter;
          -- prevCounter;
          let curr = new Date();
          var date = new Date();
          date.setDate(date.getDate() + (7 * nextCounter));
          console.log(date);
          let week = []
          curr = date;
          $scope.currentDateMap = [];
          for (let i = 1; i <= 7; i++) {
               let first = curr.getDate() - curr.getDay() + i;
               let weekDate = new Date(curr.setDate(first)).toISOString().slice(0, 10);
               week.push(weekDate);
               $scope.currentDateMap.push({day: curr.getDate(), date: weekDate});
          }
          console.log('currentDateMap::' + $scope.currentDateMap);
     }

     $scope.previousWeek = function (dt) { // debugger;
          ++ prevCounter;
          -- nextCounter;
          let curr = new Date();
          var date = new Date();
          date.setDate(date.getDate() - (7 * prevCounter));
          console.log(date);
          let week = []
          curr = date;
          $scope.currentDateMap = [];
          for (let i = 1; i <= 7; i++) {
               let first = curr.getDate() - curr.getDay() + i
               let weekDate = new Date(curr.setDate(first)).toISOString().slice(0, 10)
               week.push(weekDate);
               $scope.currentDateMap.push({day: curr.getDate(), date: weekDate});
          }
          console.log('currentDateMap::' + $scope.currentDateMap);
     }
     $scope.angularInit = function () {
          debugger;
          console.log('angular initiated:::' + $scope.userId)
          // $scope.pendingVisit = JSON.parse(penVisit);
          // $scope.compVisit = JSON.parse(compVisit);
          // initMap();
     }

     $scope.cancelAmendVisit = function () {
          $scope.amendVisitHandling = false;
     }
     $scope.amendVisit = function (param, visitId) {
          debugger;
          $scope.amendVisitHandling = true;
          console.log('list::' + $scope.pendingVisit[param]);
          $scope.amendVisitDate = $scope.pendingVisit[param].Planned_visit_date__c;
          var date = new Date($scope.amendVisitDate);


          // Will display time in 10:30:23 format
          $scope.amendVisitDate = date;
          $scope.newVisitDate = date;
          $scope.amendVisitId = visitId;
     }

     $scope.changeAmendVisit = function () {
          debugger;
          console.log('$scope.amendVisitDate::' + $scope.amendVisitDate);
          console.log('$scope.amendVisitId::' + $scope.amendVisitId);
          console.log('new visit date::' + $scope.newVisitDate);

          var newDate = new Date($scope.newVisitDate);
          var dd1 = String(newDate.getDate()).padStart(2, '0');
          var mm1 = String(newDate.getMonth() + 1).padStart(2, '0'); // January is 0!
          var yyyy1 = newDate.getFullYear();
          newDate = mm1 + '/' + dd1 + '/' + yyyy1;
          var existingDate = new Date();
          var dd = String(existingDate.getDate()).padStart(2, '0');
          var mm = String(existingDate.getMonth() + 1).padStart(2, '0'); // January is 0!
          var yyyy = existingDate.getFullYear();

          existingDate = mm + '/' + dd + '/' + yyyy;
          if (newDate < existingDate) {
               $scope.amendVisitHandling = false;
               Swal.fire({
                    title: 'Date Warning',
                    text: 'Please choose future date.'
               }, function (isConfirm) {
                    if (isConfirm) {
                         $scope.amendVisitHandling = true;
                         $scope.$apply();
                    }
               })
          } else {
              UservisitTrackingController.changePlannedVisitdate($scope.newVisitDate, $scope.amendVisitId, function (result, event) {
                  debugger;
                    if (result != null) {
                         debugger;
                         $scope.amendVisitHandling = false;
                         $scope.$apply();
                         Swal.fire({title: 'Success', text: 'Your visit plan has been changed successfully.'}).then(result => {
                              location.reload();
                         });
                    }
               })
          }

     }


     $scope.startVisit = function (accId, visitId) {
          debugger;
          console.log('AccId', accId);
          let mainURL = window.location.origin + '/apex';
          window.location.replace(mainURL + "/StartVisit?id=" + accId + "&vistId=" + visitId);
     }

     $scope.bgVisit = function (visit) {
          return visit.CheckIn__c && ! visit.Check_Out__c ? '#47B1FF' : '#E7E7E7';
     }

     $scope.startDay = function () {
          debugger;
          console.log('$scope.position.lat:' + $scope.position.lat);
         UservisitTrackingController.createVisitPlanAcrossUser($scope.position.lat, $scope.position.lng, $scope.userId, $scope.selectedDate, function (result, event) {
             debugger;
               if (result) {
                    if (result.status) {
                         $scope.disableTodayVisit = false;
                         $scope.dayVisitPlanId = result.day_visit_id;
                         $scope.$apply();
                    }
                    Swal.fire({
                         title: 'VISIT PLAN',
                         text: result.message
                    }, function (isConfirm) {
                         $scope.$apply();
                    });

               }
          }, {escape: false});
     }

     $scope.endDay = function () {
          debugger;
          let endDay = false;
          $scope.pendingVisit.forEach((item, index) => {
               debugger;
               if (!item.CheckIn__c || !item.Check_Out__c) {
                    endDay = true;
               }
          });
          if (endDay) {
               Swal.fire({title: 'Warning', text: 'You still have pending visit to be closed, do you still wanna end your day?', showCancelButton: true}).then(result => {
                    debugger;
                    if (result.isConfirmed) {
                         if ($scope.dayVisitPlanId) {
                             UservisitTrackingController.endDay($scope.position.lat, $scope.position.lng, $scope.userId, $scope.dayVisitPlanId, function (result, event) {
                                 debugger;
                                   if (result) {
                                        $scope.disableTodayVisit = true;
                                        $scope.dayHasEnded = true;
                                        $scope.$apply();
                                   }
                              }, {escape: false});
                         } else {
                              Swal.fire({
                                   title: 'VISIT PLAN',
                                   text: 'Something went wrong, please contact system administrator.'
                              }, function (isConfirm) {});
                         }
                    }
               });
          }

     }
     // $scope.getVisits();
});


// var Avals;
// You can calculate directions (using a variety of methods of transportation) by using the DirectionsService object.
var directionsService;
// Define a variable with all map points.
var _mapPoints;
var _polyPoints;
// Define a DirectionsRenderer variable.
var _directionsRenderer = '';

var map;
var locMap = new Map();
function initMap(markerLocationList, repLat, repLong) {
    debugger;
    // debugger;
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


     debugger;
     directionsService = new google.maps.DirectionsService();
     _directionsRenderer = new google.maps.DirectionsRenderer({
          map: map, suppressMarkers: true,
          // suppressPolylines: true
     });

     if (repLat && repLong) {
          markStore(map, {
               name: 'Your Location',
               location: new google.maps.LatLng(repLat, repLong)
          }, getMarkerIconURL('CURRENTLOC'));
          // _mapPoints.push(new google.maps.LatLng(repLat, repLong)); //uncomment this line if you want to add route from current loc
     }

     console.log('--- to visit' + markerLocationList);
     for (var key in markerLocationList) {
          if (key != 'remove') {
               markStore(map, {
                    name: markerLocationList[key].store_name,
                    location: new google.maps.LatLng(markerLocationList[key].lat, markerLocationList[key].lng)
               }, getMarkerIconURL(markerLocationList[key].status));
               _mapPoints.push(new google.maps.LatLng(markerLocationList[key].lat, markerLocationList[key].lng));
               if (markerLocationList[key].status === "COMPLETED") {
                    locMap.set("" + markerLocationList[key].lat + markerLocationList[key].lng, markerLocationList[key].status);
                    console.log("--- LAT " + markerLocationList[key].lat);
               }
          }
     }


     console.log('_mapPoints::' + _mapPoints);
     // below method is used to generate maproad with marker
     if (_mapPoints.length > 0) 
          getRoutePointsAndWaypoints();
     

}

function getRoutePointsAndWaypoints() {
    debugger;
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
    debugger;
    // Define a request variable for route .
     var _request = '';
     console.log(originAddress, destinationAddress, _waypoints)
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
     console.log(_request);

     // This will take the request and draw the route and return response and status as output
     directionsService.route(_request, /* customDirectionsRenderer */
               function (_response, _status) {
          console.log(_response)
          if (_status == google.maps.DirectionsStatus.OK) {
               _directionsRenderer.setDirections(_response);
          }
     });


}

function customDirectionsRenderer(response, status) {
    debugger;
     if (status == google.maps.DirectionsStatus.OK) {
          _directionsRenderer.setDirections(response);
          var bounds = new google.maps.LatLngBounds();
          var route = response.routes[0];
          var path = response.routes[0].overview_path;
          var legs = response.routes[0].legs;
          for (i = 0; i < legs.length; i ++) {
               var polyline = new google.maps.Polyline({map: map, strokeColor: "blue", path: [], strokeWeight: 5})
               debugger;
               console.log("--- LAT " + legs[i].start_location.lat());
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
    debugger;
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
    debugger;
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
