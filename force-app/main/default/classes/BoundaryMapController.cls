global without sharing class BoundaryMapController {
    
    @RemoteAction
    global static Map<String, List<Object>> getBoundaryMap() {
        String currentUserId = UserInfo.getUserId();
        
        List<Route__c> routes = [SELECT Id, Name, Route_Name__c
                                 FROM Route__c
                                 WHERE Sales_User__c = :currentUserId];
        
        Map<String, List<Object>> routeToAccounts = new Map<String, List<Object>>();
        
        List<Account> accounts = [SELECT Id, Name, BillingStreet, BillingLatitude, BillingLongitude
                                  FROM Account
                                  WHERE BillingStreet LIKE :getRouteNameFilters(routes)];
        
        for (Route__c route : routes) {
            routeToAccounts.put(route.Route_Name__c, new List<Object>());
        }
        
        for (Account acc : accounts) {
            for (Route__c route : routes) {
                if (acc.BillingStreet != null && acc.BillingStreet.contains(route.Route_Name__c)) {
                    routeToAccounts.get(route.Route_Name__c).add(acc);
                }
            }
        }
        
        System.debug('routeToAccounts------->' + routeToAccounts);
        
        return routeToAccounts;
    }
    
    private static Set<String> getRouteNameFilters(List<Route__c> routes) {
        Set<String> filters = new Set<String>();
        for (Route__c route : routes) {
            filters.add('%' + route.Route_Name__c + '%');
        }
        return filters;
    }
    
    @RemoteAction
    global static List<Route__c> getBoundaryMapp(){
        List<Route__c> routes = [SELECT Id, Name, Route_Name__c,Predefined_Area__c FROM Route__c   WHERE Sales_User__c = :UserInfo.getUserId()];
        return routes;
    }
    
    public String getLocationsJSON() {
        // Fetch and format your locations data as a JSON string
        List<Map<String, String>> locations = new List<Map<String, String>>{
            new Map<String, String>{'name' => 'Koramangala', 'address' => 'Koramangala, 560034 India'},
                new Map<String, String>{'name' => 'J. P. Nagar', 'address' => 'J. P. Nagar, 560078 India'},
                    new Map<String, String>{'name' => 'Pune', 'address' => 'Pune, India'}
            // Add more locations as needed
        };
            
            return JSON.serialize(locations);
    }
}