({
    getVisitRecs : function(component, event, helper) {
        debugger;
        var helper = this;
        var today = new Date();
        var selectedDate = component.get('v.selectedDate');        
        var year = today.getFullYear();
        var month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
        var day = String(today.getDate()).padStart(2, '0');
        // Format the date in "YYYY-MM-DD" format
        var formattedDate = year + '-' + month + '-' + day;
        if(selectedDate != null && selectedDate != undefined){
            formattedDate = selectedDate;
        }
        component.set('v.SelectedVisitDateFromTaskComp', formattedDate);
        component.set('v.selectedDate', formattedDate);
        var action = component.get('c.getAllVisitToday');
        action.setParams({
            visitDate :  formattedDate
        });
        action.setCallback(this, function(response){ 
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                var newVisitList;
                if(result != null){
                    var isApprovalRequired = result.useApprovalProcess;
                    if(result.visitList != undefined && result.visitList != null && result.visitList != ''){
                        if(isApprovalRequired){
                            if(result.isApproved == true){
                                component.set('v.taskList', result.visitList);
                                component.set('v.completedVisit', result.completedVisit); 
                                component.set('v.pendingVisit', result.pendingVisit);
                                component.set("v.ShowEmptyPage",false);
                                component.set('v.disableVisitButtons', true);
                                component.set("v.ShowStartDay",false);
                                
                                if(result.dvpList != undefined && result.dvpList.length != 0){
                                    component.set("v.ShowStartDay",false);
                                    if(result.dvpList[0].End_Date__c == null){
                                        component.set("v.ShowEndDay",false);
                                        component.set("v.ShowStartDay",true);
                                    }else{
                                        component.set("v.ShowEndDay",true);
                                        component.set("v.ShowStartDay",true);
                                    }
                                    component.set('v.disableVisitButtons', false);
                                    const today = new Date();
                                    var checkDate = new Date(formattedDate);
                                    if(checkDate.setHours(0,0,0,0) != today.setHours(0,0,0,0)){
                                        component.set("v.ShowStartDay",true);
                                        component.set("v.ShowEndDay",true);
                                        component.set('v.disableVisitButtons', true);
                                    }
                                }else{
                                    const today = new Date();
                                    var checkDate = new Date(formattedDate);
                                    if(checkDate.setHours(0,0,0,0) == today.setHours(0,0,0,0)){
                                        component.set("v.ShowStartDay",false);
                                    }else{
                                        component.set("v.ShowStartDay",true);
                                        component.set("v.ShowEndDay",true);
                                        component.set('v.disableVisitButtons', true);
                                    }
                                    component.set("v.ShowEndDay",true);
                                    component.set('v.disableVisitButtons', true);
                                } 
                            }
                            else{
                                component.set('v.taskList', result.visitList);
                                component.set('v.completedVisit', result.completedVisit); 
                                component.set('v.pendingVisit', result.pendingVisit);
                                component.set("v.ShowEmptyPage",false);
                                component.set("v.ShowStartDay",true);
                                component.set("v.ShowEndDay",true)
                                component.set('v.disableVisitButtons', true);
                            } 
                        }else{
                            component.set('v.taskList', result.visitList);
                            component.set('v.completedVisit', result.completedVisit); 
                            component.set('v.pendingVisit', result.pendingVisit);
                            component.set("v.ShowEmptyPage",false);
                            if(result.dvpList != undefined && result.dvpList.length != 0){
                                component.set("v.ShowStartDay",false);
                                if(result.dvpList[0].End_Date__c == null){
                                    component.set("v.ShowEndDay",false);
                                    component.set("v.ShowStartDay",true);
                                }else{
                                    component.set("v.ShowEndDay",true);
                                    component.set("v.ShowStartDay",true);
                                }
                                component.set('v.disableVisitButtons', false);
                                const today = new Date();
                                var checkDate = new Date(formattedDate);
                                if(checkDate.setHours(0,0,0,0) != today.setHours(0,0,0,0)){
                                    component.set("v.ShowStartDay",true);
                                    component.set("v.ShowEndDay",true);
                                    component.set('v.disableVisitButtons', true);
                                }
                            }else{
                                const today = new Date();
                                var checkDate = new Date(formattedDate);
                                if(checkDate.setHours(0,0,0,0) == today.setHours(0,0,0,0)){
                                    component.set("v.ShowStartDay",false);
                                }else{
                                    component.set("v.ShowStartDay",true);
                                    component.set("v.ShowEndDay",true);
                                    component.set('v.disableVisitButtons', true);
                                }
                                component.set("v.ShowEndDay",true);
                                component.set('v.disableVisitButtons', true);
                            }
                        }
                        var objlocation = [];
                        var accountAddressOBj = [];
                        var  location = {Street : '',City:'',State:'',PostalCode : '',Country : ''}
                        for(var i=0;i<result.visitList.length;i++){
                            if(result.visitList[i].Account__c != undefined && result.visitList[i].Account__c != null){
                                var dataccc = result.visitList[i].Account__r;
                            }else if(result.visitList[i].Specifier__c != undefined){
                                var dataccc = result.visitList[i].Specifier__r;
                            }
                                else{
                                    var dataccc = result.visitList[i].Lead__r;
                                }
                            accountAddressOBj.push(dataccc);
                        }
                        component.set("v.AccountAddressList",accountAddressOBj);
                        var dataAddress = component.get("v.AccountAddressList");
                        for(var i=0;i<dataAddress.length;i++){
                            var tempLocat = {};
                            var LocationObj = {};
                            
                            if(dataAddress[i] !=undefined && dataAddress[i].BillingStreet != undefined && dataAddress[i].BillingStreet != null){
                                tempLocat.Street = dataAddress[i].BillingStreet;
                                tempLocat.City  = dataAddress[i].BillingCity;
                                tempLocat.State = dataAddress[i].BillingState;
                                tempLocat.PostalCode = dataAddress[i].BillingPostalCode;
                                tempLocat.Country = dataAddress[i].BillingCountry;
                                LocationObj.location = tempLocat;
                                objlocation.push(LocationObj);
                            }else if(dataAddress[i] == undefined){
                                tempLocat.Street = '';
                                tempLocat.City  = '';
                                tempLocat.State = '';
                                tempLocat.PostalCode = '';
                                tempLocat.Country ='';
                                LocationObj.location = tempLocat;
                                objlocation.push(LocationObj);
                            }
                                else{
                                    tempLocat.Street = dataAddress[i].Street;
                                    tempLocat.City  = dataAddress[i].City;
                                    tempLocat.State = dataAddress[i].StateCode;
                                    tempLocat.PostalCode = dataAddress[i].PostalCode;
                                    tempLocat.Country = dataAddress[i].CountryCode;
                                    LocationObj.location = tempLocat;
                                    objlocation.push(LocationObj);
                                }
                        }
                        component.set("v.AccountMapList",objlocation)
                        this.MapinitMethod(component, event, helper);
                    }
                    else{
                        return;
                    }
                }
                else{
                    component.set('v.taskList', []);
                    component.set('v.completedVisit', []); 
                    component.set('v.pendingVisit', []);
                    component.set("v.ShowStartDay",true);
                    component.set("v.ShowEndDay",true);
                    component.set("v.ShowEmptyPage",true);
                    return;
                }
                if(component.get('v.ShowStartDay') && component.get('v.ShowEndDay')){
                    component.set('v.disableVisitButtons', true);
                }
            }else{
                console.log(JSON.stringify(response.getError()));
                this.showErrorMessage(component, event, helper);
                return;
            } 
        });
        $A.enqueueAction(action);
    },
    
    loadCompletedTasks: function (component, event, helper) {
        debugger;
        var today = new Date();
        var selectedDate = component.get('v.selectedDate');        
        var year = today.getFullYear();
        var month = String(today.getMonth() + 1).padStart(2, '0'); 
        var day = String(today.getDate()).padStart(2, '0');
        
        var formattedDate = year + '-' + month + '-' + day;
        if(selectedDate != null && selectedDate != undefined){
            formattedDate = selectedDate;
        }
        component.set('v.SelectedVisitDateFromTaskComp', formattedDate);
        component.set('v.selectedDate', formattedDate);
        var action = component.get("c.GetCompletedVisitRecords");
        action.setParams({ visitDate: formattedDate });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var responseValue = response.getReturnValue();
                if (responseValue) {
                    var isApprovalRequired = responseValue.useApprovalProcess;
                    component.set("v.completedTaskList", responseValue.completedVisitList);
                    var result = responseValue;
                    if(result.dvpList != undefined && result.dvpList.length != 0){
                        component.set("v.ShowStartDay",false);
                        if(result.dvpList[0].End_Date__c == null){
                            component.set("v.ShowEndDay",false);
                            component.set("v.ShowStartDay",true);
                        }else{
                            component.set("v.ShowEndDay",true);
                            component.set("v.ShowStartDay",true);
                        }
                        component.set('v.disableVisitButtons', false);
                        const today = new Date();
                        var checkDate = new Date(formattedDate);
                        if(checkDate.setHours(0,0,0,0) != today.setHours(0,0,0,0)){
                            component.set("v.ShowStartDay",true);
                            component.set("v.ShowEndDay",true);
                            component.set('v.disableVisitButtons', true);
                        }
                    }
                }
            } else {
                console.error("Error: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    MapinitMethod: function (component, event, helper) {
        debugger;
        component.set('v.mapMarkers',component.get("v.AccountMapList") );
        component.set('v.zoomLevel', 12);
    },
    
    showsuccessMessage : function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'SUCCESS',
            message: 'Your day has been successfully started !',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    showsuccessMessageForUpdateVisit : function (component, event, helper) {
        debugger;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'SUCCESS',
            message: 'Visit date has been successfully updated',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
        component.set('v.ShowAmedVistPop', false);
        var reloadCallback = $A.getCallback(function() {
            var navigateToChildEvent = $A.get("e.force:navigateToComponent");
            navigateToChildEvent.setParams({
                componentDef: "c:DashboardComponent", 
                componentAttributes: {
                    showtabOne:false,
                    showtabTwo:true
                } 
            });
            navigateToChildEvent.fire();
            $A.get('e.force:refreshView').fire(); 
        });
        // Invoke the callback function after a slight delay
        setTimeout(reloadCallback, 1000);
    },
    
    showErrorMessage : function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'ERROR',
            message:'Something went Wrong !',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    StartVisitDayhelper : function (component, lat, long){
        debugger;
        var taskrecords = component.get("v.taskList");
        var action = component.get("c.StartDayVisitForVistitRecord");
        action.setParams({
            startLat: lat,
            startLang: long,
            visitRecList: taskrecords
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var data = response.getReturnValue(); 
                if (data != null) {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'SUCCESS',
                        message: 'Day Started Successfully !',
                        duration: '5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    component.set("v.ShowStartDay",true);
                    component.set("v.ShowEndDay",false);
                    component.set('v.disableVisitButtons', false);
                }
            } else if (response.getState() === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            } else if (response.getState() === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        })
        $A.enqueueAction(action);
    },
    
    handleVisitRecords : function (component, event, helper){
        debugger;
        var action = component.get("c.getTodayVisitRecordsListNew");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                var visitList = [];
                for (var i = 0; i < result.length; i++) {
                    var visit = {
                        id: result[i].Id,
                        name: result[i].Name
                    };
                    visitList.push(visit);
                }
                component.set("v.visitList", visitList);
            }
        });
        $A.enqueueAction(action);
    },
    
    EndVisitDayhelper : function (component, lat, long){
        debugger;
        var action = component.get("c.updateEndDayVisitRecord");
        action.setParams({
            endLat: lat,
            endLong: long
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() !=null){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'SUCCESS',
                        message: 'Day End Successfully !',
                        duration: '5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            } else if(response.getState() === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }else if (response.getState() === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        });       
        $A.enqueueAction(action);
    },
    
    showInfo : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info',
            message: 'This is an information message.',
            duration:' 3000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    
    showSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Record created Successfully',
            duration:' 3000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    showError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:'No Records To Display',
            duration:' 3000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    showWarning : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warning',
            message: 'This is a warning message.',
            duration:' 3000',
            key: 'info_alt',
            type: 'warning',
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    
    showErrorDynamic : function(component, event, helper, errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: errorMessage,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    reloadPage: function(component, event, helper){
        var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        var counter = component.get("v.nextCounter");
        let curr = new Date();
        var date = new Date();
        date.setDate(date.getDate() + (7 * counter));
        console.log(date);
        let week = []
        const dates = [];
        curr = date;
        for (let i = 1; i <= 7; i++) {
            let first = curr.getDate() - curr.getDay() + i;
            let weekDate = new Date(curr.setDate(first)).toISOString().slice(0, 10);
            week.push(weekDate);
            const newDate = new Date(weekDate);
            var dateObj = {day:'', fullDate:'', month:''};
            dateObj.fullDate = newDate.toISOString().slice(0, 10);
            dateObj.day = newDate.toISOString().slice(8,10);
            var MonthName=monthNames[newDate.getMonth()].slice(0,3);
            dateObj.month = MonthName;
            dates.push(dateObj);
        }
        component.set("v.dates", dates);
    },
    
    callMapMethod : function(component, event, helper){
        debugger;
        var selectedVisitDateFromParentComp = component.get("v.SelectedVisitDate");
        var baseURL = $A.get("$Label.c.orgBaseURLforVFPages");
        var baseURL = baseURL + 'apex/MultipleGeolocationVF?id='+selectedVisitDateFromParentComp;
        component.set("v.siteURL",baseURL);
    },
    
    callMapMethodFromController : function(component, dataFromCont, helper){
        debugger;
        var selectedVisitDateFromParentComp = dataFromCont;
        var MultipleGeolocationVFBaseURL = $A.get("$Label.c.MultipleGeolocationVFBaseURL");
        var baseURL = MultipleGeolocationVFBaseURL+selectedVisitDateFromParentComp;
        component.set("v.siteURL",baseURL);
    },
    
    validateFields: function(component, auraId) {
        debugger;
        var customerSuccessValue = component.find(auraId).get('v.value');
        if ($A.util.isEmpty(customerSuccessValue)) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: "Please fill all Mandatory fields.",
                type: "error"
            });
            toastEvent.fire();
            return false;
        } 
        else {
            return true;
        }
    }
    
})