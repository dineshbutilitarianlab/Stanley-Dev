/**
 * @author [Dinesh B]
 * @email dinesh.b@utilitarianLab.com
 * @create date 2023-03-20 18:52:54
 * @modify date 2023-03-21 11:58:00
 * @desc [description]
 */

var app = angular.module('startVisit', []);
app.controller('startvisitController',function($scope){
    debugger;
    console.log('controller initiated::');
    $scope.accDetails = JSON.parse(accDetails);
    $scope.visitDetails = visitRecord;
    $scope.userName=userName;
    console.log(userName)
    $scope.visitId = vstId;
    $scope.accId = accId;
    $scope.userId = userId;
    $scope.paymentHandeling = false;
    $scope.caseHandeling = false;
    $scope.returnHandeling = false;
    $scope.position = {lat:0.0, lng:0.0};
    $scope.orderNumber = '';
    $scope.returnOrderList = [];
    $scope.returnOrderHandling = false;
    $scope.selectAll = false;
    $scope.productListTobeReturn = [];
    $scope.addValues = false;
    $scope.onboardHandeling = false;
    $scope.planDate = '';
    $scope.newVisitHandeling = false;
    $scope.visitduringOnboard = false;
    $scope.planvisit = '';
    $scope.disableCheckin = visitRecord.CheckIn__c!=null;
    $scope.disableCheckout = visitRecord.Check_Out__c != null;
    
    $scope.currentLocationLatitude;
    $scope.currentLocationLongitude;
    debugger;
    $scope.currentDateTime;
    currentDateTime = JSON.stringify(new Date()).split("T").join(" ");
    currentDateTime = currentDateTime.substring(0, currentDateTime.length - 6);
    currentDateTime = currentDateTime.replace(/['"]+/g, '')
    console.log('New Update Values ',currentDateTime);
    
    $scope.Products=[];
    console.log('$scope.accDetails::'+$scope.accDetails);
    
    $scope.onboardDealer = {
        Name : '',
        Phone : '',
        Email__c : '',
        Account_Type__c : '',
        BillingStreet : '',
        BillingCity : '',
        BillingState : '',
        BillingPostalCode : '',
        BillingCountry : ''
    }
    $scope.caseData = {
        Type : '',
        Reason : '',
        Product__c : '',
        Subject : '',
        Status : '',
        Priority : '',
        Origin : ''
    }
    $scope.paymentData = {
        Cheque_Date__c : '',
        Amount__c : '',
        Payment_Date__c : '',
        Cheque_Date__c : ''
    }

    debugger;
    var startPos;
var geoSuccess = function (position) {
    debugger;
    startPos = position;
    currentLocationLatitude = startPos.coords.latitude;
    currentLocationLongitude = startPos.coords.longitude;
    };
    navigator.geolocation.getCurrentPosition(geoSuccess);
    
   
    
    $scope.vstHandle = function(){
        debugger;
        console.log('$scope.visitduringOnboard = false;::'+$scope.visitduringOnboard);
        if($scope.visitduringOnboard)
            $scope.visitduringOnboard = false;
        else
            $scope.visitduringOnboard = true; 
    }
    
    $scope.getChannelSalesProducts=function(){
        MultipleGeoLocationVisitController.getChannelSalesProducts(function(res,evt){
            
            $scope.Products=res;
        })
    }
    $scope.getChannelSalesProducts();
    $scope.onboardingDealer = function(){
        debugger;
        console.log('$scope.onboardDealer::'+$scope.onboardDealer);
        console.log('$scope.planvisit::'+$scope.planvisit);
        MultipleGeoLocationVisitController.onboardDealer($scope.onboardDealer,$scope.planDate,$scope.userId,function(result,event){
            if(result != null){
                $scope.onboardHandeling = false;
                $scope.$apply();
                Swal.fire({title:'Dealer Onboarding',text:'Dealer onboarding process has been completed.'}
                          ,function(isConfirm) {
                              
                          })
            }
        })
    }

    $scope.createSample = function(){
        debugger;
        if($scope.accDetails.Email__c){
            window.open(`https://symegafood--symegadev.lightning.force.com/lightning/r/Account/${$scope.accId}/view`);
        }else{
            window.open(`https://symegafood--symegadev.lightning.force.com/lightning/r/Lead/${$scope.accId}/view`);
        }
    }
    
    $scope.newDealerOnboarding = function(){
        $scope.onboardHandeling = true;
    }
    
    $scope.cancelDealerOnboarding = function(){
        $scope.onboardHandeling = false;
    }
    
    $scope.returnOrderData = {
        Dealer_Comments__c : ''
    }
    $scope.visitDetailWrapper = new Object();
    
    $scope.temp = function(){
        debugger;
        console.log($scope.returnOrderList);
    }
    $scope.addProductTobeReturn = function(param){
        debugger;
        console.log('$scope.addValues::'+$scope.addValues);
        $scope.productListTobeReturn.push($scope.returnOrderList[param]);
        console.log('$scope.productListTobeReturn::'+$scope.productListTobeReturn);
    }
    $scope.nextbtn = function(){
        debugger;
        console.log('nextbtn::'+$scope.orderNumber);
        MultipleGeoLocationVisitController.getOrderItems($scope.orderNumber,function(result,event){
            if(result != null){
                console.log('result::'+result);
                $scope.returnOrderList = result;
                $scope.returnOrderHandling = true;
                $scope.$apply();
            }
        })
    }
    
   
    $scope.checkIn = function(){
        debugger;
        console.log('$scope.position.lat:'+$scope.position.lat);
        console.log('$scope.accDetails.BillingLatitude::'+$scope.accDetails.BillingLatitude);
        MultipleGeoLocationVisitController.checkInDealerShop($scope.position.lat, $scope.position.lng, $scope.visitId, $scope.accId, function (result, event) {
            debugger;
            if(result != null){
                Swal.fire({title:'Check-In Details',text:result}).then(result=>{
                    console.log("Result------",result);
                    $scope.visitData = true;
                    $scope.disableCheckin = true;
                    $scope.$apply();
                   // $scope.createSample(); 
                   CalculateDistance();
                });
            }
        })
    }


    function CalculateDistance() {
        debugger;
        VisitLatitude = visitRecord.Geo_Location__Latitude__s;
        VisitLongitude = visitRecord.Geo_Location__Longitude__s;

        StartVisitController.updatedVisitDistance(currentLocationLatitude, currentLocationLongitude, VisitLatitude, VisitLongitude, $scope.visitId, currentDateTime, function (result, event) {
            debugger;
            if (result != null) {
                console.log("result updated Visit Distance :::" + result);
                $scope.$apply();

            }
        })
    }
    
    $scope.checkOut = function(){
        debugger;
        StartVisitController.checkOutDealerShop(currentLocationLatitude, currentLocationLongitude, currentDateTime, $scope.visitId, $scope.accId, function (result, event) {
            debugger;
            if(result != null){
                Swal.fire({title:'Check-Out Details',text:result}).then(result=>{
                    $scope.visitData = true;
                    $scope.disableCheckout = true;
                    $scope.$apply();
                })

            }
        })
    }
    
    $scope.BackTouserDetails = function(){
        debugger;
        let mainURL = window.location.origin+'/apex/MultipleGeolocationVF';
        let subURL = $scope.visitDetails.Planned_visit_date__c !== undefined ? "?currentDate=" + $scope.visitDetails.Planned_visit_date__c : ""
        window.location.replace(mainURL + subURL);
    }
    
    $scope.getGeoLocation = () => {
        debugger;
        console.log('getGeoLocation');
        var options = {
        maximumAge: Infinity,
        timeout: 60000,
        enableHighAccuracy: false
    };
    
    function _onSuccess(callback, position) {
        debugger;
        console.log('LAT: ' + position.coords.latitude + ' - LON: ' +  position.coords.longitude);
        $scope.position.lat = position.coords.latitude;
        $scope.position.lng = position.coords.longitude;
        //$scope.init($scope.today, $scope.position.lat, $scope.position.lng);
        var nexts = [{"lat":$scope.position.lat,"lng":$scope.position.lng}];
        if($scope.visitDetails.Geo_Location__Latitude__s && $scope.visitDetails.Geo_Location__Longitude__s)
            nexts.push({"lat":$scope.visitDetails.Geo_Location__Latitude__s,"lng":$scope.visitDetails.Geo_Location__Longitude__s});
        console.log('nexts::',nexts);
        nextLocationList = nexts;
        initMap(position.coords.latitude, position.coords.longitude);
    }
    function _onError (callback, error) {
        console.log(error);
        if(callback) callback();
        
    }
    function _getLocation (callback) {
        navigator.geolocation.getCurrentPosition(
            _onSuccess.bind(this, callback),
            _onError.bind(this, callback), 
            options
        );
    }
    _getLocation();
}				
$scope.getGeoLocation();

$scope.infoWindow = function(param){
    debugger;
    console.log(param);
}
});
var userTracking;
var _mapPoints = new Array();  
var _polyPoints = new Array();
function initMap(currentLat, currentLong) {
    debugger;
    shortestroute(currentLat, currentLong);
}

function shortestroute(currentLat, currentLong){
    
    debugger;
    directionsService = new google.maps.DirectionsService();
    _directionsRenderer = new google.maps.DirectionsRenderer();    
    //Set the your own options for map.    
    var myOptions = {    
        zoom: 14,    
        center: new google.maps.LatLng(currentLat, currentLong),    
        mapTypeId: google.maps.MapTypeId.ROADMAP    
    }; 
    _mapPoints = new Array();    
    var userTrackingPosition;
    
    var map = new google.maps.Map(document.getElementById("visitMap"), myOptions);
    
    var contentString = '';
        
    const infowindow = new google.maps.InfoWindow({
        content: contentString,
    });
       
    _directionsRenderer.setMap(map);
    
    for(var key in nextLocationList){
        if(key != 'remove'){
            debugger;
            _mapPoints.push(new google.maps.LatLng(nextLocationList[key].lat, nextLocationList[key].lng)); 
        }
        
    }
    console.log('_mapPoints::'+_mapPoints);
    getRoutePointsAndWaypoints();  
}

function myFunction(param) {
    console.log(param)
}

function getRoutePointsAndWaypoints() {    
    //Define a variable for waypoints.    
    var _waypoints = new Array();    
    if (_mapPoints.length > 2) //Waypoints will be come.    
    {    
        for (var j = 1; j < _mapPoints.length - 1; j++) {    
            var address = _mapPoints[j];    
            if (address !== "") {    
                _waypoints.push({    
                    location: address,    
                    stopover: true  //stopover is used to show marker on map for waypoints    
                });    
            }    
        }    
        //Call a drawRoute() function    
        drawRoute(_mapPoints[0], _mapPoints[_mapPoints.length - 1], _waypoints);    
    } else if (_mapPoints.length > 1) {    
        //Call a drawRoute() function only for start and end locations    
        drawRoute(_mapPoints[_mapPoints.length - 2], _mapPoints[_mapPoints.length - 1], _waypoints);    
    } else {    
        //Call a drawRoute() function only for one point as start and end locations.    
        drawRoute(_mapPoints[_mapPoints.length - 1], _mapPoints[_mapPoints.length - 1], _waypoints);    
    }
} 
function drawRoute(originAddress, destinationAddress, _waypoints) {    
    //Define a request variable for route .    
    var _request = '';    
    //This is for more then two locatins    
    if (_waypoints.length > 0) {    
        _request = {    
            origin: originAddress,    
            destination: destinationAddress,    
            waypoints: _waypoints, //an array of waypoints    
            optimizeWaypoints: true, //set to true if you want google to determine the shortest route or false to use the order specified.    
            travelMode: google.maps.DirectionsTravelMode.DRIVING    
        };    
    } else {    
        //This is for one or two locatio		ns. Here noway point is used.    
        _request = {    
            origin: originAddress,    
            destination: destinationAddress,    
            travelMode: google.maps.DirectionsTravelMode.DRIVING    
        };    
    }    
    //This will take the request and draw the route and return response and status as output    
    directionsService.route(_request, function (_response, _status) {    
        if (_status == google.maps.DirectionsStatus.OK) {    
            _directionsRenderer.setDirections(_response);    
        }    
    });   
    
    
}