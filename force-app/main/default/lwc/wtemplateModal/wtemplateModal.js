import { LightningElement } from 'lwc';
import LightningModal from 'lightning/modal';

export default class WtemplateModal extends LightningModal {

    handleOkay() {
        this.close('okay');
    }

    handleTemplateSelection(event){
        debugger;        
        if(event.detail) {
            //this.templateName = event.detail;
            console.log("the selected record template name is"+event.detail);   
        }
    }
}