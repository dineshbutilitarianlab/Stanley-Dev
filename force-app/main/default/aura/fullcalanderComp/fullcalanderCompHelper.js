({
    loadDataToCalendar :function(component,data){  
        debugger;
        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        var selectedMonnth = component.get("v.month");
        //var selectedYear = component.get("v.year");
        const formattedDate = `${year}-${selectedMonnth}-${day}`;
        debugger;
        //var monthYear=`${selectedMonnth}-${selectedYear}`;
        
        if(document.getElementById('calendar') == undefined ){
            let elements = document.getElementsByClassName('callyContainer');
            //elements[0].innerHTML = '<div aura:id="calendar"></div>';
            const newelement = document.createElement('div');
            newelement.className = 'callyContainer';
            newelement.innerHTML = '<div id="calendar"></div>';
            //elements[0].parentNode.replaceChild(newelement, elements[0]); Commented 5:34 For Test
        }
        
        
        
        var ele = document.getElementById('calendar');
        $(ele).fullCalendar({
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,basicWeek,basicDay'
            },
            themeSystem: "standard",
            
            defaultDate:formattedDate,
            editable: true,
            eventLimit: true,
            dragScroll: true,
            droppable: true,
            events: data.size>0 ? data :null,
            drop: function(info) {
                debugger;
                var draggedEvent = JSON.parse(info.draggedEl.getAttribute('data-event'));
                var date = info.date;  
                var newEvent = {
                    id: draggedEvent.id,
                    title: draggedEvent.title,
                    start: date
                };
                calendar.addEvent(newEvent);
                
            },
            eventDrop: function (event, delta, revertFunc) {
                debugger;
            }
        });
        $(ele).fullCalendar('gotoDate', formattedDate);
        
        this.setEventDraggable(component);
    },
    
    tranformToFullCalendarFormat : function(component,events) {
        debugger;
        if(events ==null){
            events=[...eventsDummy];
        }
        var eventArr = [];
        for(var i = 0;i < events.length;i++){
            var eventName = events[i].Account__r ? events[i].Account__r.Name : (events[i].Lead__r ? events[i].Lead__r.Name :events[i].KPI_Target_Name__c);
            eventArr.push({
                'id': events[i].Id,
                'start': events[i].Actual_visit_date__c,
                'end': events[i].Actual_visit_date__c,
                'title': eventName,
            });
        }
        return eventArr;
    },
    
    
    fetchEvents : function(component,event) {
       
        debugger
         //component.set("v.month",month);
        // component.set("v.year",year);
        var eventsDummy = [
            {
                'Id': 'a220k000000VOKnAAO',
                'Account__r': { 'Name': 'Axplorify Travels Pvt. Ltd.' },
                'Actual_visit_date__c': '2023-08-15',
                'KPI_Target_Name__c': 'Existing Client Health Check',
                // ... other properties
            },
            {
                'Id': 'a220k000000VOIrAAO',
                'Lead__r': { 'Name': 'Rahul Kumar' },
                'Actual_visit_date__c': '2023-08-11',
                'KPI_Target_Name__c': 'Existing Client Health Check',
                // ... other properties
            },
            {
                'Id': 'a220k000000VOJ1AAO',
                'Lead__r': { 'Name': 'Chandan Kumar' },
                'Actual_visit_date__c': '2023-08-10',
                'KPI_Target_Name__c': 'New Client Onboarding',
                // ... other properties
            },
            // ... add more dummy data as needed
        ];
            //var Month = component.get("v.month");
            //var Year = component.get("v.year"); 
            //Set the handler attributes based on event data 
            if(month!=null && year!=null){
            var action = component.get("c.BeetplannerDatareturn");
            action.setParams({ 
            month : month,
            year:year
            });
            var self = this;
            var wrappersw;
            var weeklist=[];
        var visits=[];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                wrappersw=response.getReturnValue();
                console.log(JSON.stringify(wrappersw));
                weeklist=wrappersw.MBPlist.Weekly_Beat_Plans__r;
                visits=wrappersw.visitRecList;
                console.log('list size',visits.size>0);
                //if(visits.size>0){
                   var eventArr = self.tranformToFullCalendarFormat(component,visits); 
                    // component.set("v.events",eventArr);
                    self.loadDataToCalendar(component,eventArr);
                //}
                                  
                
               
                component.set("v.Weeklybp",weeklist);
                
            }
        });
        
        $A.enqueueAction(action); 
    }
    
}, 
 
 eventClick: function(info) {
    var clickedEvent = info.event;
    var start = clickedEvent.start;
    
    // Open a modal
    var modal = component.find('eventModal');
    var modalComponent = modal || component;
    modalComponent.set('v.startDate', start);
    modalComponent.set('v.isModalOpen', true);
},
    setupDragAndDrop: function(component, event, helper) {
        var draggableEvent = component.find('draggableEvent').getElement();
        var calendarEl = component.find('calendar').getElement();
        
        draggableEvent.addEventListener('dragstart', function(e) {
            e.dataTransfer.setData('text/plain', ''); // Required for dragging
        });
        
        calendarEl.addEventListener('dragover', function(e) {
            e.preventDefault();
        });
        
        calendarEl.addEventListener('drop', function(e) {
            e.preventDefault();
            
            // Get the dropped coordinates on the calendar
            var x = e.clientX - calendarEl.getBoundingClientRect().left;
            var y = e.clientY - calendarEl.getBoundingClientRect().top;
            
            // Convert coordinates to a FullCalendar date
            var date = calendar.getDateFromEl(x, y);
            
            // Create a new event at the dropped date and time
            var eventData = {
                title: 'New Event',
                start: date,
                allDay: false
            };
            
            // Add the new event to the FullCalendar
            calendar.addEvent(eventData);
        });
    },
        
        setEventDraggable: function(component) {
            debugger;
            console.log('Dragging is getting called');
            /* initialize the external events
         
        -----------------------------------------------------------------*/
       
        /* initialize the calendar
        -----------------------------------------------------------------*/
    },
        setupDragAndDrop: function(component, event, helper) {
            debugger;
            var draggableEvent = component.find('draggableEvent').getElement();
            var calendarEl = component.find('calendar').getElement();
            
            draggableEvent.addEventListener('dragstart', function(e) {
                e.dataTransfer.setData('text/plain', ''); // Required for dragging
            });
            
            calendarEl.addEventListener('dragover', function(e) {
                e.preventDefault();
            });
            
            calendarEl.addEventListener('drop', function(e) {
                e.preventDefault();
                
                // Get the dropped coordinates on the calendar
                var x = e.clientX - calendarEl.getBoundingClientRect().left;
                var y = e.clientY - calendarEl.getBoundingClientRect().top;
                
                // Convert coordinates to a FullCalendar date
                var date = calendar.getDateFromEl(x, y);
                
                // Create a new event at the dropped date and time
                var eventData = {
                    title: 'New Event',
                    start: date,
                    allDay: false
                };
                
                // Add the new event to the FullCalendar
                calendar.addEvent(eventData);
            });
        },
            
            
})