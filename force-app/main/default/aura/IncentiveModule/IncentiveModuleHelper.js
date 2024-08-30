({
   /* getMonthlyincentivecomponenet: function (component, event, helper,recId) {
		var action = component.get("c.getallIncentiveRecordList");
        action.setParams({
            "quarterid": recId
        });
        action.setCallback(this,function(response){  
            var state = response.getState();
            if(state ==="SUCCESS"){
                var data = response.getReturnValue(); 
                component.set("v.monthlyIncentiveModuleData",data );
                
            }
        });
        $A.enqueueAction(action);
    }*/
    
    parentComponentEvent:function(component, event, helper) {
        debugger;
        var message = event.getParam("message");
        //component.set("v.selectRecordId",message);
        var action = component.get("c.getallIncentiveRec");
          action.setParams({
            "fiscarYearid": 'a0k72000000mRtxAAE'
        });
        action.setCallback(this,function(response){  
            var state = response.getState();
            if(state ==="SUCCESS"){
                var results=response.getReturnValue(); 
                var recordIds = [];
                
                for (var i = 0; i < results.quarterlist.length; i++) {
                    recordIds.push(results.quarterlist[i].Id);
                }
                component.set("v.recordlist", results.recordIds);
                component.set("v.quarterlistRec1", results.quarterlist);
                component.set("v.quarterlistRec", results.quarterlist);
                
                component.set("v.fiscalyearNameRec", results.fiscalYearName);
                component.set("v.yearlygoalRecord", results.yearlygoal); 
                
                var totalT = results.yearlygoal.Yearly_Target__c;
                var totalTargetAchived = results.yearlygoal.Target_Achieved__c;
               var totalTAchivedIncentive = results.yearlygoal.Total_Incentive_Recieved__c; 
              
                 component.set("v.totalTarget" , parseInt(totalT)/10000000 +"cr"    ); 
                 component.set("v.totalTargetAchieved" , parseInt(totalTargetAchived)/100000 +"L"    ); 
                   component.set("v.totalAchievedIncentive" , parseInt(totalTAchivedIncentive)/100000 +"L"    ); 
                
                
                
                 component.set("v.incentivePercentage", results.yearlygoal.Achieved_Percentage__c);
                if(results.yearlygoal.Achieved_Percentage__c !=null && results.yearlygoal.Achieved_Percentage__c > 0){
                    var datapercentage = results.yearlygoal.Achieved_Percentage__c;  
                     component.set("v.actualProgress", datapercentage); 
                     component.set("v.isShowModuleDiv", true);
                 }
                if(results.yearlygoal.Total_Incentive_Recieved__c !=null && results.yearlygoal.Total_Incentive_Recieved__c > 0){
                    var totalincentive = results.yearlygoal.Total_Incentive_Recieved__c;  
                     component.set("v.totalincentiveRecived", totalincentive); 
                     component.set("v.isShowincentivevDiv", true);
                 }  
                  if(results.yearlygoal.Target_Achieved__c !=null && results.yearlygoal.Target_Achieved__c > 0){
                    var achivedTarget = results.yearlygoal.Target_Achieved__c;  
                     component.set("v.achivedTarget", achivedTarget); 
                     component.set("v.ShowacheivedDiv", true);
                 }
                 
                var quarterlistRec=component.get("v.quarterlistRec");
                if(quarterlistRec.length>0){
                    for(let i=0;i<quarterlistRec.length;i++){
                        if(quarterlistRec[i].Name){
                            const  StartPeriod=new Date(quarterlistRec[i].Quarter_Start_Period__c).toLocaleDateString('en-us', { year:"numeric", month:"long"});
                            const  EndPeriod=new Date(quarterlistRec[i].Quarter_End_Period__c).toLocaleDateString('en-us', { year:"numeric", month:"long"});
                            quarterlistRec[i].label= quarterlistRec[i].Name +'('+StartPeriod+' , '+EndPeriod+')';
                        }
                    }
                   component.set("v.quarterlistRec", quarterlistRec); 
                }
                
            }
        });
        $A.enqueueAction(action);
    }
	
})