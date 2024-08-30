import { LightningElement, api, wire } from 'lwc';
import searchLookupData from '@salesforce/apex/TechnicianAssigningController.searchLookupData';
import searchDefaultRecord from '@salesforce/apex/TechnicianAssigningController.searchDefaultRecord';
import taskCreationcontroller from '@salesforce/apex/TechnicianAssigningController.taskCreationcontroller';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
export default class TechnicianAssignCMP extends LightningElement {
    @api recordId; // This will be populated by Salesforce when the component is invoked in context of a record.
    @api label = 'label';
    @api placeholder = 'search...'; 
    @api iconName = 'standard:user';
    @api sObjectApiName = 'User';
    @api defaultRecordId = '';

    // Private properties
    lstResult = []; // To store list of returned records   
    hasRecords = true; 
    searchKey = ''; // To store input field value    
    isSearchLoading = false; // To control loading spinner  
    delayTimeout;
    isValueSelected = false;
    selectedRecord = {}; // To store selected lookup record

    // Initial function to populate default selected lookup record if defaultRecordId is provided
    connectedCallback() {
        // Check if defaultRecordId is provided, and fetch default record
        if (this.defaultRecordId) {
            searchDefaultRecord({ 
                recordId: this.defaultRecordId, 
                sObjectApiName: this.sObjectApiName 
            })
            .then((result) => {
                if (result) {
                    this.selectedRecord = result;
                    this.handelSelectRecordHelper(); // Helper function to show/hide lookup result container on UI
                }
            })
            .catch((error) => {
                console.error('Error fetching default record:', error);
                this.selectedRecord = {};
            });
        }
    }

    // Wire function property to fetch search records based on user input
    @wire(searchLookupData, { searchKey: '$searchKey', sObjectApiName: '$sObjectApiName' })
    searchResult({ data, error }) {
        this.isSearchLoading = false;
        if (data) {
            this.hasRecords = data.length > 0; 
            this.lstResult = JSON.parse(JSON.stringify(data));
        } else if (error) {
            console.error('Error fetching search results:', error);
        }
    }

    // Update searchKey property on input field change  
    handleKeyChange(event) {
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        console.log('Search Key =', searchKey);
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, 300);
    }

    // Method to toggle lookup result section on UI 
    toggleResult(event) {
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch (whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
                break;                    
        }
    }

    // Method to clear selected lookup record  
    handleRemove() {
        this.searchKey = '';    
        this.selectedRecord = {};
        this.lookupUpdateParenthandler(undefined); // Update value on parent component as well
        this.isValueSelected = false; 
    }
    selectedId = '';
    // Update selected record from search result 
    handelSelectedRecord(event) {   
        const objId = event.target.getAttribute('data-recid'); // Get selected record Id 
        this.selectedId  = objId;
        this.selectedRecord = this.lstResult.find(data => data.Id === objId); // Find selected record from list 
        this.lookupUpdateParenthandler(this.selectedRecord); // Update value on parent component
        this.handelSelectRecordHelper(); // Helper function to show/hide lookup result container on UI
    }

    // Handle select record
    handelSelectRecordHelper() {
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        this.isValueSelected = true; 
    }

    // Send selected lookup record to parent component using custom event
    lookupUpdateParenthandler(value) {
        const oEvent = new CustomEvent('lookupupdate', {
            detail: { selectedRecord: value }
        });
        this.dispatchEvent(oEvent);
    }
    scheduledTimeVisit;
    handleVisitDate(event) {
       this.scheduledTimeVisit = event.target.value;
    }
    handleAssignTechnician() {
    if (this.selectedId != null && this.selectedId !== '') {
        taskCreationcontroller({caseId : this.recordId, technicianId: this.selectedId, scheduledTime: this.scheduledTimeVisit})
        .then(result => {
            getRecordNotifyChange([{recordId: this.recordId}]);
            const event = new ShowToastEvent({
                title: 'Case Assigned to Technician Successfully',
                variant: 'success'
            });
            this.dispatchEvent(event);
            refreshApex(this.wiredRecord);
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
            // Extract and trim the error message
            const trimmedMessage = this.extractRelevantErrorMessage(error.body.message);
            const event = new ShowToastEvent({
                title: 'Error Assigning Technician',
                message: trimmedMessage,
                variant: 'error'
            });
            this.dispatchEvent(event);
        });
    } else {
        const event = new ShowToastEvent({
            title: 'Please Select Technician to Assign the Case',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }
}

// Helper method to extract the specific error message
extractRelevantErrorMessage(errorMessage) {
    const match = errorMessage.match(/We can't save this record because the “[^”]+”/);
    return match ? match[0] : errorMessage; // Return the matched part or the full message if no match is found
}

    handleCancel () {
        this.dispatchEvent(new CloseActionScreenEvent());
    } 

}