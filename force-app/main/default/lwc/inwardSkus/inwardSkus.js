import { LightningElement, api, wire, track } from 'lwc';
import getTransferredSKUs from '@salesforce/apex/InwardSKUs_Controller.getTransferredSKUs'; //
import SaveTransferLogDetails from '@salesforce/apex/InwardSKUs_Controller.SaveTransferLogDetails';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import modal from "@salesforce/resourceUrl/modal";
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from "lightning/platformResourceLoader";

export default class InwardSkus extends LightningElement {

    connectedCallback() {
        loadStyle(this, modal);
    }

    @api recordId;

    @track transferredLogData = [];
    @track originalList = [];

    @track totalPagesize;
    @track disablePrev = false;
    @track disableNext = false;
    @track tempListFirstIndex;
    @track tempListLastIndex;
    @track pagenumberforPagination = 1;
    @track searchKey;
    isProject = false;
    transferType = '';
    showSync = false;

    get options() {
        return [
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'No' },
        ];
    }

    @wire(getTransferredSKUs, { WarehousetansferedlogID: '$recordId' })
    wireResponse(data, error) {
        debugger;
        if (data) {
            this.openModal = true;
              console.log('Data---------->',data);
            if (data.data != undefined && data.data) {
                if (data.data.length > 0){
                    this.transferType = data.data[0].Warehouse_Transfer_Log__r.Transfer_Type__c;
                    if( this.transferType == 'Projection' || this.transferType == 'QC Check' ){
                        this.showSync = true;
                    }
                    var tempArray = [];
                    for (let i = 0; i < data.data.length; i++) {
                        let rec = { ... data.data[i] };
                        rec.prodName = rec.Product_Name__c;
                        tempArray[i] = rec;
                    }

                    this.transferredLogData = tempArray;
                    this.originalList = tempArray;
                    this.OnloadListArrangement(this.transferredLogData);
                }
                else{
                    this.showToast('Warning', 'All SKUs have been inwarded!!', 'warning');
                    this.closeModal();
                }
            }
        }
        else if (error) {

        }
    }

    OnloadListArrangement(completeList){
        debugger;
        if (Number.isInteger(completeList.length)) {
            this.totalPagesize = completeList.length;
        }
        else {
            this.totalPagesize = Math.ceil(completeList.length);
        }
        var tempList= [];
        if (completeList.length > 0 && completeList.length < 10) {
            for (var i = 0; i < completeList.length; i++) {
                tempList.push(completeList[i]);
            }
        }
        else if (completeList.length > 10) {
            for (var i = 0; i < 10; i++) {
                tempList.push(completeList[i]);
            }
        }

        this.pageRecordsToDisplay = tempList;
        console.log('this.pageRecordsToDisplay--->',this.pageRecordsToDisplay);
        this.tempListFirstIndex = tempList.length-10;
        this.tempListLastIndex = tempList.length;
        if(this.pagenumberforPagination == 1){
            this.disablePrev = true;
        }
        if(this.pagenumberforPagination == this.totalPagesize){
            this.disableNext = true;
        }
    }

    handleNext(event){
        debugger;
        var tempListForPagination = [];
        if(this.tempListLastIndex < this.transferredLogData.length){
            if((this.transferredLogData.length - this.tempListLastIndex) > 10){
                for(var i = this.tempListLastIndex; i<this.tempListLastIndex+10; i++){
                    tempListForPagination.push(this.transferredLogData[i]);
                }
            }
            else if((this.transferredLogData.length - this.tempListLastIndex) < 10){
                for(var i = this.tempListLastIndex; i<this.tempListLastIndex+(this.transferredLogData.length - this.tempListLastIndex); i++){
                    tempListForPagination.push(this.transferredLogData[i]);
                }
            }
            this.tempListFirstIndex = this.tempListLastIndex;
            this.tempListLastIndex = this.tempListLastIndex +10;
            this.pageRecordsToDisplay = tempListForPagination;
            console.log('this.pageRecordsToDisplay-->',this.pageRecordsToDisplay);
            
            this.pagenumberforPagination = pagenumberforPagination++;
            if (this.pagenumberforPagination == 1) {
                this.disablePrev = true;
            } 
            if (this.pagenumberforPagination == this.totalPagesize) {
                this.disableNext = true;
            }
        }
    }

    handlePrevious(event){
        debugger;
        var tempListForPagination = [];
        for(var i = this.tempListFirstIndex-10; i<this.tempListFirstIndex; i++){
            tempListForPagination.push(this.transferredLogData[i]);
        }
        this.tempListFirstIndex = this.tempListFirstIndex-10;
        this.tempListLastIndex = this.tempListFirstIndex;
        this.pageRecordsToDisplay = tempListForPagination;
         console.log('this.pageRecordsToDisplay-->',this.pageRecordsToDisplay);

        this.pagenumberforPagination = pagenumberforPagination--;
        if (this.pagenumberforPagination == 1) {
            this.disablePrev = true;
        } 
        if (this.pagenumberforPagination == this.totalPagesize) {
            this.disableNext = true;
        }
    }
     
    handleValidation(){
        debugger;
        let j=0;
        for(let i=0;i<this.transferredLogData.length; i++){
            if(this.transferredLogData[i].Pending_Quantity__c < this.transferredLogData[i].Recieved_Quantity__c){
                console.log('Coming in if condiiton');
                alert('entered value should be lessthan Total Quantity');
                console.error('entered value should be lessthan Total Quantity'); 
                break;   
            }
            else{
                console.log('coming in else condition')
                j++;         
            }    
        }
        if(this.transferredLogData.length==j){
            this.handleSaveRecord();
                this.disableBtn = true ;
        }         
    }
                  

    handleSaveRecord(event){
        debugger;
        var transferSKUsForapex = [];
        for(var i=0; i<this.transferredLogData.length; i++){
            delete this.transferredLogData[i].product__r;
            delete this.transferredLogData[i].Warehouse_Transfer_Log__r;
            transferSKUsForapex.push(this.transferredLogData[i]);
        }
          
        debugger;
        SaveTransferLogDetails({ wtLogId: this.recordId, TransferredSKUs:transferSKUsForapex, transferType : this.transferType})
        .then(result => {
            if(result == 'SUCCESS'){
                this.closeModal();
                this.showToast('Updated', 'Transfer SKUs Have been updated Successfully', 'SUCCESS');
                setTimeout(() => {
                    location.reload()
                }, 1500); 
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    updateRecordView() {
        debugger;
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 300); 
     }
    
    handleDismiss(){
        this.closeModal();
    }

    closeModal() {
        setTimeout(() => {
        this.dispatchEvent(new CloseActionScreenEvent());
          }, 300); 
    }
    showToast(Toasttitle, Toastmessage, ToastOutput ) {
        debugger;
        const event = new ShowToastEvent({
            title: Toasttitle,
            message: Toastmessage,
            variant: ToastOutput,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }


    pageRecordsToDisplay = [];
    paginationCallback(event) {
        this.pageRecordsToDisplay = event.detail.recordToDisplay;
         console.log('this.pageRecordsToDisplay-->',this.pageRecordsToDisplay);
    }
     
    @track disableBtn = true;

    handleRecQuanChange(event){
        debugger;
        var name = event.target.name;
        const recordId = event.target.dataset.id;
        var newValue;
        if(name == 'input1'){
            newValue = event.detail.value;
            console.log('newValue---->'+newValue);

        }
        else if(name == 'input2'){
            var remarksValue = event.detail.value;
        }

       else if(name == 'sync'){
            var syncValue = event.detail.value;
        }

        for(let i=0; i<this.transferredLogData.length; i++){
            if(this.transferredLogData[i].Id == recordId){
                if(newValue > this.transferredLogData[i].Pending_Quantity__c || newValue == '' ){
                    newValue ='';
                    alert('Entered Quantity Should Not Greater than Total Quantity or Empty');
                    this.disableBtn = true ;
                }
                else{
                        this.disableBtn = false ;
                }
            }
        } 
            
        const updatedRecords = this.transferredLogData.map(record => {
            if (record.Id === recordId) {
                
                if(newValue != null){
                return { ...record, Recieved_Quantity__c: newValue};
                }

                else if(remarksValue != null) {
                    return { ...record,  Remarks__c:remarksValue };

                }
                else if(syncValue != null) {
                    return { ...record,  sync:syncValue };

                }
            }
            return record;         
        });

        this.transferredLogData = updatedRecords;
        console.log(' this.transferredLogData---->', JSON.stringify(this.transferredLogData));
    }

    handleKeyChange(event){
        debugger;
        var tempSearchList = [];
        var tempCompleteList = this.transferredLogData;
        this.searchKey = event.target.value;
        const searchKey = event.target.value.toLowerCase();  
        console.log( 'Search Key is ' + searchKey );
 
        if ( searchKey ) {  
            this.records = this.transferredLogData;
            if ( this.records ) {
                let recs = [];
                for (let rec of this.records) {
                    if ((rec.prodName).toLowerCase().includes(searchKey)) {
                        recs.push(rec);
                    }
                    console.log('Rec is ' + JSON.stringify(rec));
                }
                console.log( 'Recs are ' + JSON.stringify( recs ) );
                tempSearchList = recs;
                this.OnloadListArrangement(tempSearchList);
            }
        }
        else {
            this.OnloadListArrangement(tempCompleteList);
        }

    }

}