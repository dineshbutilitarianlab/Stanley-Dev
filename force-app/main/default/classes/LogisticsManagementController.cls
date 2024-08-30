public with sharing class LogisticsManagementController {
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrders(Date effectiveDate, Date endDate, String status, String route, String searchKey, String pinCode, Integer pageSize, Integer pageNumber) {
        String query = 'SELECT OrderNumber, EffectiveDate, Account.Name, Status, Route__c, EndDate, Delivery_Date__c, Pick_Up_Time__c, Pickup_location__c, Pref_Delivery_Slot__c, ShippingPostalCode, Contact__r.Name, ' +
                       'Delivery_Address__Street__s, Delivery_Address__City__s, Delivery_Address__StateCode__s, Delivery_Address__PostalCode__s, Delivery_Address__CountryCode__s ' +
                       'FROM Order';
        List<String> filters = new List<String>();

        if (effectiveDate != null) {
            filters.add('EffectiveDate = :effectiveDate');
        }
        if (endDate != null) {
            filters.add('EndDate = :endDate');
        }
        if (status != null && status != '') {
            filters.add('Status = :status');
        }
        if (route != null && route != '') {
            filters.add('Route__c = :route');
        }
        if (searchKey != null && searchKey != '') {
            filters.add('OrderNumber LIKE \'%' + searchKey + '%\'');
        }
        if (pinCode != null && pinCode != '') {
            filters.add('ShippingPostalCode = :pinCode');
        }

        if (filters.size() > 0) {
            query += ' WHERE ' + String.join(filters, ' AND ');
        }

        query += ' LIMIT :pageSize OFFSET :pageOffset';

        Integer pageOffset = (pageNumber - 1) * pageSize;

        System.debug('Query: ' + query);

        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static Integer getOrderCount(Date effectiveDate, Date endDate, String status, String route, String searchKey, String pinCode) {
        String query = 'SELECT COUNT() FROM Order';
        List<String> filters = new List<String>();

        if (effectiveDate != null) {
            filters.add('EffectiveDate = :effectiveDate');
        }
        if (endDate != null) {
            filters.add('EndDate = :endDate');
        }
        if (status != null && status != '') {
            filters.add('Status = :status');
        }
        if (route != null && route != '') {
            filters.add('Route__c = :route');
        }
        if (searchKey != null && searchKey != '') {
            filters.add('OrderNumber LIKE \'%' + searchKey + '%\'');
        }
        if (pinCode != null && pinCode != '') {
            filters.add('ShippingPostalCode = :pinCode');
        }

        if (filters.size() > 0) {
            query += ' WHERE ' + String.join(filters, ' AND ');
        }

        System.debug('Count Query: ' + query);

        return (Integer) Database.countQuery(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getStatusOptions() {
        Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> picklistValues = new List<String>();
        for (Schema.PicklistEntry f : ple) {
            picklistValues.add(f.getLabel());
        }
        return picklistValues;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getRouteOptions() {
        Schema.DescribeFieldResult fieldResult = Order.Route__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> picklistValues = new List<String>();
        for (Schema.PicklistEntry f : ple) {
            picklistValues.add(f.getLabel());
        }
        return picklistValues;
    }

    @AuraEnabled(cacheable=true)
    public static List<ServiceResource> getServiceResources(List<String> routes, String resourceType) {
        System.debug('Selected Routes: ' + routes);
        System.debug('Resource Type: ' + resourceType);

        List<ServiceResource> serviceResources = [
            SELECT Id, Name, Route__c, Resource_Type__c
            FROM ServiceResource
            WHERE Route__c IN :routes AND Resource_Type__c = :resourceType
        ];

        System.debug('Service Resources: ' + serviceResources);

        return serviceResources;
    }

    @AuraEnabled
    public static void createWorkOrders(Id serviceResourceId, List<Order> orders) {
        Set<String> orderNumbers = new Set<String>();
        Set<Id> orderIds = new Set<Id>();

        for (Order order : orders) {
            orderNumbers.add(order.OrderNumber);
            orderIds.add(order.Id);
        }

        List<WorkOrder> existingWorkOrders = [
            SELECT Order_Number__c
            FROM WorkOrder
            WHERE Service_Resource__c = :serviceResourceId AND Order_Number__c IN :orderNumbers
        ];

        Set<String> existingOrderNumbers = new Set<String>();
        for (WorkOrder wo : existingWorkOrders) {
            existingOrderNumbers.add(wo.Order_Number__c);
        }

        
        List<WorkOrder> workOrdersToCreate = new List<WorkOrder>();
        for (Order order : orders) {
            if (!existingOrderNumbers.contains(order.OrderNumber)) {
                WorkOrder workOrder = new WorkOrder();
                workOrder.Service_Resource__c = serviceResourceId;
                workOrder.Delivery_Date__c = order.Delivery_Date__c;
                workOrder.Order_Number__c = order.OrderNumber;
                workOrder.Order_Date__c = order.EffectiveDate;
                workOrder.Pick_Up_Time__c = order.Pick_Up_Time__c;
                workOrder.Pickup_location__c = order.Pickup_location__c;
                workOrder.Pref_Delivery_Slot__c = order.Pref_Delivery_Slot__c;
                workOrder.Delivery_Address__Street__s = order.Delivery_Address__Street__s;
                workOrder.Delivery_Address__City__s = order.Delivery_Address__City__s;
                workOrder.Delivery_Address__PostalCode__s = order.Delivery_Address__PostalCode__s;
                workOrder.Delivery_Address__StateCode__s = order.Delivery_Address__StateCode__s;
                workOrder.Delivery_Address__CountryCode__s = order.Delivery_Address__CountryCode__s;
                workOrder.Delivery_Address__Latitude__s = order.Delivery_Address__Latitude__s;
                workOrder.Delivery_Address__Longitude__s = order.Delivery_Address__Longitude__s;
                workOrder.Delivery_Address__GeocodeAccuracy__s = order.Delivery_Address__GeocodeAccuracy__s;
                
                workOrder.AccountId = order.AccountId;
                workOrdersToCreate.add(workOrder);
            }
        }

        Map<String, String> workOrderMap = new Map<String, String>();

        if (!workOrdersToCreate.isEmpty()) {
            insert workOrdersToCreate;
            System.debug('Work Orders Created: ' + workOrdersToCreate);

            for (WorkOrder workOrder : workOrdersToCreate) {
                workOrderMap.put(workOrder.Order_Number__c, workOrder.Id);
            }

            System.debug('Work Orders Map: ' + workOrderMap);

            // Query all necessary Orders
            Map<Id, String> orderIdToOrderNumberMap = new Map<Id, String>();
            for (Order order : [SELECT Id, OrderNumber FROM Order WHERE Id IN :orderIds]) {
                orderIdToOrderNumberMap.put(order.Id, order.OrderNumber);
            }

            // Query related OrderItems
            List<OrderItem> relatedOrderItems = [
                SELECT Id, OrderId, Work_Order__c, Quantity, UnitPrice, TotalPrice
                FROM OrderItem
                WHERE OrderId IN :orderIds
            ];

            System.debug('Related Order Items: ' + relatedOrderItems);

            List<OrderItem> newOrderItems = new List<OrderItem>();
            for (OrderItem relatedOrderItem : relatedOrderItems) {
                String orderNumber = orderIdToOrderNumberMap.get(relatedOrderItem.OrderId);
                if (workOrderMap.containsKey(orderNumber)) {
                    OrderItem newOrderItem = new OrderItem();
                    newOrderItem.Id = relatedOrderItem.Id;
                    newOrderItem.Work_Order__c = workOrderMap.get(orderNumber);
                    newOrderItems.add(newOrderItem);
                }
            }

            if (!newOrderItems.isEmpty()) {
                update newOrderItems;
                System.debug('New Order Items Created: ' + newOrderItems);
            } else {
                System.debug('No New Order Items to Create');
            }

            // Query related Assets
            List<Asset> relatedAssets = [
                SELECT Id, Order__c, Work_Order__c
                FROM Asset
                WHERE Order__c IN :orderIds
            ];

            System.debug('Related Assets: ' + relatedAssets);

            List<Asset> assetsToUpdate = new List<Asset>();
            for (Asset asset : relatedAssets) {
                String orderNumber = orderIdToOrderNumberMap.get(asset.Order__c);
                if (workOrderMap.containsKey(orderNumber)) {
                    asset.Work_Order__c = workOrderMap.get(orderNumber);
                    assetsToUpdate.add(asset);
                }
            }

            if (!assetsToUpdate.isEmpty()) {
                update assetsToUpdate;
                System.debug('Assets Updated: ' + assetsToUpdate);
            } else {
                System.debug('No Assets to Update');
            }
        } else {
            System.debug('No Work Orders to Create');
        }
    }
}