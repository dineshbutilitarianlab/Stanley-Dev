@isTest
public class LeadTriggerHandlerTest {

    @testSetup
    static void setupData() {
        // Creating existing Leads with phone numbers
        List<Lead> existingLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            Lead lead = new Lead();
            lead.FirstName = 'Test' + i;
            lead.LastName = 'User' + i;
            lead.Company = 'Test Company';
            lead.Phone = '123456789' + i;
            existingLeads.add(lead);
        }
        insert existingLeads;
    }

    @isTest
    static void testCheckingDuplicatePhoneLead() {
        Test.startTest();
        
        // New leads with duplicate phone numbers
        List<Lead> newLeads = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            Lead lead = new Lead();
            lead.FirstName = 'Duplicate' + i;
            lead.LastName = 'User' + i;
            lead.Company = 'Test Company';
            lead.Phone = '123456789' + i; // Duplicates with existing leads
            newLeads.add(lead);
        }
        
        try {
            insert newLeads;
            System.assert(false, 'Expected exception was not thrown.');
        } catch (DmlException e) {
            System.debug('Expected exception: ' + e.getMessage());
        }
        
        Test.stopTest();
    }

    @isTest
    static void testCheckDuplicateLeadForMoreThan30Days() {
        Test.startTest();
        
        // Lead older than 30 days
        List<Lead> oldLeads = [SELECT Id, Phone FROM Lead WHERE CreatedDate < LAST_N_DAYS:30 LIMIT 1];
        if (oldLeads.isEmpty()) {
            return; // Test won't run without old leads
        }

        List<Lead> newLeads = new List<Lead>();
        Lead newLead = new Lead();
        newLead.FirstName = 'OldDuplicate';
        newLead.LastName = 'User';
        newLead.Company = 'Test Company';
        newLead.Phone = oldLeads[0].Phone; // Duplicate phone number
        newLeads.add(newLead);

        insert newLeads;

        List<Lead> updatedLeads = [SELECT Id, Parent_lead__c FROM Lead WHERE Id = :newLeads[0].Id];
        
        List<Task> tasks = [SELECT Id, WhoId FROM Task WHERE WhoId = :oldLeads[0].Id];
        Test.stopTest();
    }

    @isTest
    static void testTriggerExecution() {
        Test.startTest();
        
        // Query the custom metadata
        SObject_Trigger_Control__mdt triggerConfig = [SELECT Trigger_Status__c FROM SObject_Trigger_Control__mdt WHERE MasterLabel = 'Lead' LIMIT 1];
        
        // Test data
        List<Lead> leads = new List<Lead>();
        Lead lead1 = new Lead(FirstName='John', LastName='Doe', Company='ABC Corp', Phone='9876543210');
        Lead lead2 = new Lead(FirstName='Jane', LastName='Doe', Company='XYZ Corp', Phone='0123456789');
        leads.add(lead1);
        leads.add(lead2);
        
        // Insert leads
        insert leads;
        
        Test.stopTest();
    }
}