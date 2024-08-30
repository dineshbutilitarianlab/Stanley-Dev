$(document).ready(function () {
    
    let repVisits = [];
    let eventss=[]
    let selectedEventKPIS = [];
    let selectedEvent;
    let selectedObject;
    let selecteLocation;
    let selectedUser;
    let currentAccount;
    let visiteDateToApex;
    let AccountId;
    let LeadId;
    let SpecRecId;
    let addlat;
    let addlong;
    let startTime;
    let endTime;
    let accMap = new Map();
    let routeName;
    let objecTypeName;
    let tagRSM = false;
    var plannedVisitDate;
    var VisitDescription;
    var visitStartTime;
    var visitEndTime;
    
    let configureCalendar = function () {
        debugger;
        $("#calendar").fullCalendar('removeEvents');
        $("#calendar").fullCalendar('addEventSource', repVisits);
    }
    
    debugger;
    const queryString = window.location.search;
    let jobAppId = queryString.split("id=").pop();

    MonthlyVisitViewerController.getcurrentUserRoutesNew(function (result, event) {
        debugger;
        $(result).each(function (i, e) {
            $("#pick-two").after('<option value="' + result[i] + '">' + result[i] + '</option>');
        });
        
    }, { escape: false });
    
    // Method for Getting Sobject Type
    MonthlyVisitViewerController.getSobjectType(function (result, event) {
        debugger;
        console.log('--- result Object :' + result);
        $(result).each(function (i, e) {
            $("#pick-three").after('<option value="' + result[i] + '">' + result[i] + '</option>');
        });
        
    }, { escape: false });
    
    MonthlyVisitViewerController.fetchPageData(jobAppId,function (result, event) {
        debugger;
        let monthName=jobAppId;
        console.log('--- result' + result);
        if(result !=null){
            eventss=[...result];
        }
        else{
          
        }
        if(eventss!=null){
           eventss.forEach(item=>{
        if(item.Lead__c != undefined || item.Lead__c != null){
           repVisits.push({ id: item.Id, start: item.Actual_visit_date__c,title:item.Lead__r.Name, kpiId:item.KPI_Target__c, eventColor:'purple', status:item.Visit_Status__c, Name:item.Name, RouteName:item.Route_Name__c, visitDate:item.Planned_visit_date__c, desc:item.Description__c, kpiName: item.KPI_Target_Name__c, duration:item.Duration__c});
        }
        else if(item.Account__c != undefined || item.Account__c != null){
            repVisits.push({ id: item.Id, start: item.Actual_visit_date__c,title:item.Account__r.Name, kpiId:item.KPI_Target__c, eventColor:'purple', status:item.Visit_Status__c, Name:item.Name, RouteName:item.Route_Name__c, visitDate:item.Planned_visit_date__c, desc:item.Description__c, kpiName: item.KPI_Target_Name__c, duration:item.Duration__c});
        }else if(item.Specifier__c != undefined || item.Specifier__c != null){
            repVisits.push({ id: item.Id, start: item.Actual_visit_date__c,title:item.Specifier__r.Name, kpiId:item.KPI_Target__c, eventColor:'purple', status:item.Visit_Status__c, Name:item.Name, RouteName:item.Route_Name__c, visitDate:item.Planned_visit_date__c, desc:item.Description__c, kpiName: item.KPI_Target_Name__c, duration:item.Duration__c});
        }
        else{ 
            repVisits.push({ id: '', start: '',title:'', kpiId:'', eventColor:'purple', status:'', Name:'', RouteName:'', visitDate:'', desc:'', kpiName: '', duration:''});
        } 
       })
    }
                  
                  
    if (event.status) {
    $('#calendar').fullCalendar({
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
        },
        themeSystem: "standard",
        cache: true,
        defaultDate: monthName,
        navLinks: true,
        editable: true,
        eventLimit: true,
        events: repVisits,
        dragScroll: true,
        droppable: true,
        weekNumbers: true,
        displayEventTime: false,
        
        eventDrop: function (event, delta, revertFunc) {
            debugger;
            if (!confirm("Are you sure about this change? ")) {
                revertFunc();
            } else {
                
                $.each(repVisits, function (i, visit) {
                    if (visit.id === event.id) {
                        repVisits[i].start = event.start._d.getTime();
                        updateSingleVisitDate(repVisits[i]);
                    }
                    console.log(repVisits[i]);
                });
            }
        },
        eventClick: function (event, jsEvent, view) {
            debugger;
            selectedEvent = event;
            getVisitKpis(selectedEvent)
        },
        dayClick: function (date, jsEvent, view) {
            jsEvent.preventDefault();
        },
        drop: function (date ,jsEvent) {
            debugger;
            visiteDateToApex = date;
            console.log('repVisits.length === >'+repVisits.length);                   
            for (var i = 0; i < repVisits.length; i++){
                if(repVisits[i].start !=null){
                    if(repVisits[i].start ==visiteDateToApex && repVisits[i].id==AccountId){
                        
                    }
                    else{
                        
                    }   
                }
                else{
                    handleAddressSelection(date, this);
                    return;//recently added
                }
            }
            if ($('#drop-remove').is(':checked')) {
                $(this).remove();
            }
        },
        eventConstraint: {
            start: moment().format('YYYY-MM-DD'),
            end: '2100-02-01' // hard coded goodness unfortunately
        },
        eventRender: function(event, element){
            if(event.status != undefined && (event.status == 'Pending' || event.status == 'Assigned')){
                $(element).find(".fc-content").attr("style", "background-color: red;");
            }
            if(event.kpiId != undefined && event.kpiId != null){
                $(element).find(".fc-content").attr("style", "background-color: yellow; color:black;");
            }
            if(event.status != undefined && event.status == 'Completed'){
                $(element).find(".fc-content").attr("style", "background-color: green;");
            }
            if(event.status != undefined && event.status == 'In Progress'){
                $(element).find(".fc-content").attr("style", "background-color: black;");
            }
        }
    });
    $('#calendar').fullCalendar('gotoDate', monthName);
    }
    $("#spinner").hide();
    }, { escape: false });

    function updateSingleVisitDate(visit){ 
        let visits = [];
        let v = {Id:visit.Id,Actual_visit_date__c:visit.start};
        visits.push(v);
        MonthlyVisitViewerController.createVisits(visits, function (result, event) {
            console.log('createVisits Result === >' + result);
            debugger;
            if (event.status) {
                console.log('event created successfully');
            }
            $("#spinner").hide();
        }, { escape: false });
    }

    function callVisitAccountCreateRecordMethod() {
        debugger;
        let apexDate = visiteDateToApex.toISOString();
        MonthlyVisitViewerController.createVisitObjectTypev1(AccountId, apexDate, addlat, addlong, startTime,endTime,tagRSM,function (result, event) {
            if(result!=null){
                if(result == 'visit is already scheduled for this slot!!'){
                    alert(result);
                    return;
                }else{
                    let index = repVisits.findIndex(item=>item.id==currentAccount);
                    swal({
                        title: "Good job!",
                        text: 'Visit Created Successfully!',
                        icon: 'success',
                        buttons: false,
                        timer: 1000,
                    });
                    window.location.reload();
                    window.parent.postMessage({name:'Visit Created', payload:'fired'}, '*');    
                }
            }else{
                swal ({
                    title:"Oops" ,  
                    text:"Something went wrong!" ,  
                    icon:"error",
                    buttons: false,
                    timer: 1000,
                })
            }
        }, { escape: false });
    }

    function callVisitLeadCreateRecordMethod() {
        debugger;
        let apexDate = visiteDateToApex.toISOString();
        MonthlyVisitViewerController.createVisitObjectTypev1(LeadId, apexDate, addlat, addlong, startTime,endTime,tagRSM,function (result, event) {
            if(result!=null){
                if(result == 'visit is already scheduled for this slot!!'){
                    return;
                }else{
                    swal({
                        title: "Good job!",
                        text: 'Visit Created Successfully!',
                        icon: 'success',
                        buttons: false,
                        timer: 1000,
                    });
                    window.location.reload();
                    window.parent.postMessage({name:'Visit Created', payload:'fired'}, '*');
                }
            }else{
                swal ({
                    title:"Oops" ,  
                    text:"Something went wrong!" ,  
                    icon:"error",
                    buttons: false,
                    timer: 1000,
                })
            }
        }, { escape: false });
    }

    $("#upsert-visit").click(function () {
        $("#spinner").show();
        debugger;
        var salesRep = $('#user-select').find(":selected").val();
        if (salesRep && repVisits && repVisits.length > 0) {
            let visits = [], visit;
            for (let i = 0; i < repVisits.length; i++) {
                visit = {};
                visit.id = repVisits[i].id;
                visit.Account__c = repVisits[i].accountId;
                visit.Actual_visit_date__c = repVisits[i].start;
                visit.Assigned_User__c = salesRep;
                visits.push(visit);
            }
            MonthlyVisitViewerController.createVisits(visits, function (result, event) {
                debugger;
                if (event.status) {
                    console.log('event created successfully');
                }
                $("#spinner").hide();
            }, { escape: false });
        }
        else {
            $("#spinner").hide();
            alert('Please select visit inorder to create.');
        }
    });

    $("#search-account").click(function () {
        debugger;
        $("#search-pannel").toggle();
    });

    $("#search-dealer").click(function () {
        debugger;
        let userId = $("#user-select option:selected").val();
        if (userId == undefined || userId === "") {
            alert('Please select sales rep in-order to search');
            return;
        }
        var searchString = $('#search-box').val();
        if (searchString == undefined || searchString.length < 3) {
            alert('You need to provide at least 3 characters to search.');
            return;
        }
        $("#spinner").show();
        debugger;
        selecteLocation = $('#user-selectlocation :selected').text();
        MonthlyVisitViewerController.getRepAccounts(selectedUser, selecteLocation, function (accountList, event) {
            debugger;
            if (event.status) {
                if (accountList && accountList.length == 0) {
                    alert('No Records found.');
                } else {
                    $("#event-container").empty();
                    $(accountList).each(function (i, e) {
                        $("#event-container").append(
                            '<div class="fc-event" data-accid="' + accountList[i].Id + '">' + accountList[i].Name + '</div>'
                        );
                    });
                    setEventDraggable();
                }
                
            } else {
                console.log(result);
                alert('Something went wrong');
            }
            $("#spinner").hide();
        });
    });

    $("#clear-dealer").click(function () {
        $('#search-box').val("");
        $("#event-container").empty();
        updateDefaultRepAccounts($("#user-select option:selected").val());
    });

    $("#delete-event").click(function () {
        debugger;
        if (selectedEvent) {
            if (selectedEvent.id) {
                $("#spinner").show();
                MonthlyVisitViewerController.deleteEvent(selectedEvent.id, function (result, event) {
                    if (event.status) {
                        $("#calendar").fullCalendar('removeEvents', selectedEvent._id);
                    } else {
                        alert('Something went wrong, please contact system admin.');
                    }
                    $('#event-modal').hide();
                    $("#spinner").hide();
                });
            } else {
                $("#calendar").fullCalendar('removeEvents', selectedEvent._id);
                $('#event-modal').hide();
            }
        }
    });

    $(".close-modal").click(function () {
        debugger;
        console.log("Lead modal closed");
        $('#address-modallead').hide();
    });

    $(".close-modals").click(function () {
        debugger;
        console.log("Specifier address modal closed");
        $('#specifieraddress-modal').hide();
    });

    $("#user-select").change(function () {
        debugger;
        let userId = $(this).children("option:selected").val();
        routeName = userId;
        if (userId == undefined || userId === "" || userId === "Select...")
            $("#upsert-visit").prop('disabled', true);
        $("#event-container").empty();
        getCalData();
    });

    // Calling Sobject Type
    $("#user-select1").change(function () {
        debugger;
        let sobjectType = $(this).children("option:selected").val();
        objecTypeName = sobjectType;
        if (sobjectType == undefined || sobjectType === "" || sobjectType === "Select...")
            $("#upsert-visit").prop('disabled', true);
        $("#event-container").empty();
        updateDefaultRepAccounts(routeName,sobjectType);
    });

    $("#tagRSM1").click(function () {
        debugger;
        var thisCheck1 = $(this);
        if(thisCheck1.is(':checked')){
            tagRSM = true;
        }
    });

    $("#tagRSM2").click(function () {
        debugger;
        var thisCheck2 = $(this);
        if(thisCheck2.is(':checked')){
            tagRSM = true;
        }
    });

    $("#user-selectRecords").change(function () {
        debugger;
        $("#search-pannel").toggle();
        SelectedRecord = $('#user-selectRecords :selected').text();
    });

    $("#user-selectUser").change(function () {
        debugger;
        getUser();
    });

    function getUser() {
        debugger;
        selectedUser = $('#user-selectUser :selected').text();
        if (selectedUser != null && selecteLocation != null && selectedObject == 'Account') {
            MonthlyVisitViewerController.getRepAccounts(selectedUser, selecteLocation, function (accountList, event) {
                debugger;
                if (event.status) {
                    if (accountList.length == 0) {
                        $("#event-container").empty();
                        alert('No Account Records found.');
                    } else {
                        $("#event-container").empty();
                        $(accountList).each(function (i, e) {
                            $("#event-container").append(
                                '<div class="fc-event" data-accid="' + accountList[i].Id + '">' + accountList[i].Name + '</div>'
                            );
                        });
                        setEventDraggable();
                    }
                } else {
                    console.log(result);
                    alert('Something went wrong');
                }
                $("#spinner").hide();
            });
        } else if (selectedUser != null && selecteLocation != null && selectedObject == 'Lead') {
            debugger;
            MonthlyVisitViewerController.getRepLeads(selectedUser, selecteLocation, function (accountList, event) {
                debugger;
                if (event.status) {
                    if (accountList.length == 0 && selectedUser != 'Select...') {
                        $("#event-container").empty();
                        alert('No Records found !');
                    } else {
                        $("#event-container").empty();
                        $(accountList).each(function (i, e) {
                            $("#event-container").append(
                                '<div class="fc-event" data-accid="' + accountList[i].Id + '">' + accountList[i].Name + '</div>'
                            );
                        });
                        setEventDraggable();
                    }
                    
                } else {
                    console.log(result);
                    alert('Something went wrong');
                }
                $("#spinner").hide();
            });
        }
    }

    $("#user-selectlocation").change(function () {
        debugger;
        selecteLocation = $('#user-selectlocation :selected').text();
        callGetUserData();
    });

    function callGetUserData() {
        debugger;
        MonthlyVisitViewerController.fetchGroupmemeber(selecteLocation, function (result, event) {
            debugger;
            if (event.status) {
                if (result.length > 0) {
                    for (var i = 0; i < result.length; i++) {
                        selectedUserId = result[i].Id;
                    }
                    $("#user-selectUser").empty();
                    var mySelect = $('#user-selectUser');
                    $(result).each(function (i, e) {
                        mySelect.append(
                            '<option value="' + result[i].Id + '">' + result[i].LastName + '</option>' + '<br>'
                        );
                    });
                }
                getUser();
            }
            else {
                alert("Something went wrong !")
            }
            
        }, { escape: false });
    }

    function updateDefaultRepAccounts(userId, sobjectType) {
        debugger;
        $("#event-container").hide();
        $("#search-pannel").hide();
        $("#search-account").hide();
        $("#upsert-visit").prop('disabled', true);
        $("#spinner").show();
        if (userId && userId !== "") {
            $("#event-container").show();
            $("#upsert-visit").prop('disabled', false);
            $("#search-account").show();
            MonthlyVisitViewerController.getUserVisitsUpdated(userId,sobjectType, function (result, event) {
                selectedObject = $('#user-select :selected').text();
                if (event.status) {
                    // For Account
                    if( result.accountList !=undefined){
                        for (let i = 0; i < result.accountList.length; i++) {
                            let calVisit = {};
                            calVisit.id = result.accountList[i].Id;
                            calVisit.title = result.accountList[i].Name;
                            accMap.set(result.accountList[i].Id, result.accountList[i]);
                            repVisits.push(calVisit);
                        }
                        $(result.accountList).each(function (i, e) {
                            $("#event-container").append(
                                '<div class="fc-event" data-accid="' + result.accountList[i].Id + '">' + result.accountList[i].Name + '</div>'
                            );
                        });
                        setEventDraggable();
                    }
                    // For Lead
                    if(result.leadList !=undefined){
                        for (let i = 0; i < result.leadList.length; i++) {
                            let calVisit = {};
                            calVisit.id = result.leadList[i].Id;
                            calVisit.title = result.leadList[i].Name;
                            accMap.set(result.leadList[i].Id, result.leadList[i]);
                            repVisits.push(calVisit);
                        }
                        $(result.leadList).each(function (i, e) {
                            $("#event-container").append(
                                '<div class="fc-event" data-accid="' + result.leadList[i].Id + '">' + result.leadList[i].Name + '</div>'
                            );
                        });
                        setEventDraggable();
                    }
                    // For Specifier
                    if(result.specifierList !=undefined){
                        for (let i = 0; i < result.specifierList.length; i++) {
                            let calVisit = {};
                            calVisit.id = result.specifierList[i].Id;
                            calVisit.title = result.specifierList[i].Name;
                            accMap.set(result.specifierList[i].Id, result.specifierList[i]);
                            repVisits.push(calVisit);
                        }
                        $(result.specifierList).each(function (i, e) {
                            $("#event-container").append(
                                '<div class="fc-event" data-accid="' + result.specifierList[i].Id + '">' + result.specifierList[i].Name + '</div>'
                            );
                        });
                        setEventDraggable();
                    }
                } else {
                    alert('Something went wrong!');
                }
                $("#spinner").hide();
            });
        }
    }

    function getCalData(){
        debugger;
        MonthlyVisitViewerController.fetchPageData(jobAppId,function (result, event) {
            debugger;
            let monthName=jobAppId;
            if(result !=null){
                eventss=[...result];
            }else{
                console.log('No Visit recor Foud Method : fetchPageData ');
            }
            if(result!=null){
                repVisits = [];
                result.forEach(item=>{
                    if(item.Lead__c != undefined || item.Lead__c != null){
                        repVisits.push({ id: item.Id, start: item.Actual_visit_date__c,title:item.Lead__r.Name, kpiId:item.KPI_Target__c, eventColor:'purple', status:item.Visit_Status__c, Name:item.Name, RouteName:item.Route_Name__c, visitDate:item.Planned_visit_date__c, desc:item.Description__c, kpiName: item.KPI_Target_Name__c, duration:item.Duration__c});
                     }
                     else if(item.Account__c != undefined || item.Account__c != null){
                        repVisits.push({ id: item.Id, start: item.Actual_visit_date__c,title:item.Account__r.Name, kpiId:item.KPI_Target__c, eventColor:'purple', status:item.Visit_Status__c, Name:item.Name, RouteName:item.Route_Name__c, visitDate:item.Planned_visit_date__c, desc:item.Description__c, kpiName: item.KPI_Target_Name__c, duration:item.Duration__c});
                     }else if(item.Specifier__c != undefined || item.Specifier__c != null){
                        repVisits.push({ id: item.Id, start: item.Actual_visit_date__c,title:item.Specifier__r.Name, kpiId:item.KPI_Target__c, eventColor:'purple', status:item.Visit_Status__c, Name:item.Name, RouteName:item.Route_Name__c, visitDate:item.Planned_visit_date__c, desc:item.Description__c, kpiName: item.KPI_Target_Name__c, duration:item.Duration__c});
                     }
                     else{ 
                        repVisits.push({ id: '', start: '',title:'', kpiId:'', eventColor:'purple', status:'', Name:'', RouteName:'', visitDate:'', desc:'', kpiName: '', duration:''});
                     } 
                })
             }
        })
    }

    function setEventDraggable() {
        /* initialize the external events
            -----------------------------------------------------------------*/
        $('#external-events .fc-event').each(function () {
            // store data so the calendar knows to render an event upon drop
            $(this).data('event', {
                title: $.trim($(this).text()), // use the element's text as the event title
                stick: true // maintain when user navigates (see docs on the renderEvent method)
            });
            // make the event draggable using jQuery UI
            $(this).draggable({
                zIndex: 999,
                revert: true,      // will cause the event to go back to its
                revertDuration: 0  //  original position after the drag
            });
        });
        /* initialize the calendar
            -----------------------------------------------------------------*/
    }

    function getVisitKpis(selectedEvent) {
        debugger;
        MonthlyVisitViewerController.showKpi(selectedEvent.id, function (result, event) {
            if (result || result.length > 0) {
                $("#kpi-radio").empty();
                $('#taskDetails').empty();
                $('#taskDetails2').empty();
                selectedEventKPIS = [];
                var radioCount = 0; // Counter to keep track of radio buttons
                result.forEach(res => {
                    res.checked = selectedEvent.kpiId == res.Id;
                    var radioElement = $('<input>')
                    .attr({
                    type: 'radio',
                    id: res.Id,
                    value: res.Id,
                    checked: res.checked
                })
                .on('change', onKPIChange)
                .addClass('radio-gap'); // Add a class for styling
                var labelElement = $('<label>')
                .attr('for', res.Id)
                .text(res.KPI_Target_Name__c)
                .addClass('label-gap'); // Add a class for styling                
                // Append radio button and label
                radioElement.appendTo('#kpi-radio');
                labelElement.appendTo('#kpi-radio');
                selectedEventKPIS.push(res);                
                radioCount++;
                $('<br>').appendTo('#kpi-radio');
                // Add a line break after every second radio button
                if (radioCount % 4 === 0) {
                    //$('<br>').appendTo('#kpi-radio');
                }
            });
            var visitDate = new Date(selectedEvent.start._i);
            var formattedDate = visitDate.toLocaleString();
            var formattedDateList = formattedDate.split(',');
            var newFormattedDate = formattedDateList[0];
            if (selectedEvent.kpiId != undefined && selectedEvent.kpiId != null) {
                $('#taskDetails').append("<div><span><b>Task Id :</b> " + " </span>" + selectedEvent.Name + "</div>");
                // $('#taskDetails').append("<div><span><b>Route :</b> " + " </span>" + selectedEvent.RouteName + "</div>");
                $('#taskDetails').append("<div><span><b>Visit Date : </b>" + " </span>" + newFormattedDate + "</div>");
                $('#taskDetails').append("<div><span><b>Visit Status : </b>" + " </span>" + selectedEvent.status + "</div>");
                // $('#taskDetails2').append("<div><span><b>Visit Description : </b>" + " </span>" + selectedEvent.desc + "</div>");
                $('#taskDetails2').append("<div><span><b>Visit Type :</b> " + " </span>" + selectedEvent.kpiName + "</div>");
                $('#taskDetails2').append("<div><span><b>Client Name :</b> " + " </span>" + selectedEvent.title + "</div>");
                $('#taskDetails2').append("<div><span><b>Visit Duration :</b> " + " </span>" + selectedEvent.duration + "</div>");
            } else {
                $('#taskDetHeading').empty();
            }   
            $("#modal-heading-01").text(selectedEvent.title);
            $("#myModal").show();
        }                                       
      });
    }

    let selectedKPIId = '';
    function onKPIChange(event){
        debugger;
        selectedKPIId = '';
        let checkedIndex = selectedEventKPIS.findIndex(item=>item.checked==true);
        let newSelectedKPIIndex = selectedEventKPIS.findIndex(item=>item.Id==event.target.id);
        if(checkedIndex!=-1){
            selectedEventKPIS[checkedIndex].checked = false;
        }
        selectedEventKPIS[newSelectedKPIIndex].checked = true;
        if(checkedIndex!=newSelectedKPIIndex){
            $("#save-kpi-btn").prop("disabled", false);
            selectedKPIId = selectedEventKPIS[newSelectedKPIIndex].Id;
        }
        $('#kpi-radio').empty();
        selectedEventKPIS.forEach(res=>{
            var radioElement = $('<input>')
            .attr({
            type: 'radio',
            id: res.Id,
            value: res.Id,
            checked: res.checked
        })
        .on('change', onKPIChange)
        .appendTo('#kpi-radio');
        
        $('<label>')
        .attr('for', res.Id)
        .text(res.KPI_Target_Name__c)
        .appendTo('#kpi-radio');
        $('</br>').appendTo('#kpi-radio');
    });
   }

    $("#save-kpi-btn").click(function () {
        debugger;
        tagKPIToVisit();
    });

    $(".close-modal").click(function() {
        $("#address-modal").hide();
    });

    $(".close-modal").click(function() {
        $("#address-modallead").hide();
    });

    let selectedDate, selectedInstance;
    let addressMap;
    function handleAddressSelection(date, instance) {
        debugger;
        var checkObjeType = objecTypeName;
        addressMap = new Map();
        selectedDate = date;
        selectedInstance = instance;
        $("#address-parent").empty();
        $("#address-parentlead").empty();
        if (accMap.has($(instance).attr("data-accid"))) {
            
            // for Account
            if(checkObjeType == 'Account'){
                let account = accMap.get($(instance).attr("data-accid"));
                console.log("Account selected-----",account);
                if(account && account.ShippingCity && account.ShippingCountry && account.ShippingState) {
                    addressMap.set('999', {city: account.ShippingCity, country: account.ShippingCountry, lat: account.ShippingLatitude, long: account.ShippingLongitude, pCode: account.ShippingPostalCode, state: account.ShippingState, street: account.ShippingStreet});
                    $("#address-parent").append('<span class="slds-radio"><input type="radio" id="999" value="999" name="address-radio" checked="" /><label class="slds-radio__label" for="999"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ account.ShippingCity+', <b>Country:</b> '+account.ShippingCountry+', <b>Pin-Code: </b>'+ account.ShippingPostalCode+', <b>State:</b> '+account.ShippingState+', <b>Street: </b> '+account.ShippingStreet+'</span></label></span>');
                }
                if(account.Geo_Location__Latitude__s == undefined ||  account.Geo_Location__Longitude__s  == undefined){
                    alert('Geo Location is Mandatory'); 
                    return ;
                }
                if(account && account.BillingCity && account.BillingCountry && account.BillingState) {
                    addressMap.set('777', {city: account.BillingCity, country: account.BillingCountry, lat: account.BillingLatitude, long: account.BillingLongitude, pCode: account.BillingPostalCode, state: account.BillingState, street: account.BillingStreet});
                    $("#address-parent").append('<span class="slds-radio"><input type="radio" id="777" value="777" name="address-radio" checked="" /><label class="slds-radio__label" for="777"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ account.BillingCity+', <b>Country:</b> '+account.BillingCountry+', <b>Pin-Code: </b>'+ account.BillingPostalCode+', <b>State:</b> '+account.BillingState+', <b>Street: </b> '+account.BillingStreet+'</span></label></span>');
                }
                if(account && account.Dispatch_Address__r) {
                    for(let i = 0; i < account.Dispatch_Address__r.length; i++) {
                        addressMap.set(i+"", {city: account.Dispatch_Address__r[i].Address__City__s, country: account.Dispatch_Address__r[i].Address__CountryCode__s, lat: account.Dispatch_Address__r[i].Address__Latitude__s, long: account.Dispatch_Address__r[i].Address__Longitude__s, pCode: account.Dispatch_Address__r[i].Address__PostalCode__s, state: account.Dispatch_Address__r[i].Address__StateCode__s, street: account.Dispatch_Address__r[i].Address__Street__s});
                        $("#address-parent").append('<span class="slds-radio"><input type="radio" id="'+i+'" value="'+i+'" name="address-radio" checked="" /><label class="slds-radio__label" for="'+i+'"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ account.Dispatch_Address__r[i].Address__City__s+', <b>Country:</b> '+account.Dispatch_Address__r[i].Address__CountryCode__s+', <b>Pin-Code: </b>'+ account.Dispatch_Address__r[i].Address__PostalCode__s+', <b>State:</b> '+account.Dispatch_Address__r[i].Address__StateCode__s+', <b>Street: </b> '+account.Dispatch_Address__r[i].Address__Street__s+'</span></label></span>');
                    }
                }
            }

            // For Lead
            if(checkObjeType == 'Lead'){
                let LeadRec = accMap.get($(instance).attr("data-accid"));
                if(LeadRec && LeadRec.City && LeadRec.Country && LeadRec.State) {
                    addressMap.set('999', {city: LeadRec.City, country: LeadRec.Country, lat: LeadRec.Latitude, long: LeadRec.Longitude, pCode: LeadRec.PostalCode, state: LeadRec.State, street: LeadRec.Street});
                    $("#address-parentlead").append('<span class="slds-radio"><input type="radio" id="999" value="999" name="address-radio" checked="" /><label class="slds-radio__label" for="999"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ LeadRec.City+', <b>Country:</b> '+LeadRec.Country+', <b>Pin-Code: </b>'+ LeadRec.PostalCode+', <b>State:</b> '+LeadRec.State+', <b>Street: </b> '+LeadRec.Street+'</span></label></span>');
                }
            }
             
                // for Specifier
            if (checkObjeType == 'Specifier') {
                let SpecRec = accMap.get($(instance).attr("data-accid"));
                if(SpecRec && SpecRec.CityName__c && SpecRec.Country__c && SpecRec.State_Province__c) {
                    addressMap.set('998', {city: SpecRec.CityName__c, country: SpecRec.Country__c, pCode: SpecRec.Zip_Postal_Code__c, state: SpecRec.State_Province__c, street: SpecRec.Street_Address__c});
                    $("#specifieraddress-parent").append('<span class="slds-radio"><input type="radio" id="998" value="998" name="address-radio" checked="" /><label class="slds-radio__label" for="998"><span class="slds-radio_faux"></span><span class="slds-form-element__label">'+'<b>City: </b>'+ SpecRec.CityName__c+', <b>Country:</b> '+SpecRec.Country__c+', <b>Pin-Code: </b>'+ SpecRec.Zip_Postal_Code__c+', <b>State:</b> '+SpecRec.State_Province__c+', <b>Street: </b> '+SpecRec.Street_Address__c+'</span></label></span>');
                }
            }

            else{
                console.log('Lead Address Found !')
            }
        }
        
        if(checkObjeType == 'Account'){
            $("#address-modal").show();
        }
        if(checkObjeType == 'Lead'){
            $("#address-modallead").show();
        }
        if(checkObjeType == 'Specifier'){
            $("#specifieraddress-modal").show();
        }
        
    }

    function tagKPIToVisit(){
        MonthlyVisitViewerController.tagKIPToVisit(selectedEvent.id,selectedKPIId, function (result, event) {
            debugger;
            // toastr.success("Button has been enabled successfully!", "Success", {
            //     closeButton: true,
            //     progressBar: true,
            //     positionClass: "toast-top-right"
            // });
            window.location.reload();
            $("#myModal").hide();
        });
    }

    // for Account VisitRecord
    $("#save-event").click(function() {
        debugger;
        let radioId = $('input[name="address-radio"]:checked').val();
        if(radioId && addressMap && addressMap.has(radioId)) {
            let addressObj = addressMap.get(radioId);
            let obj = { start : selectedDate._i, City__c: addressObj.city, Country__c: addressObj.country, Geo_Location__latitude__s: addressObj.lat, Geo_Location__longitude__s: addressObj.long, Postal_Code__c: addressObj.pCode, State__c: addressObj.state, Street__c: addressObj.street};
            AccountId = $(selectedInstance).attr("data-accid");
            let dateTime = visiteDateToApex.toISOString();
            addlat=addressObj.lat;
            addlong=addressObj.long;
            let apexDate = visiteDateToApex.toISOString();
            var startTimeValue = document.getElementById('time-input-id-47').value;
            var endTimeValue = document.getElementById('time-input-id-48').value;
            startTime=startTimeValue;
            endTime=endTimeValue;
            callVisitAccountCreateRecordMethod(AccountId,apexDate,addlat,addlong,startTime,endTime,tagRSM);
            console.log('LATLANG',obj);
            $("#address-modal").hide();
        }else {
            alert('something went wrong, please try again later');
        }
    });

    // for Lead VisitRecord
    $("#save-eventlead").click(function(){
        debugger;
        let radioId = $('input[name="address-radio"]:checked').val();
        if(radioId && addressMap && addressMap.has(radioId)) {
            let addressObjLead = addressMap.get(radioId);
            let obj = { start : selectedDate._i, City__c: addressObjLead.City, Country__c: addressObjLead.country, Geo_Location__latitude__s: addressObjLead.lat, Geo_Location__longitude__s: addressObjLead.long, Postal_Code__c: addressObjLead.pCode, State__c: addressObjLead.state, Street__c: addressObjLead.street};
            LeadId = $(selectedInstance).attr("data-accid");
            let dateTime = visiteDateToApex.toISOString();
            addlat=addressObjLead.lat;
            addlong=addressObjLead.long;
            let apexDate = visiteDateToApex.toISOString();
            var startTimeValue = document.getElementById('time-input-id-44').value;
            var endTimeValue = document.getElementById('time-input-id-55').value;
            startTime=startTimeValue;
            endTime=endTimeValue;
            callVisitLeadCreateRecordMethod(LeadId,apexDate,addlat,addlong,startTime,endTime,tagRSM);
            console.log('LATLANG == >',obj);
            $("#address-modallead").hide();
        }else{
            alert('something went wrong, please try again later');
        }
    });

    // For Creating Visit Record
    $("#save-visitrecord").click(function () {
        debugger;
         plannedVisitDate = $('#date-input-id-11').val();
         VisitDescription = $('#date-input-id-22').val();
         visitStartTime = $('#date-input-id-33').val();
         visitEndTime = $('#date-input-id-44').val();
         SpecRecId = $(selectedInstance).attr("data-accid");

        let currentDate = new Date();
        let selectedVisitDate = new Date(plannedVisitDate);
        let currentDateWithoutTime = new Date(currentDate.toDateString());

        if (selectedVisitDate < currentDateWithoutTime) {
            swal({
                title: "Oops...",
                text: 'Visit Date cannot be in the Past.',
                icon: 'warning',
                buttons: false,
                timer: 2000
            });
            return false;
        }

        if (selectedVisitDate.toDateString() === currentDate.toDateString()) {
            let currentTime = currentDate.getHours() + ":" + currentDate.getMinutes();
            if (visitStartTime < currentTime) {
                  swal({
                    title: "Oops...",
                    text: 'Start Time cannot be in the past for Today.',
                    icon: 'warning',
                    buttons: false,
                    timer: 2000
                });
                return false;
            }
        }   

        if (visitEndTime <= visitStartTime) {
            swal({
                title: "Oops...",
                text: 'End Time must be greater than Start Time.',
                icon: 'warning',
                buttons: false,
                timer: 2000
            });
            return false;
        }

         $('#specifieraddress-modal').hide();
         callVisitSpecifierCreateMethod(SpecRecId,plannedVisitDate,visitStartTime,visitEndTime,VisitDescription);
    });


    function callVisitSpecifierCreateMethod() {
        debugger;
        $("#spinner").show();
        MonthlyVisitViewerController.createVisitForSpecifier(SpecRecId, plannedVisitDate, visitStartTime, visitEndTime, VisitDescription,function (result, event) {
            if(result!=null){
                $("#spinner").hide();
                    swal({
                        title: "Good job!",
                        text: 'Visit Created Successfully!',
                        icon: 'success',
                        buttons: false,
                        timer: 3000,
                    });
                    setTimeout(function(){
                        window.location.reload();
                        window.parent.postMessage({name:'Visit Created', payload:'fired'}, '*'); 
                    },3000);   
            }else{
                swal ({
                    title:"Oops" ,  
                    text:"Something went wrong!" ,  
                    icon:"error",
                    buttons: false,
                    timer: 1000,
                })
            }
        }, { escape: false });
    }

});




