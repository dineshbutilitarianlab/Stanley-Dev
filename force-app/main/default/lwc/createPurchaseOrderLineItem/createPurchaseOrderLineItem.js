import { LightningElement,api,wire,track } from 'lwc';
import getProductsForPOLI from '@salesforce/apex/StockPoHandler.getProductsForPOLI';
import createPoLineItem from '@salesforce/apex/StockPoHandler.createPoLineItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CreatePurchaseOrderLineItem extends LightningElement {

    @api selectedRecordswithoutQuantiy =[] ;
    @api selectedRecords = [];
    @api selectedValue = [];
    @api qty;
    @track listtoenableSubmitbutton = [];
    @track  pushToApexFromJs=[];
    @track enableBtn = true;
   connectedCallback() {
    debugger;
     setTimeout(() => {
        this.displaySelectedProdTable();  
        },300);
    }

    displaySelectedProdTable() {
        debugger;
        getProductsForPOLI({ prodIdList: this.selectedRecords})
            .then(result => {
                console.log('result -- > ', result);
                if(result.length>0){
                    this.selectedRecordswithoutQuantiy = result;
                    console.log(this.selectedRecordswithoutQuantiy);
                }
            })
            .catch(error => {
                console.log('error--->', error);
                this.showWarningToast('Error', error.body.message, 'error');
                this.closeModal();
            });
    }

    handleSubmit(){
        debugger;
        this.handleLoad();
    }
  
    handleSelectedRecQuanChange(event) {
        debugger;
        var name = event.target.name;
        var currenttypedvalue =  event.detail.value;                  //parseInt(event.detail.value);
        var currentRecId = event.target.dataset.id;

        let tempFieldWrapperArray = [...this.selectedRecordswithoutQuantiy];
        console.log('tempFieldWrapperArray--->',tempFieldWrapperArray);
        let SelectedRecord = this.selectedRecordswithoutQuantiy.find(eachProdRec => eachProdRec.productId === currentRecId);

        tempFieldWrapperArray.forEach(fieldWrapper => {
            if (fieldWrapper.productId == currentRecId) {
                if (name == 'input1' && currenttypedvalue != NaN) {
                    fieldWrapper.qty = currenttypedvalue;
                    console.log('fieldWrapper====>', fieldWrapper);
                }
            }
        });
        this.selectedRecordswithoutQuantiy = tempFieldWrapperArray;

        let getSLIs = this.selectedRecordswithoutQuantiy ;
        var pushToApex = [];

        for(var i in getSLIs){
            pushToApex.push({
                productId: getSLIs[i].productId,
                productName:  getSLIs[i].productName,
                productSKU : getSLIs[i].productSKU,
                qty:  getSLIs[i].qty,
                productType : getSLIs[i].productType,
                pendingPOQty: getSLIs[i].pendingPOQty,
                currentInventory: getSLIs[i].currentInventory,
                inTransitInventory: getSLIs[i].inTransitInventory,
                virtuallyBlockedInventory: getSLIs[i].virtuallyBlockedInventory,
                projectedQty: getSLIs[i].projectedQty
            });
        }
        this.pushToApexFromJs = pushToApex;

        if(currenttypedvalue != "" && currenttypedvalue > 0 ){
            this.enableBtn = false;
        }
        else{
           this.enableBtn = true ;
        }

        for(let i=0; i < pushToApex.length; i++){
            if(pushToApex[i].qty == "" || pushToApex[i].qty == 0 || pushToApex[i].qty == '0' || pushToApex[i].qty == null){
                this.enableBtn = true;
                return;
            }
        }        
    }

    handleLoad() {
        debugger;
        console.log('this.pushToApexFromJs--',JSON.stringify(this.pushToApexFromJs));
        createPoLineItem({ prods: this.pushToApexFromJs})
            .then(result => {
                console.log('result -- > ', result);
                this.showWarningToast('Success', 'Purchase Order created succesfully!!!', 'SUCCESS');
                this.closeModal();
            })
            .catch(error => {
                console.log('error--->', error);
                this.showWarningToast('Error', error.body.message, 'error');
                this.closeModal();
            });
    }

    closeModal() {
        debugger;
        this.dispatchEvent(new CustomEvent('close'))    
    }

    showWarningToast(toastTitle, toastmessage, toastvariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastmessage,
            variant: toastvariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

}