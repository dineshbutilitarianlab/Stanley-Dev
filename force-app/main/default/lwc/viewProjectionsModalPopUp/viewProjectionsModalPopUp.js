import { LightningElement, track, wire, api } from 'lwc';
import getDataForProjection from '@salesforce/apex/StockPoHandler.getDataForProjection';

export default class ViewProjectionsModalPopUp extends LightningElement {

    startDateText = null;
    endDateText = null;
    @api selectedRecords = [];
    recordsToShow = [];
    showRecs = false;
    showMsg = false;

    dateChangeHandler(event){
        debugger;
        if(event.target.name === 'start-date') {
            this.startDateText = event.target.value;
        }
        else {
            this.endDateText = event.target.value;
        }       

        if(this.startDateText != null && this.startDateText != '' && this.endDateText != null && this.endDateText != '') {
            getDataForProjection({startDate : this.startDateText, endDate : this.endDateText, prodIdList : this.selectedRecords}).then((result) => {
                console.log('Result -->',result);
                var resultFromApex = result;
                this.recordsToShow = [];
                for(var key in resultFromApex){
                    this.recordsToShow.push({values:resultFromApex[key], key:key}); //Here we are creating the array to show on UI.
                }

                if(this.recordsToShow.length == 0){
                    this.showMsg = true;
                    this.showRecs = false;
                }
                else{
                    this.showRecs = true;
                    this.showMsg = false;
                }
            }).catch(error=>{
                    console.log("Error",error);
                    alert(error.body.message);
            });
        }
        else{
            this.showRecs = false;
        }
    }

    closeModal() {
        debugger;
        this.dispatchEvent(new CustomEvent('close'));
    }


}