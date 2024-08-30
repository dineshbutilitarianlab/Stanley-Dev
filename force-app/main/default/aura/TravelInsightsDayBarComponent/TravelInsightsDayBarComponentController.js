({
	doInit : function(component, event, helper) {
        
        let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        let date=new Date();
        let year=date.getFullYear();
        let month=date.getMonth();
        let MonthName=monthNames[date.getMonth()]+' '+year;
        
		component.set("v.MonthList",['January'+' '+year, 'February'+' '+year, 'March'+' '+year, 'April'+' '+year, 'May'+' '+year, 'June'+' '+year, 'July'+' '+year, 'August'+' '+year, 'September'+' '+year, 'October'+' '+year, 'November'+' '+year, 'December'+' '+year]);
        var FirstMonthList=[{month:'January'+' '+year,colormatch:null},{month:'February'+' '+year,colormatch:null},{month:'March'+' '+year,colormatch:null},{month:'April'+' '+year,colormatch:null},{month:'May'+' '+year,colormatch:null} ,{month:'June'+' '+year,colormatch:null}];
        var SecondMonthList=[{month:'July'+' '+year,colormatch:null},{month:'August'+' '+year,colormatch:null},{month:'September'+' '+year,colormatch:null},{month:'October'+' '+year,colormatch:null},{month:'November'+' '+year,colormatch:null},{month:'December'+' '+year,colormatch:null}];
        var FirstMonthListMobile = [{month:'January'+' '+year,colormatch:null},{month:'February'+' '+year,colormatch:null},{month:'March'+' '+year,colormatch:null}];
        var SecondMonthListMobile = [{month:'April'+' '+year,colormatch:null},{month:'May'+' '+year,colormatch:null} ,{month:'June'+' '+year,colormatch:null}];
        var ThirdMonthListMobile = [{month:'July'+' '+year,colormatch:null},{month:'August'+' '+year,colormatch:null},{month:'September'+' '+year,colormatch:null}];
        var FourthMonthListMobile = [{month:'October'+' '+year,colormatch:null},{month:'November'+' '+year,colormatch:null},{month:'December'+' '+year,colormatch:null}];
        var allMonthListMobile = [{month:'January'+' '+year,colormatch:null},{month:'February'+' '+year,colormatch:null},{month:'March'+' '+year,colormatch:null},{month:'April'+' '+year,colormatch:null},{month:'May'+' '+year,colormatch:null} ,{month:'June'+' '+year,colormatch:null},{month:'July'+' '+year,colormatch:null},{month:'August'+' '+year,colormatch:null},{month:'September'+' '+year,colormatch:null},{month:'October'+' '+year,colormatch:null},{month:'November'+' '+year,colormatch:null},{month:'December'+' '+year,colormatch:null}];
        for(let i=0;i<FirstMonthList.length;i++){
            if(FirstMonthList[i].month==MonthName){
                FirstMonthList[i].colormatch=true;
                console.log('FirstMonthList');
                component.set("v.MonthListToShow",FirstMonthList); 
            }
        }
        for(let i=0;i<SecondMonthList.length;i++){
            if(SecondMonthList[i].month==MonthName){
                SecondMonthList[i].colormatch=true;
                console.log('SecondMonthList');
                component.set("v.MonthListToShow",SecondMonthList); 
            }else{
                SecondMonthList[i].colormatch=false;
            }
        }
        
        /*for(let i=0;i<FirstMonthListMobile.length;i++){
            if(FirstMonthListMobile[i]==MonthName){
                console.log('FirstMonthListMobile');
                component.set("v.MonthListToShowMobile",FirstMonthListMobile); 
            }
        }
        for(let i=0;i<SecondMonthListMobile.length;i++){
            if(SecondMonthListMobile[i].month==MonthName){
                SecondMonthListMobile[i].colormatch=true;
                console.log('SecondMonthListMobile');
                component.set("v.MonthListToShowMobile",SecondMonthListMobile); 
            }else{
                SecondMonthListMobile[i].colormatch=false;
            }
        }
        for(let i=0;i<ThirdMonthListMobile.length;i++){
            if(ThirdMonthListMobile[i].month==MonthName){
                ThirdMonthListMobile[i].colormatch=true;
                console.log('ThirdMonthListMobile');
                component.set("v.MonthListToShowMobile",ThirdMonthListMobile); 
            }else{
                ThirdMonthListMobile[i].colormatch=false;
            }
        }
        for(let i=0;i<FourthMonthListMobile.length;i++){
            if(FourthMonthListMobile[i].month==MonthName){
                FourthMonthListMobile[i].colormatch=true;
                console.log('FourthMonthListMobile');
                component.set("v.MonthListToShowMobile",FourthMonthListMobile); 
            }else{
                FourthMonthListMobile[i].colormatch=false;
            }
        }*/
        for(let i=0;i<allMonthListMobile.length;i++){
            if(allMonthListMobile[i].month==MonthName){
                allMonthListMobile[i].colormatch=true;
                console.log('allMonthListMobile');
                component.set("v.MonthListToShowMobile",allMonthListMobile); 
            }else{
                allMonthListMobile[i].colormatch=false;
            }
        }
        var cmpEvent = component.getEvent("sampleCmpEvent"); 
        //Set event attribute value
        cmpEvent.setParams({
            "Month" : monthNames[date.getMonth()],
             "Year":year
        }); 
        cmpEvent.fire(); 
	},
    
    handlePrevClicked:function(component, event, helper) {
        let FirstIndexMonth;
        const mql = window.matchMedia('(max-width: 820px)');
		 let mobileView = mql.matches;
        if(mobileView){
            var MonthListOnUI=component.get("v.MonthListToShowMobile");
        for(let i=0;i<MonthListOnUI.length;i++){
            if(i==0){
                FirstIndexMonth=MonthListOnUI[i].month;
                break;  
            }    
        }
        let MonthYearArray=FirstIndexMonth.split(' ');
        
        let inputMonth; 
        let inputYear;
        let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        let monthNamesAndValues = [{month:"January",value:1},{month:"February",value:2},{month:"March",value:3}, {month:"April",value:4}, {month:"May",value:5}, {month:"June",value:6},{month:"July",value:7},{month:"August",value:8},{month:"September",value:9},{month:"October",value:10},{month: "November",value:11},{month:"December",value:12}];
        if(MonthYearArray[0]!=null && MonthYearArray[1]!=null){
            for(let i=0;i<monthNamesAndValues.length;i++){
                if(monthNamesAndValues[i].month==MonthYearArray[0]){
                    inputMonth=monthNamesAndValues[i].value;
                    inputYear=MonthYearArray[1];
                }
            }
        }
        if(inputMonth!=undefined && inputYear!=undefined)
            helper.getPreviousMonthAndYear(component,event,helper,inputMonth,inputYear); 
        }else{
            var MonthListOnUI=component.get("v.MonthListToShow");
        for(let i=0;i<MonthListOnUI.length;i++){
            if(i==0){
                FirstIndexMonth=MonthListOnUI[i].month;
                break;  
            }    
        }
        let MonthYearArray=FirstIndexMonth.split(' ');
        
        let inputMonth; 
        let inputYear;
        let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        let monthNamesAndValues = [{month:"January",value:1},{month:"February",value:2},{month:"March",value:3}, {month:"April",value:4}, {month:"May",value:5}, {month:"June",value:6},{month:"July",value:7},{month:"August",value:8},{month:"September",value:9},{month:"October",value:10},{month: "November",value:11},{month:"December",value:12}];
        if(MonthYearArray[0]!=null && MonthYearArray[1]!=null){
            for(let i=0;i<monthNamesAndValues.length;i++){
                if(monthNamesAndValues[i].month==MonthYearArray[0]){
                    inputMonth=monthNamesAndValues[i].value;
                    inputYear=MonthYearArray[1];
                }
            }
        }
        if(inputMonth!=undefined && inputYear!=undefined)
            helper.getPreviousMonthAndYear(component,event,helper,inputMonth,inputYear); 
        }
        
    },
     handleNextClicked:function(component, event, helper) {
        let FirstIndexMonth;
         const mql = window.matchMedia('(max-width: 820px)');
		 let mobileView = mql.matches;
         if(mobileView){
             var MonthListOnUI=component.get("v.MonthListToShowMobile");
         for(let i=0;i<MonthListOnUI.length;i++){
             if(i==2){
                 FirstIndexMonth=MonthListOnUI[i].month;
                 break;
             }     
         }
         let MonthYearArray=FirstIndexMonth.split(' ');
         
         let inputMonth; 
         let inputYear;
         let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
         let monthNamesAndValues = [{month:"January",value:1},{month:"February",value:2},{month:"March",value:3}, {month:"April",value:4}, {month:"May",value:5}, {month:"June",value:6},{month:"July",value:7},{month:"August",value:8},{month:"September",value:9},{month:"October",value:10},{month: "November",value:11},{month:"December",value:12}];
         if(MonthYearArray[0]!=null && MonthYearArray[1]!=null){
             for(let i=0;i<monthNamesAndValues.length;i++){
                 if(monthNamesAndValues[i].month==MonthYearArray[0]){
                     inputMonth=monthNamesAndValues[i].value;
                     inputYear=MonthYearArray[1];
                 }
             }
         }
         if(inputMonth!=undefined && inputYear!=undefined)
             helper.getNextMonthAndYear(component,event,helper,inputMonth,inputYear);  
         }
         else{
             var MonthListOnUI=component.get("v.MonthListToShow");
         for(let i=0;i<MonthListOnUI.length;i++){
             if(i==5){
                 FirstIndexMonth=MonthListOnUI[i].month;
                 break;
             }     
         }
         let MonthYearArray=FirstIndexMonth.split(' ');
         
         let inputMonth; 
         let inputYear;
         let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
         let monthNamesAndValues = [{month:"January",value:1},{month:"February",value:2},{month:"March",value:3}, {month:"April",value:4}, {month:"May",value:5}, {month:"June",value:6},{month:"July",value:7},{month:"August",value:8},{month:"September",value:9},{month:"October",value:10},{month: "November",value:11},{month:"December",value:12}];
         if(MonthYearArray[0]!=null && MonthYearArray[1]!=null){
             for(let i=0;i<monthNamesAndValues.length;i++){
                 if(monthNamesAndValues[i].month==MonthYearArray[0]){
                     inputMonth=monthNamesAndValues[i].value;
                     inputYear=MonthYearArray[1];
                 }
             }
         }
         if(inputMonth!=undefined && inputYear!=undefined)
             helper.getNextMonthAndYear(component,event,helper,inputMonth,inputYear);  
         }
        
    },
    handleClick:function(component, event, helper) {
        
        var MonthlyList= component.get("v.MonthListToShow");
        var selectedMonth = event.getSource().get('v.value');
        for(let i=0;i<MonthlyList.length;i++){
            if(MonthlyList[i].month==selectedMonth){
                MonthlyList[i].colormatch=true;
            }else{
                MonthlyList[i].colormatch=false;
            }
        }
        component.set("v.MonthListToShow",MonthlyList); 
        const str = selectedMonth;
        let Array=str.split(' ');
        let Month=Array[0];
        let Year=Array[1];
        var cmpEvent = component.getEvent("sampleCmpEvent"); 
        //Set event attribute value
        cmpEvent.setParams({
            "Month" : Month,
             "Year":Year
        }); 
        cmpEvent.fire(); 


    }
})