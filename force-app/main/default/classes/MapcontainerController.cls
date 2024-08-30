public class MapcontainerController {

    @AuraEnabled
    public static Account getAccountDetails(String recordId){
        Map<String,String> MapOfAccountIdCurrnetLatLong = new Map<String,String>();
        try{
            if(String.isNotBlank(recordId))
                return [SELECT Id,Name, BillingStreet, BillingCity, BillingState, BillingPostalCode,BillingCountry,BillingLatitude, BillingLongitude FROM Account WHERE Id=:recordId];
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }

    @AuraEnabled
    public static Lead getLeadDetail(String recordId){
        Map<String,String> MapOfAccountIdCurrnetLatLong = new Map<String,String>();
        try{
            if(String.isNotBlank(recordId))
                return [SELECT Id, Name, Street, City, State, PostalCode, Country, Latitude, Longitude FROM Lead WHERE Id=:recordId];
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }

        @auraEnabled
        Public static String GoogleMapReverseGeocodeCallout(String lat, String lng){
        system.debug('lat =====> ' + lat);
        system.debug('lng =====> ' + lng);
        String CompleteAddress = '';
        try{
            //String key='AIzaSyB4SPqkO0ZQbxT-EU4l886H9Y3ipf1NMW0';
            string key ='AIzaSyB4SPqkO0ZQbxT-EU4l886H9Y3ipf1NMW0';
            Http httpProtocol = new Http();
            // Create HTTP request to send.
            HttpRequest request = new HttpRequest();
            // Set the endpoint URL.
            String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+lat+',' +lng +'&key='+ key;
            request.setEndPoint(endpoint);
            // Set the HTTP verb to GET.
            request.setMethod('GET');
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            HttpResponse response = httpProtocol.send(request);
           // System.debug('####Body : '+response.getBody());
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                Map<String, object> GooglemapResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                
                List<Object> Addresslist = (List<Object>)GooglemapResponseMap.get('results');
                System.debug('Addresslist =====>> '+Addresslist);
                integer j=0;
                for(integer i=0; i<Addresslist.size(); i++){
                    //for(Object obj : Addresslist){
                   // System.debug('Addresslist[i] =====>> '+Addresslist[i]);
                    if(i==0){
                        Map<String, Object> addressmap = (map<String, Object>)Addresslist[i];
                       // System.debug('addressmap =====>> '+addressmap);
                        CompleteAddress = String.valueof(addressmap.get('formatted_address'));
                    }
                }
            }
            
        }
        catch(Exception e){
            
        }
        System.debug('CompleteAddress =====>> '+CompleteAddress); 
        return CompleteAddress;
    }
    
}