({
    doinit : function(component ,event ,helper){
        debugger;
        window.addEventListener('message', $A.getCallback(function(postMessageEvent){
            if(postMessageEvent.data.name == 'Visit Created'){
                console.log('Data Received');
                component.set('v.showApprovalButton', true);
            }
        })); 
    },
    handleSectionToggle: function (cmp, event) { 
        debugger;
      
    },
    afterScriptsLoaded: function(component,event ,helper){
     
    },
    afterRender: function(component, helper) {
        debugger;
        this.superAfterRender();
        helper.setupDraggableEvents(component);
    },
    parentComponentEvent:function(component ,event ,helper) {
        debugger;
        const today = new Date();
        //var day = String(today.getDate() + 1).padStart(2, '0');
        var day = String(today.getDate() + 1 ).padStart(2, '0');
        day = day;
        var wrappdata;
        var mbl=[];
        var visitList=[];
        var Month = event.getParam("Month");
        var Year = event.getParam("Year"); 
        component.set("v.selectedMonth",Month);
        component.set("v.selectedYear",Year);
        const formattedDate = `${Year}-${Month}-${day}`;
        component.set("v.ShowToCreateMonthlyBeatPlan",false);
        //Set the handler attributes based on event data 
        var action = component.get("c.BeetplannerDatareturn"); 
        action.setParams({ 
            month : Month,
            year:Year
        });        
        // Create a callback that is executed after 
        // the server-side action returns
        var monthYear=Month+'-'+Year;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                wrappdata = response.getReturnValue();
                let datacheck = Object.keys(wrappdata);
                if(Object.keys(wrappdata).length > 0){
                    var isApprovalRequired = wrappdata.isApprovalRequired;
                    component.set("v.ShowMonthlyBeatPlan",false);
                    component.set("v.ShowMonthlyBeatPlan",true);
                    // wrappdata.visitRecList[0].Visit__r
                    if (wrappdata.MBPlist.Weekly_Beat_Plans__r != undefined) {
                        component.set("v.Weeklybp",wrappdata.MBPlist.Weekly_Beat_Plans__r);
                    }
                    component.set("v.weeklyWrapper",wrappdata.weeklyWrapper);
                    component.set("v.kpiTargetsName",wrappdata.MBPlist.KPI_Targets__r)
                    component.set("v.recordId",wrappdata.MBPlist.Id);
                    component.set("v.mbpName",wrappdata.MBPlist.Name);
                    component.set("v.userName",wrappdata.MBPlist.Sales_User__r.Name);
                    component.set("v.month",wrappdata.MBPlist.Month_Name__c);
                    component.set("v.mbpStatus",wrappdata.MBPlist.Status__c);
                    var tempKPIList=wrappdata.weeklyWrapper;
                    for(let j=0;j<wrappdata.weeklyWrapper.length;j++){
                        let TempArray=wrappdata.weeklyWrapper[j].kpiList;
                        for (let i = 0; i <TempArray.length; i++) {
                            if (i % 2 === 0) {
                                TempArray[i].dynamicClass='slds-badge slds-theme_success';
                                // console.log(i + " is even");
                            } else {
                                TempArray[i].dynamicClass='slds-badge slds-badge_inverse';
                                // console.log(i + " is odd");
                            }
                        }
                        // console.log('TempArray---'+JSON.stringify(TempArray));
                        wrappdata.weeklyWrapper[j].kpiList=TempArray;
                    }
                    component.set("v.Visits",visitList);
                    if(isApprovalRequired){
                        component.set('v.isApprovalRequired', true);
                        component.set("v.showApprovalButton",wrappdata.showApprovalButton);
                        if(wrappdata.MBPlist.Status__c=='Approved'){
                        component.set("v.showApprovedCal",false);
                        component.set("v.showApprovedCal",true);
                        component.set("v.showUnapprovedCal",false);
                        let isShowpageCally=component.get("v.showApprovedCal")
                        if(isShowpageCally==true){
                            component.set("v.showUnapprovedCal",false);
                            component.set("v.showApprovedCal",true);
                            component.set("v.showUnapprovedCal",false);
                        }
                        else if(isShowpageCally==false){
                            component.set("v.showApprovedCal",false);
                            component.set("v.showUnapprovedCal",true);
                        }
                    }
                    else{
                        component.set("v.showApprovedCal",false);
                        component.set("v.showUnapprovedCal",true);
                    }
                    if(wrappdata.MBPlist.Status__c!='Approved'){
                        component.set("v.showUnapprovedCal",false);
                        component.set("v.showUnapprovedCal",true);
                        component.set("v.showApprovedCal",false);
                    }
                    }else{
                        component.set('v.isApprovalRequired', false);
                        component.set("v.showApprovedCal",false);
                        component.set("v.showUnapprovedCal",true);
                    }
                    helper.fetchEvents(component,event);
                    //var formatted=component.get("v.formattedDate");
                    var baseURL = $A.get("$Label.c.orgBaseURLforVFPages");
                    debugger;
                    baseURL = baseURL + 'apex/MonthlyVisitViewer?id='+formattedDate;
                    component.set("v.siteURL", baseURL);
                }else{
                    component.set("v.ShowMonthlyBeatPlan",false);
                    component.set("v.ShowToCreateMonthlyBeatPlan",true);
                }
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
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Successfully Send for Approval',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            } else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'This is an error message',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    },
    closeModel:function(component ,event ,helper){
        debugger;
        component.set("v.isShowDaskDesComp",false);
    }
    
    
})