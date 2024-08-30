({
    helperMethod : function(component, pageNo) {
        debugger;
        var action = component.get('c.getAllDateOfSchdeularSight');
        var pageSizeBeatStatus = component.get("v.BeatStatuspageSize").toString();
        var pageSizeProspects = component.get("v.ProspectspageSize").toString();
        var monthName = component.get('v.monthName');
        var monthYear = component.get('v.monthYear');
        action.setParams({
            "pageSize" : 10,
            "pageNumber" : pageNo,
            "monthName" : monthName,
            "monthYear" : monthYear
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                var data = response.getReturnValue();
                if(data.visitRecList !=undefined && data.visitRecList !=null && data.visitRecList.length >0){
                    if(data.visitRecList.length < component.get("v.BeatStatuspageSize") || data.visitRecList.length == 0){
                        component.set("v.BeatStatusisLastPage", true);
                    } else{
                        component.set("v.BeatStatusisLastPage", false);
                    }
                    component.set("v.BeatStatusdataSize", data.length);
                    component.set("v.visitList",data.visitRecList);
                }else{
                    component.set("v.BeatStatusisLastPage", true);
                }

                if(data.LeadRecList !=null && data.LeadRecList.length >0){
                    if(data.LeadRecList.length < component.get("v.ProspectspageSize") || data.LeadRecList.length == 0){
                        component.set("v.ProspectsisLastPage", true);
                    } else{
                        component.set("v.ProspectsisLastPage", false);
                    }
                    component.set("v.ProspectsdataSize", data.length);
                    component.set("v.LeadList",data.LeadRecList);
                }else{
                    component.set("v.ProspectsisLastPage", true);
                }

                if(data.eventList !=null && data.eventList.length >0){
                    if(data.eventList.length < component.get("v.MeetingpageSize") || data.eventList.length == 0){
                        component.set("v.MeetingisLastPage", true);
                    } else{
                        component.set("v.MeetingisLastPage", false);
                    }
                    component.set("v.MeetingissdataSize", data.length);
                    component.set("v.EventList",data.eventList);
                }else{
                    component.set("v.MeetingisLastPage", true); 
                }

                if(data.emailList !=null && data.emailList.length >0){
                    if(data.emailList.length < component.get("v.EmailspageSize") || data.emailList.length == 0){
                        component.set("v.EmailsLastPage", true);
                    } else{
                        component.set("v.EmailsLastPage", false);
                    }
                    component.set("v.EmailsissdataSize", data.length);
                    component.set("v.EmailList",data.emailList);
                }else{
                    component.set("v.EmailsLastPage", true);
                }
                
                if(data.oppList !=null && data.oppList.length >0){
                    if(data.oppList.length < component.get("v.ProposalspageSize") || data.oppList.length == 0){
                        component.set("v.ProposalsLastPage", true);
                    } else{
                        component.set("v.ProposalsLastPage", false);
                    }
                    component.set("v.EmailsissdataSize", data.length);
                    component.set("v.OppList",data.oppList);
                }else{
                    component.set("v.ProposalsLastPage", true); 
                }

                if(data.oppNegoList !=null && data.oppNegoList.length >0){
                    if(data.oppNegoList.length < component.get("v.NegotiationpageSize") || data.oppNegoList.length == 0){
                        component.set("v.NegotiationLastPage", true);
                    } else{
                        component.set("v.NegotiationLastPage", false);
                    }
                    component.set("v.NegotiationissdataSize", data.length);
                    component.set("v.OppNegoList",data.oppNegoList);
                }else{
                    component.set("v.NegotiationLastPage", true);
                }

                if(data.quoteList !=null && data.quoteList.length >0){
                    if(data.quoteList.length < component.get("v.QuotationpageSize") || data.quoteList.length == 0){
                        component.set("v.QuotationLastPage", true);
                    } else{
                        component.set("v.QuotationLastPage", false);
                    }
                    component.set("v.QuotationissdataSize", data.length);
                    component.set("v.QuotList",data.quoteList);
                }else{
                    component.set("v.QuotationLastPage", true);
                }

                if(data.purOrdList !=null && data.purOrdList.length >0){
                    if(data.purOrdList.length < component.get("v.PurchaseOrderpageSize") || data.purOrdList.length == 0){
                        component.set("v.PurchaseOrderLastPage", true);
                    } else{
                        component.set("v.PurchaseOrderLastPage", false);
                    }
                    component.set("v.PurchaseOrderissdataSize", data.length);
                    component.set("v.PurchaseOrderList",data.purOrdList);
                }else{
                    component.set("v.PurchaseOrderLastPage", true);
                }

                if(data.invoList !=null && data.invoList.length >0){
                    if(data.invoList.length < component.get("v.InvoicespageSize") || data.invoList.length == 0){
                        component.set("v.InvoicesLastPage", true);
                    } else{
                        component.set("v.InvoicesLastPage", false);
                    }
                    component.set("v.InvoicesissdataSize", data.length);
                    component.set("v.InvoiceList",data.invoList);
                }else{
                    component.set("v.InvoicesLastPage", true);
                }

                if(data.caseList !=null && data.caseList.length >0){
                    if(data.caseList.length < component.get("v.TicketspageSize") || data.caseList.length == 0){
                        component.set("v.TicketsLastPage", true);
                    } else{
                        component.set("v.TicketsLastPage", false);
                    }
                    component.set("v.TicketsissdataSize", data.length);
                    component.set("v.TicketList",data.caseList);
                }else{
                    component.set("v.TicketsLastPage", true);
                }

                if(data.feedbackList !=null && data.feedbackList.length >0){
                    if(data.feedbackList.length < component.get("v.FeedbackpageSize") || data.feedbackList.length == 0){
                        component.set("v.FeedbackLastPage", true);
                    } else{
                        component.set("v.FeedbackLastPage", false);
                    }
                    component.set("v.FeedbackissdataSize", data.length);
                    component.set("v.FeedbackList",data.feedbackList);
                }else{
                    component.set("v.FeedbackLastPage", true);
                }
            }
        });
        $A.enqueueAction(action);
    }
})