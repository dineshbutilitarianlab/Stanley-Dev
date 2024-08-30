({ 
    
    afterScriptsLoaded: function(component,event ,helper){
        debugger;
        var Month = component.get("v.month");
        var Year = component.get("v.year");
        //var events = component.get("v.events");
        //console.log('events--------IN',events);
        //if(!events.length)
        
            helper.fetchEvents(component,event);
       // /
    },
    
    afterRender: function(component, helper) {
        setTimeout(function() {
            this.superAfterRender();
            helper.setupDraggableEvents(component);
        }, 2000);
        
    }
    
})