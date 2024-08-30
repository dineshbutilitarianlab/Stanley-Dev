({
	doInit : function(component, event, helper) {
        debugger;
        helper.helperMethod(component, 1);
    },
    
    BeatStatushandleNext : function(component, event, helper){
        var pageNumberBeatStatus = component.get("v.BeatStatuspageNumber");
        component.set("v.BeatStatuspageNumber", pageNumberBeatStatus+1);
        helper.helperMethod(component, pageNumberBeatStatus+1);
    },
     ProspecthandleNext : function(component, event, helper){
        var pageNumberProspects = component.get("v.ProspectspageNumber");
        component.set("v.ProspectspageNumber", pageNumberProspects+1);
        helper.helperMethod(component, pageNumberProspects+1);
    },
    MeetinghandleNext : function(component, event, helper){
        var pageNumberMeeting = component.get("v.MeetingpageNumber");
        component.set("v.MeetingpageNumber", pageNumberMeeting+1);
        helper.helperMethod(component, pageNumberMeeting+1);
    },
    EmailshandleNext : function(component, event, helper){
        var pageNumberEmails = component.get("v.EmailspageNumber");
        component.set("v.EmailspageNumber", pageNumberEmails+1);
        helper.helperMethod(component, pageNumberEmails+1);
    },
    ProposalshandleNext : function(component, event, helper){
        var pageNumberProposals = component.get("v.ProposalspageNumber");
        component.set("v.ProposalspageNumber", pageNumberProposals+1);
        helper.helperMethod(component, pageNumberProposals+1);
    },
    NegotiationhandleNext : function(component, event, helper){
        var pageNumberNegotiation = component.get("v.NegotiationpageNumber");
        component.set("v.NegotiationpageNumber", pageNumberNegotiation+1);
        helper.helperMethod(component, pageNumberNegotiation+1);
    },
     QuotationhandleNext : function(component, event, helper){
        var pageNumberQuotation = component.get("v.QuotationpageNumber");
        component.set("v.QuotationpageNumber", pageNumberQuotation+1);
        helper.helperMethod(component, pageNumberQuotation+1);
    },
    PurchaseOrderhandleNext : function(component, event, helper){
        var pageNumberPurchaseOrder = component.get("v.PurchaseOrderpageNumber");
        component.set("v.PurchaseOrderpageNumber", pageNumberPurchaseOrder+1);
        helper.helperMethod(component, pageNumberPurchaseOrder+1);
    },
    InvoiceshandleNext : function(component, event, helper){
        var pageNumberInvoices = component.get("v.InvoicespageNumber");
        component.set("v.InvoicespageNumber", pageNumberInvoices+1);
        helper.helperMethod(component, pageNumberInvoices+1);
    },
    TicketshandleNext : function(component, event, helper){
        var pageNumberTickets = component.get("v.TicketspageNumber");
        component.set("v.TicketspageNumber", pageNumberTickets+1);
        helper.helperMethod(component, pageNumberTickets+1);
    },
    FeedbackhandleNext : function(component, event, helper){
        var pageNumberFeedback = component.get("v.FeedbackpageNumber");
        component.set("v.FeedbackpageNumber", pageNumberFeedback+1);
        helper.helperMethod(component, pageNumberFeedback+1);
    },
    
    
    
    BeatStatushandlePrev : function(component, event, helper){
        var pageNumberBeatStatus = component.get("v.BeatStatuspageNumber");
        component.set("v.BeatStatuspageNumber", pageNumberBeatStatus-1);
          helper.helperMethod(component, pageNumberBeatStatus+1);
    },
    ProspecthandlePrev : function(component, event, helper){
        var pageNumberProspects = component.get("v.ProspectspageNumber");
        component.set("v.ProspectspageNumber", pageNumberProspects-1);
          helper.helperMethod(component, pageNumberProspects-1);
    },
     MeetinghandlePrev : function(component, event, helper){
        var pageNumberMeeting = component.get("v.MeetingpageNumber");
        component.set("v.MeetingpageNumber", pageNumberMeeting-1);
          helper.helperMethod(component, pageNumberMeeting-1);
    },
     EmailshandlePrev : function(component, event, helper){
        var pageNumberEmails = component.get("v.EmailspageNumber");
        component.set("v.EmailspageNumber", pageNumberEmails-1);
          helper.helperMethod(component, pageNumberEmails-1);
    },
    ProposalshandlePrev : function(component, event, helper){
        var pageNumberProposals = component.get("v.ProposalspageNumber");
        component.set("v.ProposalspageNumber", pageNumberProposals-1);
          helper.helperMethod(component, pageNumberProposals-1);
    },
    NegotiationhandlePrev : function(component, event, helper){
        var pageNumberNegotiation = component.get("v.NegotiationpageNumber");
        component.set("v.NegotiationpageNumber", pageNumberNegotiation-1);
          helper.helperMethod(component, pageNumberNegotiation-1);
    },
    QuotationhandlePrev : function(component, event, helper){
        var pageNumberQuotation = component.get("v.QuotationpageNumber");
        component.set("v.QuotationpageNumber", pageNumberQuotation-1);
          helper.helperMethod(component, pageNumberQuotation-1);
    },
    PurchaseOrderhandlePrev : function(component, event, helper){
        var pageNumberPurchaseOrder = component.get("v.PurchaseOrderpageNumber");
        component.set("v.PurchaseOrderpageNumber", pageNumberPurchaseOrder-1);
          helper.helperMethod(component, pageNumberPurchaseOrder-1);
    },
    InvoiceshandlePrev : function(component, event, helper){
        var pageNumberInvoices = component.get("v.InvoicespageNumber");
        component.set("v.InvoicespageNumber", pageNumberInvoices-1);
          helper.helperMethod(component, pageNumberInvoices-1);
    },
    TicketshandlePrev : function(component, event, helper){
        var pageNumberTickets = component.get("v.TicketspageNumber");
        component.set("v.TicketspageNumber", pageNumberTickets-1);
          helper.helperMethod(component, pageNumberTickets-1);
    },
    FeedbackhandlePrev : function(component, event, helper){
        var pageNumberFeedback = component.get("v.FeedbackpageNumber");
        component.set("v.FeedbackpageNumber", pageNumberFeedback-1);
          helper.helperMethod(component, pageNumberFeedback-1);
    },
})