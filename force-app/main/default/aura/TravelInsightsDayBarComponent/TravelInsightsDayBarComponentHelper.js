({
	getNextMonthAndYear:function(component,event,helper,month,year) {
        const mql = window.matchMedia('(max-width: 820px)');
		let mobileView = mql.matches;
        if(mobileView){
            var MonthListOnUI=component.get("v.MonthListToShowMobile");
        let monthNamesAndValues = [{month:"January",value:1},{month:"February",value:2},{month:"March",value:3}, {month:"April",value:4}, {month:"May",value:5}, {month:"June",value:6},{month:"July",value:7},{month:"August",value:8},{month:"September",value:9},{month:"October",value:10},{month: "November",value:11},{month:"December",value:12}];
        let currentDate = new Date(year, month +1, 1); // Month is zero-based
        let previousMonth = (currentDate.getMonth() === 0) ? 11 : currentDate.getMonth() - 1;
        let previousYear = (currentDate.getMonth() === 0) ? currentDate.getFullYear() - 1 : currentDate.getFullYear();
        if(previousMonth!=undefined && previousYear!=undefined){
            previousMonth=previousMonth+1;
            previousYear= previousYear
        }
        console.log(`Previous Month: ${previousMonth}, Previous Year: ${previousYear}`);
        
        let lastelement=MonthListOnUI.shift();//Removes First Element From Array
        console.log('MonthListOnUI After Shift--'+JSON.stringify(MonthListOnUI));
        let newMonthToadd=(monthNamesAndValues.find(item=>item.value==previousMonth)).month;
        newMonthToadd=newMonthToadd+' '+previousYear;
        console.log('newMonthToadd--'+JSON.stringify(newMonthToadd));
        let objtoadd={month:newMonthToadd,colormatch:false};
        MonthListOnUI.push(objtoadd);
        console.log('MonthListOnUI After Push--'+JSON.stringify(MonthListOnUI));
        component.set("v.MonthListToShowMobile",MonthListOnUI);
        }else{
            var MonthListOnUI=component.get("v.MonthListToShow");
        let monthNamesAndValues = [{month:"January",value:1},{month:"February",value:2},{month:"March",value:3}, {month:"April",value:4}, {month:"May",value:5}, {month:"June",value:6},{month:"July",value:7},{month:"August",value:8},{month:"September",value:9},{month:"October",value:10},{month: "November",value:11},{month:"December",value:12}];
        let currentDate = new Date(year, month +1, 1); // Month is zero-based
        let previousMonth = (currentDate.getMonth() === 0) ? 11 : currentDate.getMonth() - 1;
        let previousYear = (currentDate.getMonth() === 0) ? currentDate.getFullYear() - 1 : currentDate.getFullYear();
        if(previousMonth!=undefined && previousYear!=undefined){
            previousMonth=previousMonth+1;
            previousYear= previousYear
        }
        console.log(`Previous Month: ${previousMonth}, Previous Year: ${previousYear}`);
        
        let lastelement=MonthListOnUI.shift();//Removes First Element From Array
        console.log('MonthListOnUI After Shift--'+JSON.stringify(MonthListOnUI));
        let newMonthToadd=(monthNamesAndValues.find(item=>item.value==previousMonth)).month;
        newMonthToadd=newMonthToadd+' '+previousYear;
        console.log('newMonthToadd--'+JSON.stringify(newMonthToadd));
        let objtoadd={month:newMonthToadd,colormatch:false};
        MonthListOnUI.push(objtoadd);
        console.log('MonthListOnUI After Push--'+JSON.stringify(MonthListOnUI));
        component.set("v.MonthListToShow",MonthListOnUI);
        }
        
    },
    
    getPreviousMonthAndYear : function(component,event,helper,month,year) {
        	const mql = window.matchMedia('(max-width: 820px)');
			let mobileView = mql.matches;
        if(mobileView){
            var MonthListOnUI=component.get("v.MonthListToShowMobile");
            let monthNamesAndValues = [{month:"January",value:1},{month:"February",value:2},{month:"March",value:3}, {month:"April",value:4}, {month:"May",value:5}, {month:"June",value:6},{month:"July",value:7},{month:"August",value:8},{month:"September",value:9},{month:"October",value:10},{month: "November",value:11},{month:"December",value:12}];
            let currentDate = new Date(year, month - 1, 1); // Month is zero-based
            let previousMonth = (currentDate.getMonth() === 0) ? 11 : currentDate.getMonth() - 1;
            let previousYear = (currentDate.getMonth() === 0) ? currentDate.getFullYear() - 1 : currentDate.getFullYear();
            if(previousMonth!=undefined && previousYear!=undefined){
                previousMonth=previousMonth+1;
                previousYear= previousYear
            }
            console.log(`Previous Month: ${previousMonth}, Previous Year: ${previousYear}`);
           
            let lastelement=MonthListOnUI.pop();//Removes The Last Element From List 
            console.log('MonthListOnUI After POP--'+JSON.stringify(MonthListOnUI));
            let newMonthToadd=(monthNamesAndValues.find(item=>item.value==previousMonth)).month;
            newMonthToadd=newMonthToadd+' '+previousYear;
            console.log('newMonthToadd--'+JSON.stringify(newMonthToadd));
            let objtoadd={month:newMonthToadd,colormatch:false};
            MonthListOnUI.unshift(objtoadd);
            console.log('MonthListOnUI After Unshift--'+JSON.stringify(MonthListOnUI));
            component.set("v.MonthListToShowMobile",MonthListOnUI);
        }else{
            var MonthListOnUI=component.get("v.MonthListToShow");
            let monthNamesAndValues = [{month:"January",value:1},{month:"February",value:2},{month:"March",value:3}, {month:"April",value:4}, {month:"May",value:5}, {month:"June",value:6},{month:"July",value:7},{month:"August",value:8},{month:"September",value:9},{month:"October",value:10},{month: "November",value:11},{month:"December",value:12}];
            let currentDate = new Date(year, month - 1, 1); // Month is zero-based
            let previousMonth = (currentDate.getMonth() === 0) ? 11 : currentDate.getMonth() - 1;
            let previousYear = (currentDate.getMonth() === 0) ? currentDate.getFullYear() - 1 : currentDate.getFullYear();
            if(previousMonth!=undefined && previousYear!=undefined){
                previousMonth=previousMonth+1;
                previousYear= previousYear
            }
            console.log(`Previous Month: ${previousMonth}, Previous Year: ${previousYear}`);
           
            let lastelement=MonthListOnUI.pop();//Removes The Last Element From List 
            console.log('MonthListOnUI After POP--'+JSON.stringify(MonthListOnUI));
            let newMonthToadd=(monthNamesAndValues.find(item=>item.value==previousMonth)).month;
            newMonthToadd=newMonthToadd+' '+previousYear;
            console.log('newMonthToadd--'+JSON.stringify(newMonthToadd));
            let objtoadd={month:newMonthToadd,colormatch:false};
            MonthListOnUI.unshift(objtoadd);
            console.log('MonthListOnUI After Unshift--'+JSON.stringify(MonthListOnUI));
            component.set("v.MonthListToShow",MonthListOnUI);
        }
            
    },
})