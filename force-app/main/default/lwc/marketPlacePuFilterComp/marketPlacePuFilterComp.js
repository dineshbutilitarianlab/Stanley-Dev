import { LightningElement, api, track, wire } from 'lwc';
import getMarketPlace from '@salesforce/apex/StockPoHandler.getPickListValuesIntoList';

export default class MarketPlacePuFilterComp extends LightningElement {

    currentFilter = "--None--";
    marketPlaceName = "";
    @track showDate;
    startDateText = null;
    endDateText = null;
    @track searchKey = '';
    @api searchKeyToSend = '';

    @track picklistList;
    @track newoptions = [];
    @track value;
    @track allValues = [];
    @track optionsMaster = [];
    showFilters = true;

    dateChangeHandler(event) {
        debugger;
        if (event.target.name === 'start-date') {
            this.startDateText = event.target.value;
        }
        else {
            this.endDateText = event.target.value;
        }
        this.notifyChildren(false);
    }

    @wire(getMarketPlace)
    getMarketPlace(result) {
        debugger;
        if (result.data) {
            this.picklistList = result.data;
            console.log('picklistList------->', this.picklistList);
            let arr = [];
            for (var i = 0; i < this.picklistList.length; i++) {
                arr.push({ label: this.picklistList[i], value: this.picklistList[i] });
                console.log('arr->', JSON.stringify(arr));
            }
            this.newoptions = arr;
            this.optionsMaster = arr;
            console.log('newoptionsss->', JSON.stringify(this.newoptions));
        }
        else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

    handleChange(event) {
        debugger;
        this.value = event.target.value;
        if (!this.allValues.includes(this.value))
            this.allValues.push(this.value);
        console.log('this.allValues---->', this.allValues);
        this.modifyOptions();
        this.notifyChildren(false);
    }

    handleRemove(event) {
        debugger;
        this.value = '';
        const valueRemoved = event.target.name;
        this.allValues.splice(this.allValues.indexOf(valueRemoved), 1);
        console.log('After Remove Values-->', this.allValues);
        this.modifyOptions();
        if (this.allValues == [] || this.allValues.length == 0) {
            this.notifyChildren(false);
        }
        else {
            this.notifyChildren(true);
        }
    }

    modifyOptions() {
        debugger;
        this.newoptions = this.optionsMaster.filter(elem => {
            if (!this.allValues.includes(elem.value))
                return elem;
            console.log('element---->', elem)
        })
    }

    get filterOptions() {
        return [
            { label: "--None--", value: "--None--" },
            { label: "Last 3 Months", value: "Last 3 Months" },
            { label: "Last 6 Months", value: "Last 6 Months" },
            { label: "Current Year", value: "Current Year" },
            { label: "Last Year", value: "Last Year" },
            { label: "Last 2 Years", value: "Last 2 Years" },
            { label: "Custom", value: "Custom" },

        ];
    }

    handleFilterChange(event) {
        debugger;
        this.currentFilter = event.target.value;
        if (this.currentFilter === "Last 3 Months") {
            this.showDate = false;
            let date = new Date();
            this.startDateText = new Date(date.getFullYear(), date.getMonth() - 3, date.getDate() + 1).toISOString().substring(0, 10);
            this.endDateText = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1).toISOString().substring(0, 10);
        } else if (this.currentFilter === "Last 6 Months") {
            this.showDate = false;
            let date = new Date();
            this.startDateText = new Date(date.getFullYear(), date.getMonth() - 6, date.getDate() + 1).toISOString().substring(0, 10);
            this.endDateText = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1).toISOString().substring(0, 10);
        } else if (this.currentFilter === "Custom") {
            this.showDate = true;
            let curr = new Date(); // get current date
            let first = curr.getDate() - curr.getDay(); // First day is the day of the month - the day of the week
            let last = first + 6; // last day is the first day + 6
            let firstDate = new Date();
            let lastDate = new Date();
            firstDate.setDate(first);
            lastDate.setDate(last);
            this.startDateText = firstDate.toISOString().substring(0, 10);
            this.endDateText = lastDate.toISOString().substring(0, 10);
        } else if (this.currentFilter === "Current Year") {
            this.showDate = false;
            let date = new Date();
            this.startDateText = new Date(date.getFullYear(), 1, -29).toISOString().substring(0, 10);
            this.endDateText = new Date(date.getFullYear(), 12, 1).toISOString().substring(0, 10);
        } else if (this.currentFilter === "Last Year") {
            this.showDate = false;
            let date = new Date();
            this.startDateText = new Date(date.getFullYear() - 1, 1, -29).toISOString().substring(0, 10);
            this.endDateText = new Date(date.getFullYear() - 1, 12, 1).toISOString().substring(0, 10);
            console.log("Start Date: ", this.startDateText);
            console.log("End Date: ", this.endDateText);
        } if (this.currentFilter === "Last 2 Years") {
            this.showDate = false;
            let date = new Date();
            this.startDateText = new Date(date.getFullYear() - 2, 1, -29).toISOString().substring(0, 10);
            this.endDateText = new Date(date.getFullYear() - 1, 12, 1).toISOString().substring(0, 10);

            console.log("Start Date: ", this.startDateText);
            console.log("End Date: ", this.endDateText);
        }
        else if (this.currentFilter === "--None--") {
            this.startDateText = null;
            this.endDateText = null;
        }
        this.notifyChildren(false);

    }

    notifyChildren(showAllProds) {
        debugger;
        if (!this.isTemporary) {
            console.log('startDateText --> ', this.startDateText);
            console.log('endDateText --> ', this.endDateText);
            console.log('marketPlaceName --> ', this.marketPlaceName);
            console.log('showAllProds --> ', this.showAllProds);

            setTimeout(() => this.template.querySelector('c-show-stockpo-sales').filterRecordsWithStartEndMarketplace(this.startDateText, this.endDateText, this.allValues, showAllProds));
        } else {
            debugger;
            console.log('dataWrapper-----', this.dataWrapper);
        }
    }

    // handleSelection(event){
    //     debugger;
    //     var Id = event.detail.selectedId;
    //     this.marketPlaceName = event.detail.name;
    //     console.log('Id--',Id);
    //     this.notifyChildren(false);
    // }

    // handleRemoval(event){
    //     debugger;
    //     console.log("the selected record name is -- " + event.detail.name);
    //     this.marketPlaceName = event.detail.name;   
    //     this.notifyChildren(false);
    // }

    // handleKeyChange( event ) {
    //     debugger;
    //     this.searchKey = event.target.value.toLowerCase();
    //     console.log( 'Search String is ' + this.searchKey );
    //     this.searchKeyToSend = this.searchKey;
    //     this.notifyChildrenWithSearchKey();
    // } 

    // notifyChildrenWithSearchKey() {
    //     debugger;
    //     if(!this.isTemporary) {
    //         console.log('searchKeyToSend --> ',this.searchKeyToSend);
    //         setTimeout(() => this.template.querySelector('c-show-stockpo-sales').filterRecordsWithSearchKey(this.searchKeyToSend));
    //     }else {
    //         debugger;
    //         console.log('dataWrapper-----',this.dataWrapper);
    //     }
    // }

    resetAllFilters() {
        debugger;
        this.startDateText = null;
        this.endDateText = null;
        this.marketPlaceName = '';
        this.searchKey = '';
        this.currentFilter = '';
        this.showDate = false;
        this.allValues = [];
        this.notifyChildren(true);
    }

    handleFilterVisibility(event) {
        debugger;
        this.showFilters = event.detail.showFilter;
        console.log('this.showFilters---->', this.showFilters);
    }

}