({
    helperMethod : function(component ,event ,helper,MonthName,year) {
        
        var action = component.get('c.getMonthlyRecord');
        action.setParams({ 
            month:MonthName,
            year:year
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                var data = response.getReturnValue();
                if(data !=null && data.length >0){
                    var resultdata = data;
                    for(var i in resultdata){
                        resultdata[i].CreatedDateFormatted = resultdata[i].CreatedDate.slice(0,10);
                    }
                    component.set("v.dataList",resultdata);
                    // alert(JSON.stringify(data.dayVisitPlanList)) 
                }else{
                    component.set('v.dataList', []);
                }
            }
        });
        $A.enqueueAction(action);
        
    }
})