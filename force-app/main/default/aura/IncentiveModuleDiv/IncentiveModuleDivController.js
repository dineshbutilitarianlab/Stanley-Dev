({
	doInit : function(component, event, helper) {
        debugger;
       var actualVal1 = component.get("v.actualProgress"); 
        
	 helper.doInit1(component, event, helper) ;	
        
        /*var action = component.get("c.geahievedPercentage")
        action.setCallback(this,function(response){  
            var state = response.getState();
            if(state ==="SUCCESS"){
                var data = response.getReturnValue(); 
                component.set("v.actualProgress",data );
               
            }
        });
        $A.enqueueAction(action);*/
	}
})