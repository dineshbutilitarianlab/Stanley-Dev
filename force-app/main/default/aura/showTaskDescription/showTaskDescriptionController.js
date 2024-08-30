({
    doinit : function(component, event, helper) {
        debugger;
        var visitrecord=[];
        //var accountId =component.get("c.getTaskdetails");
        var action = component.get("c.getTaskdetails");
        action.setParams({ accountId : component.get("v.SelectVisitAccountId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                visitrecord= response.getReturnValue();
                //alert("From server: ");
                component.set("v.Visits",visitrecord[0]);
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    }
    
})