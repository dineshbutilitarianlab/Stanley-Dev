({
    doInit : function(component, event, helper) {
        debugger;
        // var selectedVisitDate = component.get("v.SelectedVisitDate");
        var month=component.get("v.month");
        var year='2023';
        var monthYear=month+'-'+year;
        var baseURL = 'https://sales-production--mfgcloud--c.sandbox.vf.force.com/apex/MonthlyVisitViewer?id='+monthYear;
        component.set("v.siteURL",baseURL);
        console.log('baseURL === >'+baseURL);

    },
    
    //Deeenu are u there..?
    
    
    
})