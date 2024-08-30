public class CreateExpenseAndExpenseLineItem {


    @AuraEnabled
    public static List<Expense_Template_Line_Item__c> getRecords(String storeId) {
        try {
            System.debug('storeId===>'+storeId);
            Account accountRecord = [select Id,Expense_Template__c from Account where Id =:storeId];
            System.debug('accountRecord===>'+accountRecord);
            String ExpenseTemplateId = accountRecord.Expense_Template__c;
            // Query to retrieve records
            List<Expense_Template_Line_Item__c> items = [SELECT Id, Expense_Line_Item_Type__c, Expense_Template__c,Actual_Budget__c,Total_Budget__c FROM Expense_Template_Line_Item__c Where  Expense_Template__c =: ExpenseTemplateId];
            return items;
        } catch (Exception e) {
            // Handle the exception
            System.debug('Error retrieving ExpenseTemplateItem__c records: ' + e.getMessage());
            throw new AuraHandledException('Unable to retrieve expense template items.');
        }
    }

    @AuraEnabled
    public static String saveRecords(List<Expense_Template_Line_Item__c>expenseItems,String storeId){
        try{

            System.debug('expenseItems===>'+expenseItems);
            Account accountRecord = [select Id,Expense_Template__c,Name from Account where Id =:storeId];
            List<ExpenseT_Expense_Item__c> insertExpenseLineItemRecords = new List<ExpenseT_Expense_Item__c>();
            Decimal actualPrice = 0;
            Decimal TotalPrice = 0;

            ExpenseT_Expense__c expenseRecord =  new ExpenseT_Expense__c();
            expenseRecord.Expense_Amount__c  = actualPrice;
            expenseRecord.Total_Budget__c  = TotalPrice;
            expenseRecord.ExpenseT_Expense_Date__c = System.now().date();
            expenseRecord.Store__c = storeId;
            expenseRecord.Name = 'Expense'+ accountRecord.Name;
            System.debug('expenseRecord===>'+expenseRecord);
            insert expenseRecord;

            // Retrieve the ID of the inserted record
            Id insertedRecordId = expenseRecord.Id;

            // Output the ID to the debug log
            System.debug('Inserted Record ID: ' + insertedRecordId);

            for(Expense_Template_Line_Item__c exI:expenseItems){
                ExpenseT_Expense_Item__c expense = new ExpenseT_Expense_Item__c();
                if(exI.Expense_Line_Item_Type__c != null){
                     expense.Name = exI.Expense_Line_Item_Type__c;
                }
               
                expense.Actual_Budget__c = exI.Actual_Budget__c ;
                expense.Total_Budget__c = exI.Total_Budget__c;
                expense.ExpenseT_Expense_Item_Transaction_Date__c = System.now().date();
                expense.ExpenseT_Expense_Item_Amount__c = exI.Actual_Budget__c ;
                expense.ExpenseT_Expense__c = insertedRecordId;
                expense.ExpenseT_Expense_Item_Category__c = 'Inventory Costs';
            
                actualPrice = actualPrice + exI.Actual_Budget__c;
                TotalPrice = TotalPrice + exI.Total_Budget__c;

                if(exI.Total_Budget__c >= exI.Actual_Budget__c){
                    
                }else{
                   expense.Approval_Status__c = 'Sent';
                }
                insertExpenseLineItemRecords.add(expense);
            }
            System.debug('insertExpenseLineItemRecords===>'+insertExpenseLineItemRecords);
            
            insert insertExpenseLineItemRecords;
            if(actualPrice > TotalPrice){
                expenseRecord.ExpenseT_Expense_Approval_Status__c  = 'Sent';
            }
            expenseRecord.Expense_Amount__c  = actualPrice;
            expenseRecord.Total_Budget__c  = TotalPrice;
            update expenseRecord;

            
            return 'success';

        }catch(Exception e){
            // Handle the exception
            System.debug('Error retrieving ExpenseTemplateItem__c records: ' + e.getMessage());
            System.debug('Error retrieving ExpenseTemplateItem__c records: ' + e.getLineNumber());
            throw new AuraHandledException('Unable to retrieve expense template items.');

        }
        


    }

}