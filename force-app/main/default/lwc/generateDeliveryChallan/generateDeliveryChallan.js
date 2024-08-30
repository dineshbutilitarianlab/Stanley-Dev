import { LightningElement,wire,api,track} from 'lwc';
import savePDF from '@salesforce/apex/DeliveryChallanVFController.savePDF'
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import challanLink from '@salesforce/label/c.Opp_International_Link'; 

export default class GenerateProformaInvoicePDF extends LightningElement {

    @api recordId;
    @track urlUsed;
       
    connectedCallback(){
        debugger;
        setTimeout(() => {
            //this.urlUsed = challanLink + this.recordId;
            //this.urlUsed = 'https://trevifurniture--trevisbx--c.sandbox.vf.force.com/apex/StanleyDC?id=' + this.recordId;
             this.urlUsed = 'https://trevifurniture--trevisbx--c.sandbox.vf.force.com/apex/DeliveryChallanVF?id='+this.recordId;
        },300);
    }

    savePDF(){
        debugger;
        savePDF({url:this.urlUsed,id:this.recordId,fileName:"Delivery Challan"}).then(result => {
            console.log("JADSJKHKDHSD",result);
            this.showNotification('Success','Delivery Challan generated successfully','success');
            this.closeAction();
        }).catch(error=>{
            console.log("Error",error);
        });
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
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