import { LightningElement, api, wire, track } from 'lwc';
import getSalesProjection from '@salesforce/apex/StockPoHandler.getSalesProjection';
import upsertProjectedSKUs from '@salesforce/apex/StockPoHandler.upsertProjectedSKUs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateSalesProjection extends LightningElement {
    @api selectedRecordIds = [];
    @api selectedMonth = '';
    salesprojList = [];
    @track disableSalesbutton = true;

    connectedCallback() {
        debugger;
        setTimeout(() => {
            this.displaySelectedProdTable();  
        },300);
    }

    displaySelectedProdTable() {
        debugger;
        getSalesProjection({ selectedMonth: this.selectedMonth, prodId : this.selectedRecordIds })
            .then(result => {
                this.salesprojList = result;
                console.log('this.salesprojList--->', this.salesprojList);
            })
            .catch(error => {
                console.log('error--->', error);
                this.error = error;
                this.salesprojList = undefined;
            });
    }

    @track listtoenableSubmitbutton = [];
    handleSelectedRecQuanChange(event) {
        debugger;

        var name = event.target.name;
        var currenttypedvalue = event.detail.value;
        var currentRecId = event.target.dataset.id;
        var currentProdId = event.target.dataset.product;

        let tempFieldWrapperArray = [...this.salesprojList];

        tempFieldWrapperArray.forEach(fieldWrapper => {
                if (fieldWrapper.productId == currentProdId) {
                if (name == 'input1' && currenttypedvalue != "") {
                    fieldWrapper.qty = parseInt(event.detail.value);
                    if (!this.listtoenableSubmitbutton.find(eachProdRec => eachProdRec.productId === currentRecId)) {
                        this.listtoenableSubmitbutton.push(fieldWrapper);
                    }
                }
                else {
                    if (this.listtoenableSubmitbutton.find(eachProdRec => eachProdRec.productId === currentRecId)) {
                        this.listtoenableSubmitbutton = this.listtoenableSubmitbutton.filter(record => record.productId !== recId);
                    }
                    fieldWrapper.qty = null;
                }
                console.log('fieldWrapper====>', fieldWrapper);
            }
        });

        this.salesprojList = tempFieldWrapperArray;
        if (currenttypedvalue > 0 && currenttypedvalue != "") {
            this.disableSalesbutton = false;
        }
        else {
            this.disableSalesbutton = true;
        }

        for(let i=0; i < tempFieldWrapperArray.length; i++){
            if(tempFieldWrapperArray[i].qty == "" || tempFieldWrapperArray[i].qty == 0 || tempFieldWrapperArray[i].qty == '0' || tempFieldWrapperArray[i].qty == null){
                this.disableSalesbutton = true;
                return;
            }
        }   
    }

    SubmitAllSalesProjection() {
        debugger;
        upsertProjectedSKUs({actualList : this.salesprojList, selectedMonthYear : this.selectedMonth })
            .then(result => {
                if(result == 'SUCCESS'){
                    this.showToast('Updated', 'Sales Projection has been created Succesfully!!!', 'SUCCESS');
                    this.showButtons = true;  
                    this.ShowProductScreen = true;
                    this.showSelectedRecwithSalesProjRec = false;
                    this.showPOsalesButtons = false;
                    this.closeModal();
                }
            })
            .catch(error => {
                this.showToast('Error', error, 'error');
                //this.closeModal();
            });        
    }

    showToast(toastTitle, toastmessage, toastvariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastmessage,
            variant: toastvariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    closeModal() {
        debugger;
        this.dispatchEvent(new CustomEvent('close'))    
    }

}