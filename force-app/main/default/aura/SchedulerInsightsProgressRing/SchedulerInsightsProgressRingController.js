({
    /*init: function(component, event, helper) {
        // Sample data for demonstration purposes
        var action = component.get('c.getRoleAndKPI');
        var progressData = [
            { title: 'Site Visit', progress: 50 ,cl:'#7DC37D' },
            { title: 'CP Visit', progress: 75 ,cl:'#FFBB46' },
            { title: 'New Partner', progress: 10 ,cl:'#B7AAFF' },
            { title: 'Other KPI', progress: 90 ,cl:'#D5A9FF' }
        ];
        component.set('v.progressData', progressData);
    },*/
    
    init: function(component, event, helper) {
        debugger;
        // Sample data for demonstration purposes
        var cardData=[];
        var action = component.get('c.getCountOfVisitsForDifferentKPIs');
        action.setParams({
            monthName: component.get('v.selectedMonth'),
            monthYear: component.get('v.selectedYear')
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result != null){
                    var oppRecCount = result;
                    var tempLength=0;
                    var temparray = [];    
                    
                    for (let i = 0; i < oppRecCount.length; i++) {
                        tempLength++;
                        let Obj = { title: '', progress: 0, cl: '' };
                        Obj.title = oppRecCount[i].KPI_Target_Name__c;
                        var targetCount = oppRecCount[i].Target_Count__c;
                        var acheivedCount = oppRecCount[i].Achieved_Count__c;
                        if(acheivedCount == 0 || acheivedCount == null || acheivedCount == undefined){
                            var percentProgress = 0;
                        }else{
                         var percentProgress = Math.round((acheivedCount/targetCount)*100);   
                        }
                        // Generate a random number between 40 and 90 (inclusive)
                       // Obj.progress = Math.floor(Math.random() * (90 - 40 + 1)) + 40;
                       Obj.progress = percentProgress;
                        
                        if (tempLength == 1)
                            Obj.cl = '#7DC37D';
                        else if (tempLength == 2)
                            Obj.cl = '#FFBB46';
                            else if (tempLength == 3)
                                Obj.cl = '#B7AAFF';
                                else if (tempLength == 4)
                                    Obj.cl = '#D5A9FF';
                        
                        if (tempLength == 4)
                            tempLength = 0;
                        
                        cardData.push(Obj);
                    }
                    // Set the data in the component attribute
                    console.log('cardData--'+JSON.stringify(cardData));
                    component.set('v.progressData', cardData);
                }
            }            
        });
        $A.enqueueAction(action);
        
    },
    
    handleSectionToggle: function (cmp, event) { 
        debugger;
      
    },
    
})