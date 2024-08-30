({
	init: function(component, event, helper) {
        helper.getCardData(component);
    },
    getrecord: function(component, event, helper) {
        debugger;
        var listviewId = event.target.dataset.id;
        var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": listviewId,
                "listViewName": null,
                "scope": "Account"
            });
            navEvent.fire();
    }
})