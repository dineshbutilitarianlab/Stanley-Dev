({
    parentComponentEvent:function(component ,event ,helper) {
        
        var MPlist=[];
        var Month = event.getParam("Month");
        var Year = event.getParam("Year"); 
        component.set("v.selectedMonth",Month);
        component.set("v.selectedYear",Year);
        
        let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        let date=new Date();
        let year=date.getFullYear();
        let month=date.getMonth();
        let MonthName=monthNames[date.getMonth()];
        var action = component.get('c.getMonthBeatPlan');
        action.setParams({ 
            month:Month,
            year:Year
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                helper.helperMethod(component ,event ,helper,Month,year);
                var data = response.getReturnValue();
                if(data !=null && data!=undefined){
                    var mbplRecord =data.mbplRecord;
                    var approvalData =data.approvalData;
                    
                    // Set MonthlyBeatPlanDataList attribute
                    component.set("v.MonthlyBeatPlanDataList", mbplRecord);
                    component.set("v.approvalDetails", approvalData);
                    // Set userName attribute
                    component.set("v.userName", mbplRecord.Sales_User__r.Name);
                    component.set("v.ShowToCreateMonthlyBeatPlan",false);
                }else{
                    component.set("v.ShowToCreateMonthlyBeatPlan",true);
                } 
                
            }else{
                component.set("v.ShowToCreateMonthlyBeatPlan",true); 
            }
        });
        $A.enqueueAction(action);
        
    }    
    
})