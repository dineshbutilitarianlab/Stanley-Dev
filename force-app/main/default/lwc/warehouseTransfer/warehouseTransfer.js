import { LightningElement, api, track } from 'lwc';
import getproductWarehouseRecords from '@salesforce/apex/TransferWareHouseController.getproductWarehouseRecords';
import getMarketPlaceWarehouseRecords from '@salesforce/apex/TransferWareHouseController.getMarketPlaceWarehouseRecords';
import insertWarehouseTransferLog from '@salesforce/apex/TransferWareHouseController.insertWarehouseTransferLog';
import insertMarketPlaceWarehouseTransferLog from '@salesforce/apex/TransferWareHouseController.insertMarketPlaceWarehouseTransferLog';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WarehouseTransfer extends LightningElement {

    @api recordId;
    @track saveDraftValues = [];
    Textval;
    rowid;
    whList = [];

    @api qtyToTransfer;
    @api currentInven;

    @track recList = [];
    @track SaveDisable = true;
    @track showErrorPopUp = true;

    connectedCallback() {
        this.handleSearch();
    }

    @track selectedRecord = [];
    @track warehouseProductList = [];
    @track searchKey;
    @track pageLength = 10;
    @track page = 0;
    @track searchable = [];
    @api selectedwareHouseId;
    @api selectedOption = '';

    handleSearch() {
        debugger;
        if (this.selectedOption == 'B2B') {
            getproductWarehouseRecords({ recid: this.recordId, selectedOption: this.selectedOption })
                .then((result) => {
                    this.recList = [];
                    for (let i = 0; i < result.length; i++) {
                        let rec = { ...result[i] };
                        rec.onSelectEnable = true;
                        rec.qtyToTransfer = '';
                        rec.productName = rec.Product__r.Name;
                        rec.currentInven = rec.Current_Inventory__c;


                        this.recList[i] = rec;
                        //this.warehouseProductList[i]=rec;
                        console.log('this.data[i].url -- ', rec);
                    }
                    for (let i = 0; i < this.recList.length; i++) {
                        this.searchable.push(this.recList[i]);
                    }
                    //   alert('searchable', JSON.stringify(this.searchable));
                })
                .catch((error) => {
                    alert(JSON.stringify(error))
                    this.error = error;
                    console.log('error = >', error)
                });
        }
        else if (this.selectedOption == 'B2C') {

            getMarketPlaceWarehouseRecords({ recid: this.recordId, selectedOption: this.selectedOption })
                .then((result) => {
                    this.recList = [];
                    for (let i = 0; i < result.length; i++) {
                        let rec = { ...result[i] };
                        rec.onSelectEnable = true;
                        rec.productName = rec.Product__r.Name;
                        rec.qtyToTransfer = '';
                        rec.currentInven = rec.Inventory__c;
                        rec.inTransitInven = rec.In_Transit_Inventory__c;
                        rec.virtualBlocked = rec.Virtually_Blocked_Inventory__c;
                        rec.remaningInv = rec.Inventory__c - (rec.In_Transit_Inventory__c + rec.Virtually_Blocked_Inventory__c);
                        this.recList[i] = rec;
                        //this.warehouseProductList[i]=rec;
                        console.log('this.data[i].url -- ', rec);
                    }
                    for (let i = 0; i < this.recList.length; i++) {
                        this.searchable.push(this.recList[i]);
                    }
                })
                .catch((error) => {
                    alert(JSON.stringify(error))
                    this.error = error;
                    console.log('error = >', error)
                });
        }


    }
    getSelectedName(event) {
        debugger;
        const selectedRows = event.detail.selectedRows;
        console.log('selectedRows', selectedRows);
        this.selectedRecord = selectedRows;
    }

    @track pushToApexFromJs = [];

    handleInputChange(event) {
        debugger;

        var currenttypedvalue = event.detail.value;                  //parseInt(event.detail.value);
        var currentRecId = event.target.dataset.id;

        // his.recList check with  id

        for (var i = 0; i < this.recList.length; i++) {
            if (this.recList[i].Id == currentRecId) {

                if ((this.recList[i].currentInven - (this.recList[i].inTransitInven + this.recList[i].virtualBlocked)) < Number(event.target.value)) {
                    this.recList[i].qtyToTransfer = 0;
                    alert('Should Not Be Greater Than Current Inventory');
                }else {
                    // this.recList[i].qtyToTransfer = 0;
                    this.recList[i].qtyToTransfer = Number(event.target.value);
                    if (this.selectedOption == 'B2B') {
                        this.recList[i].Current_Inventory__c = this.recList[i].currentInven;

                        // - Number(event.target.value);
                    }
                    else if (this.selectedOption == 'B2C') {
                        this.recList[i].remaningInv = this.recList[i].currentInven - (this.recList[i].inTransitInven + Number(event.target.value) + this.recList[i].virtualBlocked)
                        this.recList[i].In_Transit_Inventory__c = 0;
                    }
                    this.recList[i].In_Transit_Inventory__c = this.recList[i].In_Transit_Inventory__c != undefined ? this.recList[i].In_Transit_Inventory__c + Number(event.target.value) : Number(event.target.value);
                    this.recList[i].checkedvalue = true;
                    // tempData.push(fieldWrapper); // push only changed modification

                }
            }
        }
        this.searchable = this.recList;
        // RECENTLY COmmented ON 4/23/2024 133 - 181 GC
        // let SelectedRecord = this.recList.find(eachProdRec => eachProdRec.Id === currentRecId);
        // console.log('SelectedRecord-->',SelectedRecord);

        /*   let tempFieldWrapperArray = [...this.recList];
           let tempData = [];
   
           console.log('tempFieldWrapperArray--->', tempFieldWrapperArray);
   
           tempFieldWrapperArray.forEach(fieldWrapper => {
               if (fieldWrapper.Id == currentRecId) {
                   // if (name == 'input1' && currenttypedvalue != NaN) {
                   //     fieldWrapper.qty = currenttypedvalue;
                   //     console.log('fieldWrapper====>', fieldWrapper);
                   // }
   
                   if (Number(event.target.value) > fieldWrapper.currentInven) {
                       fieldWrapper.qtyToTransfer = 0;
                       alert('Should Not Be Greater Than Current Inventory');
                   }
                   else {
                       //  alert('inside');
                       fieldWrapper.qtyToTransfer = Number(event.target.value);
                       if(this.selectedOption =='B2B'){
                           fieldWrapper.Current_Inventory__c = fieldWrapper.currentInven - Number(event.target.value);
                       }
                       else if(this.selectedOption =='B2C'){
                           fieldWrapper.Inventory__c = fieldWrapper.currentInven - Number(event.target.value);
                       }
                       
                       fieldWrapper.In_Transit_Inventory__c = fieldWrapper.In_Transit_Inventory__c != undefined ? fieldWrapper.In_Transit_Inventory__c + Number(event.target.value) : Number(event.target.value);
                       fieldWrapper.checkedvalue = true;
                       tempData.push(fieldWrapper); // push only changed modification
                   }
               }
           });
           //this.recList.push(tempData);
           if (tempData != [] || tempData.length >0) {
               if (this.pushToApexFromJs.length == 0) {
                   this.pushToApexFromJs = tempData; //commented by GC
               //   this.pushToApexFromJs.push(tempData);   //...this.pushToApexFromJs,
               //   this.pushToApexFromJs = [...tempData];
   
               }
               else {
                  // this.pushToApexFromJs.push(tempData); // commented by GC printing same data twice
                //   this.pushToApexFromJs = [...tempData];
                    this.pushToApexFromJs.push(tempData);
               }
           }
           else {
               console.error('currentRecId is undefined.');
           } */
        // 109 - 156 in comment

        // let getSLIs = tempData;
        // var pushToApex = [];

        // //if(this.selectRecord.find(record => record.Id === currentRecId)){
        //     for(var i in tempData){
        //         pushToApex.push({
        //             Id: tempData[i].Id,
        //             Current_Inventory__c:  tempData[i].Current_Inventory__c,
        //             In_Transit_Inventory__c : tempData[i].In_Transit_Inventory__c
        //         });
        //         alert(pushToApex);
        //     }
        // //}
        // //this.selectRecord = pushToApex;

        // this.pushToApexFromJs.push(pushToApex);




        // this.rowid = event.target.dataset.id;
        // for(let i=0; i<this.recList.length; i++){
        //     if(this.rowid == this.recList[i].Id){
        //         if(this.recList[i].Current_Inventory__c!=null  ){
        //             if(Number(event.target.value) > this.recList[i].currentInven){
        //                 this.recList[i].qtyToTransfer = 0;
        //                 alert('Should Not Be Greater Than Current Inventory');
        //             }
        //             else{
        //                 this.recList[i].qtyToTransfer = Number(event.target.value);
        //                 this.recList[i].Current_Inventory__c = this.recList[i].currentInven - Number(event.target.value);
        //                 this.recList[i].In_Transit_Inventory__c = this.recList[i].In_Transit_Inventory__c != undefined ? this.recList[i].In_Transit_Inventory__c + Number(event.target.value) : Number(event.target.value);                        
        //             }
        //         }
        //     }

        //     if(this.selectRecord.find(record => record.Id === this.rowid)){
        //         let record=this.selectRecord.filter(record => record.Id !== this.rowid);
        //         this.selectRecord = this.selectRecord.filter(record => record.Id !== this.rowid);
        //         if((record!=null || record!=undefined) && record.checkedvalue==true){
        //             this.recList[i].checkedvalue=true;
        //             this.selectRecord.push(this.recList[i]);
        //         }
        //         else{
        //             this.selectRecord.push(this.recList[i]);
        //         }
        //     }            
        // }

        console.log('recList--', JSON.stringify(this.recList));
        // console.log('selectRecord--', JSON.stringify(this.selectRecord));
    }

    @track selectRecord = [];
    changeHandler(event) {
        debugger;
        const recId = event.target.dataset.id;
        console.log('RECiD===>', recId);
        if (event.target.checked) {
            for (let i = 0; i < this.recList.length; i++) {
                if (this.recList[i].Id == recId) {
                    this.recList[i].onSelectEnable = false;
                    this.recList[i].checkedvalue = true;
                    if (this.selectRecord.find(record => record.Id === recId)) {
                        //      this.recList[i].checkedvalue = true;
                        console.log('This Record Exist');
                    }
                    else {
                        //       this.recList[i].checkedvalue = true;
                        this.selectRecord.push(this.recList[i])
                    }

                    if (this.selectRecord.length > 0) {
                        this.SaveDisable = false;
                    }
                }
            }
        }
        else {
            for (let i = 0; i < this.recList.length; i++) {
                if (this.recList[i].Id == recId) {
                    this.recList[i].onSelectEnable = true;
                    this.recList[i].checkedvalue = false;
                }
            }
            this.selectRecord = this.selectRecord.filter(record => record.Id !== recId);
            if (this.selectRecord.length > 0) {
                this.SaveDisable = false;
            }
            else {
                this.SaveDisable = true;
            }
        }
        console.log('selectRecord--', JSON.stringify(this.selectRecord));
    }


    ONSave() {
        debugger;
        let booleanValue = false;
        let count = 0;

        for (let i = 0; i < this.recList.length; i++) {
            if (this.recList[i].qtyToTransfer > 0) {
                //booleanValue=true;
                count = count + 1;

            } else {
                booleanValue = false;
            }
        }
        if (this.recList.length == count) {
            booleanValue = true;
        }
        else {
            booleanValue = true;
        }

        // Recently Commented on 4-23-24 288 - 302
        // for (let i = 0; i < this.pushToApexFromJs.length; i++) {
        //     if (this.pushToApexFromJs[i].qtyToTransfer > 0) {
        //         //booleanValue=true;
        //         count = count + 1;

        //     } else {
        //         booleanValue = false;
        //     }
        // }
        // if (this.pushToApexFromJs.length == count) {
        //     booleanValue = true;
        // }
        // else {
        //     booleanValue = true;
        // }

        console.log('recordId--', this.recordId);
        console.log('SelectedWareHouse--', this.selectedwareHouseId);
        if (booleanValue == true) {
            if (this.selectedOption == 'B2B') {
                insertWarehouseTransferLog({ prodList: this.pushToApexFromJs, warehouseMasterId: this.recordId, SelectedWareHouseId: this.selectedwareHouseId })
                    .then((result) => {
                        debugger
                        console.log('result---->', result);
                        if (result === 'success') {
                            this.showToast();
                            this.closeModal();
                            console.log('result==>', result);
                        }
                    })
                    .catch((error) => {
                        console.log('error===>', error);
                        this.closeModal();
                    });
            }
            else if (this.selectedOption == 'B2C') {

                // for(var i=0; i<this.pushToApexFromJs.length;i++){
                //    delete this.pushToApexFromJs[i].onSelectEnable;
                //    delete this.pushToApexFromJs[i].checkedvalue ;
                //      delete this.pushToApexFromJs[i].qtyToTransfer;
                //       delete this.pushToApexFromJs[i].currentInven;
                // }
                let localArray = [];
                for (var i = 0; i < this.recList.length; i++) {
                    //this.recList[i].onSelectEnable == true &&
                    if (this.recList[i].checkedvalue == true) {
                        localArray.push(this.recList[i]);
                    }


                } //prodList: this.pushToApexFromJs

                insertMarketPlaceWarehouseTransferLog({ prodList: localArray, warehouseMasterId: this.recordId, SelectedWareHouseId: this.selectedwareHouseId })
                    .then((result) => {
                        debugger
                        console.log('result---->', result);
                        if (result === 'success') {
                            this.showToast();
                            this.closeModal();
                            console.log('result==>', result);
                        }
                    })
                    .catch((error) => {
                        console.log('error===>', error);
                        this.closeModal();
                    });
            }
        } else {
            window.alert('Error Provide Quantity Transfer');
        }
    }




    @track records = [];
    @track tempArray = this.searchable;
    handleKeyChange(event) {
        debugger;
        this.searchKey = event.target.value;
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            if (this.records) {
                let recs = [];
                for (let rec of this.searchable) {

                    let productName = rec.Product__r.Name ? rec.Product__r.Name.toLowerCase() : '';
                    let sku = rec.Product__r.StockKeepingUnit ? rec.Product__r.StockKeepingUnit.toLowerCase() : '';

                    if (productName.includes(searchKey) || sku.includes(searchKey)) {
                        recs.push(rec);
                    }
                    console.log('Rec is ' + JSON.stringify(rec));
                    /*let valuesArray = Object.values( rec );
                    console.log( 'valuesArray is ' + valuesArray );
                    for ( let val of valuesArray ) {
                        if ( val ) {
                            if ( val.toLowerCase().includes( searchKey ) ) {
                                recs.push( rec );
                                break;
                            }
                        }
                    }*/
                }
                console.log('Recs are ' + JSON.stringify(recs));
                this.searchable = recs;
            }
        } else {
            this.searchable = this.tempArray;
        }

    }


    nextpage() {
        debugger;
        let results = [];
        if (this.page <= (Math.floor(this.recList.length / this.pageLength))) {
            this.page = this.page + 1;
            for (let i = 0; i < this.pageLength; i++) {
                if ((i + (this.page * this.pageLength)) < this.recList.length) {
                    results.push(this.recList[i + (this.page * this.pageLength)]);
                }
            }
            this.searchable = results;
            console.log('searchable--', this.searchable);
        }
        // if(this.page==this.recList.length){
        //     this.disable=true;
        // }
        if (results.length == 0) {
            this.disable = true;
        }
    }

    prevpage() {
        debugger;
        let results = [];
        if (this.page >= 1) {
            this.page = this.page - 1;
            for (let i = 0; i < this.pageLength; i++) {
                if ((i + (this.page * this.pageLength)) < this.recList.length) {
                    results.push(this.recList[i + (this.page * this.pageLength)]);
                }
            }
            this.searchable = results;
            console.log('searchable--', this.searchable);
        }
        if (this.page == this.recList.length) {
            this.disable = true;
        }
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Transfer Product Warehouse',
            message: 'Successfully Transfered',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    closeModal() {
        debugger;
        this.dispatchEvent(new CustomEvent('close'))
    }

    get isSearchableEmpty() {
        debugger;
        console.log('searchable.length =>', this.searchable.length);
        if (this.searchable.length > 0) {
            return true;
        }
        else {
            return false;
        }
    }

    get isB2C() {
        return this.selectedOption === 'B2C';
    }

}