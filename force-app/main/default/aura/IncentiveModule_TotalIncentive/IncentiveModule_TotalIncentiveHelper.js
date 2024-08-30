({
	doInit1 : function(component, event, helper)  {
        debugger;
        helper.computeProgress(component, event, helper);
        
	},
    computeProgress : function(component, event, helper)  {
        debugger;
        var totalVal = component.get("v.totalProgress");
        var actualVal = component.get("v.actualProgress"); 
        
        if(totalVal && actualVal && !isNaN(parseInt(totalVal)) && isFinite(totalVal) && !isNaN(parseInt(actualVal)) && isFinite(actualVal)){
           //parameter is number 
            var percVal = parseInt(actualVal) / parseInt(totalVal) ;
            var progressVal = parseInt(  percVal * 360  ) ;
             component.set("v.cirDeg" , progressVal );
             component.set("v.perText" ,parseInt(percVal * 100)/10000000 +"Cr"   ); 
        }else if(actualVal){
            helper.callApexMethod(component, event, helper, totalVal, actualVal);
        }
    },
    callApexMethod : function(component, event, helper, txt_totalVal, txt_actualVal)  {
        debugger;
        var action = component.get('c.computePercentage');
        var txt_recordId = component.get("v.recordId");
        var txt_sObjectName = component.get("v.sObjectName");
        
        action.setParams({
            recordId : txt_recordId,
            sObjectName : txt_sObjectName,
            totalValueFieldName : txt_totalVal,
            actualValueFieldName : txt_actualVal
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === 'SUCCESS') {
                var percVal = a.getReturnValue() ; 
                var progressVal = parseInt(  (percVal/100) * 360  ) ; 
                component.set("v.cirDeg" , progressVal );
                component.set("v.perText" , parseInt(percVal)    );              
            }  
        });
        $A.enqueueAction(action);  
    }
})