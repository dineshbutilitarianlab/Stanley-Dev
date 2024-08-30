import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getRecords from "@salesforce/apex/CreateExpenseAndExpenseLineItem.getRecords";
import saveRecords from "@salesforce/apex/CreateExpenseAndExpenseLineItem.saveRecords";
export default class CreateExpenseAndExpenseLineItem extends LightningElement {

    @api recordId;
    @track expenseItems = []; // Track the expense items

    connectedCallback() {
        debugger;
        setTimeout(() => {
            this.getExpenseTemplateItems();
        },100); // 100 milliseconds = 0.1 seconds   
    }


    getExpenseTemplateItems(){
        debugger;
        getRecords({storeId : this.recordId})
            .then(result => {
                console.log('Expense Template Items:', result);
                  this.expenseItems = result;
                
            })
            .catch(error => {
                console.error('Error retrieving Expense Template Items:', error);
            });
    }


     handleChange(event) {
        debugger;
        const field = event.target.name;
        const value = event.target.value;
        const id = event.target.dataset.id; // Correctly retrieve the data-id attribute
        
        // Find the item and update its value
        this.expenseItems = this.expenseItems.map(item => {
            if (item.Id === id) {
                return { ...item, [field]: value };
            }
            return item;
        });
    }

    closeModal(){
        debugger;
        this.dispatchEvent(new CloseActionScreenEvent());

    }

    handleSubmit(){
        debugger;
        saveRecords({expenseItems : this.expenseItems,storeId :this.recordId})
            .then(result => {
                console.log('Expense Template Items:', result);
                this.showNotification('Success','Expense Record Saved Successfully..','success');
                this.closeModal();
            })
            .catch(error => {
                console.error('Error retrieving Expense Template Items:', error);
            });
    }

    
    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

}