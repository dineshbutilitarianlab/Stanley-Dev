({
    doinit : function(component ,event ,helper) {
        debugger;
        /*var Wrapper=[];
        var MPlist=[];
        var KPIrecord=[];
        var VisitRecord=[];
        var action = component.get("c.BeetplannerDatareturn");
        action.setParams({ firstName : component.get("v.firstName") });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                MPlist=response.getReturnValue();
                //alert("From server: " + );
                component.set("v.Weeklybp",MPlist);
                
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
        
        $A.enqueueAction(action);*/
    },
    parentComponentEvent:function(component ,event ,helper) {
        
        debugger;
        
        var wrappdata;
        var mbl=[];
        var Month = event.getParam("Month");
        var Year = event.getParam("Year"); 
        component.set("v.selectedMonth",Month);
        component.set("v.selectedYear",Year);
        //component.set("v.ShowToCreateMonthlyBeatPlan",true);
        //Set the handler attributes based on event data 
        var action = component.get("c.BeetplannerDatareturn");
        action.setParams({ 
            month : Month,
            year:Year
        });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                wrappdata=response.getReturnValue();
                //alert("From server: " + );
                // wrappdata.MBPlist.Status__c
                component.set("v.Weeklybp",wrappdata.MBPlist.Weekly_Beat_Plans__r);
                console.log('wrappdata.MBPlist.Weekly_Beat_Plans------->',wrappdata.MBPlist.Weekly_Beat_Plans__r);
                
                component.set("v.selectedMonth",wrappdata.MBPlist.Month_Name__c);
                component.set("v.selectedYear",wrappdata.MBPlist.Year__c.toString());
                
                mbl=wrappdata.MBPlist;
                
                var childComponent =component.find("childComp");
                if (childComponent) {
                    component.set("v.showApprovedCal",true);
                    childComponent.helper.fetchEvents(component,wrappdata.MBPlist.Month_Name__c,wrappdata.MBPlist.Year__c); // Call the child method
                    
                }
                
                
                
                var isCallyopen=component.get("v.showUnapprovedCal");
                var childComponentt =component.find("chilcally");
                if (childComponentt) {
                    //component.set("v.showApprovedCal",true);
                    childComponentt.helper.fromParent(component ,event ,helper); // Call the child method
                    
                }
                
                if(wrappdata.MBPlist.Month_Name__c.length>0){
                    component.set("v.mbpStatus",wrappdata.MBPlist.Status__c);
                    if(wrappdata.MBPlist.Status__c=='Approved'){
                        component.set("v.showApprovedCal",true);
                        component.set("v.showUnapprovedCal",false);
                    }else{
                        component.set("v.showApprovedCal",false);
                        component.set("v.showUnapprovedCal",true);
                        
                    }
                    component.set("v.recordId",wrappdata.MBPlist.Id);
                    component.set("v.mbpName",wrappdata.MBPlist.Name);
                    component.set("v.month",wrappdata.MBPlist.Month_Name__c);
                    component.set("v.ShowToCreateMonthlyBeatPlan",false);
                    
                    
                    
                }
                else{
                    component.set("v.ShowToCreateMonthlyBeatPlan",true); 
                    component.set("v.showApprovedCal",false);
                }
                
                
            }
            else if (state === "INCOMPLETE") {
                // do something
                var childComponent =component.find("childComp");
                if (childComponent) {
                    component.set("v.showApprovedCal",true);
                    childComponent.helper.fetchEvents(component,Month,Year); // Call the child method
                    
                }
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    var childComponent =component.find("childComp");
                    if (childComponent) {
                        component.set("v.showApprovedCal",true);
                        childComponent.helper.fetchEvents(component,Month,Year); // Call the child method
                        
                    }
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
        
    },
    
    sendForApp:function(component ,event ,helper){
        debugger;
        var recId=event.target.Id;
        var action = component.get("c.initiateApprovalProcess");
        action.setParams({
            recordId: component.get("v.recordId") // Pass the relevant record Id to the Apex method
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('Successfully Sent');
                // Handle success, e.g., display a toast message or refresh the page
            } else if (state === "ERROR") {
                var errors = response.getError();
                // Handle errors, e.g., display error messages
            }
        });
        
        $A.enqueueAction(action);
    },
    
    callCall:function(component ,event ,helper){
        debugger
        
    }
})