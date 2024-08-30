import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmailToLogistics from '@salesforce/apex/SendToLogistics.sendEmailToLogistics';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class SendToLogistics extends LightningElement {
     @api recordId;

     connectedCallback() {
       debugger;
       setTimeout(() => {
        this.handle();  
        },300);
     }

     handle(){
        sendEmailToLogistics({ id: this.recordId })
        .then((result) => {
            debugger;
            if(result == 'SUCCESS')
            {
                debugger;
                console.log('result---->',result);  
                this.showSuccessToast();
                this.closeQuickAction();
            }
            else{
                this.showErrorToast() ;
                this.closeQuickAction();
            }
        })
        .catch((error) => {
            console.log('error--->',error);
        });

   }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    showSuccessToast() {
    const evt = new ShowToastEvent({
    title: 'Success',
    message: 'Email Successfully sent to Logistic Team!!',
    variant: 'success',
    mode: 'dismissable'
   });
    this.dispatchEvent(evt);
  }

  showErrorToast() {
    const evt = new ShowToastEvent({
    title: 'Error',
    message: 'Some unexpected error',
    variant: 'error',
    mode: 'dismissable'
 });
  this.dispatchEvent(evt);
 }


}