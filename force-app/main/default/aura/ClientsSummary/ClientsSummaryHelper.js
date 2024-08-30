({
    getCardData: function(component) {
        debugger;
        var action = component.get('c.getAllAccountCount');
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result != null){
                    var oppRecCount = result.oppToatlCount;
                    var accETBRecCount = result.accETBCount;
                    var accNTBRecCount = result.accNTBCount;
                    var accLCRecCount = result.accLCCount;
                    var cardData = [
                        { Title: 'Total Prospects', Description:''  ,cl: '#62b7ed' ,Padding: '2%', View: 'View' ,listviewId: '00B5j000007Y2RDEA0', wi:'70%' ,ml:'14%' ,br:'8px' ,mr:'-1%'},
                        { Title: 'Existing To Business', Description: '' ,cl: '#62b7ed' ,Padding: '2%' ,View: 'View' ,listviewId: '00B5j000007Y2R7EAK',wi:'70%' ,ml:'14%' ,br:'8px' ,mr:'0%'},
                        { Title: 'New To Business', Description: '' ,cl: '#62b7ed' ,Padding: '2%' ,View: 'View' ,listviewId: '00B5j000007Y2R7EAK',wi:'70%' ,ml:'14%' ,br:'8px' ,mr:'0%'},
                        { Title: 'Lost Clients', Description: '' ,cl: '#62b7ed' ,Padding: '2%' ,View: 'View' ,listviewId: '00B5j000007Y2R7EAK',wi:'70%' ,ml:'14%' ,br:'8px' ,mr:'-1%'}
                    ];
                    var temparray = [];
                    for(var i in cardData){
                        if(cardData[i].Title == 'Total Prospects'){
                            cardData[i].Description = oppRecCount;
                            temparray.push(cardData[i].Description);
                        }
                        if(cardData[i].Title == 'Existing To Business'){
                            cardData[i].Description = accETBRecCount;
                            temparray.push(cardData[i].Description);
                        }
                        if(cardData[i].Title == 'New To Business'){
                            cardData[i].Description = accNTBRecCount;
                            temparray.push(cardData[i].Description);
                        }
                        if(cardData[i].Title == 'Lost Clients'){
                            cardData[i].Description = accLCRecCount;
                            temparray.push(cardData[i].Description);
                        }
                    }
                    component.set('v.cardData', cardData);
                }
            }            
        });
        $A.enqueueAction(action);
        
    }
})