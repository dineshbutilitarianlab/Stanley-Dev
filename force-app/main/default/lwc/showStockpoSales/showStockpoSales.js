import { LightningElement, wire, api, track } from 'lwc';
import getProducts from '@salesforce/apex/StockPoHandler.getProducts';
import getFilteredProducts from '@salesforce/apex/StockPoHandler.getFilteredProducts';
import getSalesProjection from '@salesforce/apex/StockPoHandler.getSalesProjection';
import upsertProjectedSKUs from '@salesforce/apex/StockPoHandler.upsertProjectedSKUs';
import modal from "@salesforce/resourceUrl/modal";
import { loadStyle } from "lightning/platformResourceLoader";
import { CloseActionScreenEvent } from 'lightning/actions';
import COLORS from '@salesforce/resourceUrl/colors';

export default class ShowStockpoSales extends LightningElement {

    
    connectedCallback() {
        loadStyle(this, modal);
        this.monthLoop();
    }

    renderedCallback(){ 
        loadStyle(this, COLORS).then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors")
        })
    }

    @api searchKey = '';

    @track pageLength = 6;
    @track startingRecord = 1;
    @track pageSize = 10; 
    @track page = 1;
    @track totalPage = 0;
    @track totalRecountCount = 0;
    @track searchable=[];
    @track items = []; 

    @track data = [];
    @track error;
    // =============== Product Screen ===================
    @track showButtons = true;
    @track ShowProductScreen = false;
    selectedRecords = [];
    selectedCheckboxIds = [];

    // =============== Month Screen ===================
    @track monthScreen = false;
    @track monthsButtons = false;
    @track monNextbutton = true;
    @track MonthYear=[];

    // ============ Show Sales Proj rec Screen ==================
    @track showPOsalesButtons = false;

    //=========== SHOW Projection =======
    @track showPopUp = false;

    //=========== SHOW PO =======
    @track showPO = false;

    addMonths(date, months) {
        date.setMonth(date.getMonth() + months);
        return date;
    }

    monthLoop(){
        let no_of_months=12;
        let array=[];
        //  Add 2 months to the current Date
        for(let i=0;i<no_of_months;i++){
            const result1 = this.addMonths(new Date(), i);
            console.log(result1); 
            var month = result1.toLocaleString('default', { month: 'long' });
            const year = result1.getFullYear(); // returns 95
            array.push({key:month+' '+year,value:month+' '+year});
            console.log(month); 
        }
        console.log(array);
        this.MonthYear=array;
    }
                
    @track selectedValue;
     
    @track recList = [];
    @wire(getProducts)
    getProductsData(result) {
        debugger;
        if (result.data) {
            this.items = result.data;
            let tempArray = [];
            for(let i=0; i< result.data.length; i++){
                let rec = {...result.data[i]};
                rec.check = false;
                tempArray[i] = rec;
            }
              this.recList = tempArray;
              console.log('this.recList--->',  this.recList);

            this.processRecords(tempArray);  // this.recList   tempArray
            this.error = undefined;
            this.ShowProductScreen = true;
            this.showButtons = true;
        } 
        else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

    processRecords(data){
        debugger;
        var item = data;
        this.totalRecountCount = data.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        
        this.searchable = item.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
    }

    get getMainButton(){
        debugger;
        //alert('entered');
        return (this.selectedRecords == '' || this.selectedRecords == undefined);
    }
    
    handleCheckboxSelect(event) {
        debugger;
        const isChecked = event.target.checked;
        const prodId = event.target.dataset.id;

        if (isChecked) {
            if (!this.selectedCheckboxIds.includes(prodId)) {
                this.selectedCheckboxIds.push(prodId);
            }
        } else {
            const index = this.selectedCheckboxIds.indexOf(prodId);
            if (index > -1) {
                this.selectedCheckboxIds.splice(index, 1);
            }
        }

        if(this.selectedCheckboxIds.length > 0){
            this.selectedRecords = this.selectedCheckboxIds;
        }
        else{
            this.selectedRecords = [];
        }
    }
    

    handleAllSelected(event) {
        debugger; 
        this.selectAll = event.target.checked;
        if (this.selectAll) {
            this.selectedCheckboxIds = this.searchable.map(prod => prod.Id);
        } else {
            this.selectedCheckboxIds = [];
        }    
        this.searchable = this.searchable.map(prod => ({
            ...prod,
            check: this.selectAll
        }));

        if(this.selectedCheckboxIds.length > 0){
            this.selectedRecords = this.selectedCheckboxIds;
        }
        else{
            this.selectedRecords = [];
        }
    }

    previousHandler() {
        debugger;
        if (this.page > 1) {
            this.page = this.page - 1; 
            this.displayRecordPerPage(this.page);
        }

        this.searchable = this.searchable.map(prod => ({
            ...prod,
            check: this.selectedCheckboxIds.includes(prod.Id)
        }));
    }

    nextHandler() {
        debugger;
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }

        this.searchable = this.searchable.map(prod => ({
            ...prod,
            check: this.selectedCheckboxIds.includes(prod.Id)
        }));
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.searchable = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }   

    handleKeyChange(event) {
        debugger;

        const searchKey = event.target.value.toLowerCase();
        console.log( 'Search String is ' + searchKey );
        
        if (searchKey) {
            this.searchable = this.items;
            console.log( 'Account Records are ' + JSON.stringify( this.searchable ) );
            if (this.searchable) {
                let recs = [];                
                for ( let rec of this.searchable ) {
                    console.log( 'Rec is ' + JSON.stringify( rec ) );
                    let valuesArray = Object.values( rec );
                    console.log( 'valuesArray is ' + JSON.stringify( valuesArray ) );

                    for ( let val of valuesArray ) {
                        console.log( 'val is ' + val );
                        let strVal = String( val );                     
                        if ( strVal ) {
                            if ( strVal.toLowerCase().includes( searchKey ) ) {
                                recs.push( rec );
                                break;                       
                            }
                        }
                    }               
                }
                console.log( 'Matched Products are ' + JSON.stringify( recs ) );
                this.processRecords(recs);
                if(recs.length > 0){
                    this.showMsg = false;
                }
                else{
                    this.showMsg = true;
                }
            }
            
        }
        else {
            if(this.items.length > 0){
                this.showMsg = false;
            }
            else{
                this.showMsg = true;
            }
            this.processRecords(this.items);
        }       
    } 

    createPO(){
        debugger;
        this.showPO = true;
        this.ShowProductScreen = false;     
        this.showButtons = false; 
        const showHideFilterEvent = new CustomEvent('showfilters', {
            detail:  { 'showFilter' : false }
        });
        this.dispatchEvent(showHideFilterEvent);
    }

    closeQuickAction() {
        debugger;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleCancel() {
        debugger;
        this.closeQuickAction();
        this.showButtons = true;  
        this.ShowProductScreen = true;
        this.monthScreen = false;
        this.monthsButtons = false;
        this.showPOsalesButtons = false;
        this.monNextbutton = true;
        this.selectedRecords = [];
        this.selectedCheckboxIds = [];
        this.selectedValue = '';
        const showHideFilterEvent = new CustomEvent('showfilters', {
            detail:  { 'showFilter' : true }
        });
        this.dispatchEvent(showHideFilterEvent);
    }

    handleSalesProjection() {
        debugger;
        this.showButtons = false;
        this.monthScreen = true;
        this.monthsButtons = true;
        this.ShowProductScreen = false;  

        const showHideFilterEvent = new CustomEvent('showfilters', {
            detail:  { 'showFilter' : false }
        });
        this.dispatchEvent(showHideFilterEvent);
    }

    handlePrevious() {
        this.showButtons = false;
        this.monthScreen = true;
        this.ShowProductScreen = false;
    }

    handleRadioSelected(event) {
        debugger;
        this.monNextbutton = false;
        window.console.log('selected value ===> ' + event.target.value);
        this.selectedValue = event.target.value;
    }

    monthNext() {
        debugger;
        this.ShowProductScreen = false;
        this.monthScreen = false;
        this.showButtons = false;
        this.monthsButtons = false;
        this.showPOsalesButtons = true;
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    closeProjectionModal() {
        this.ShowProductScreen = true;
        this.showPOsalesButtons = false;
        this.showButtons = true;
        this.selectedRecords = [];
        this.selectedCheckboxIds = [];
        this.searchable = this.searchable.map(prod => ({
            ...prod,
            check: false
        }));
        const showHideFilterEvent = new CustomEvent('showfilters', {
            detail:  { 'showFilter' : true }
        });
        this.dispatchEvent(showHideFilterEvent);
    }
    
    closePOScreen(){
        debugger;
        this.ShowProductScreen = true;
        this.showPO = false;
        this.showButtons = true;
        this.searchable = this.searchable.map(prod => ({
            ...prod,
            check: false
        }));
        this.selectedRecords = [];
        this.selectedCheckboxIds = [];
        const showHideFilterEvent = new CustomEvent('showfilters', {
            detail:  { 'showFilter' : true }
        });
        this.dispatchEvent(showHideFilterEvent);
    }
    
    showMsg = false;
    @api
    filterRecordsWithStartEndMarketplace(startDateText, endDateText, marketPlaceList, showAllProds) {
        debugger;
        console.log('startDateText --> ',startDateText);
        console.log('endDateText --> ',endDateText);
        console.log('marketPlaceList --> ',marketPlaceList);
        console.log('showAllProds --> ',showAllProds);

        this.page = 1;

        var tempDataArray = [];
        var temparray = [];

        getFilteredProducts({startDate : startDateText, endDate : endDateText, marketPlaceList, showAllProds}).then((result) => {
            console.log('Result -->',result);
            if(result.length > 0){
                tempDataArray = result.map((x) => ({ ...x }));
                for (let i = 0; i < tempDataArray.length; i++) {
                    (tempDataArray)[i].Projected_Quantity__c = '';
                    temparray.push((tempDataArray)[i]);
                }
                this.processRecords(result);
                this.showMsg = false;
            }
            else{
                this.showMsg = true;
            }
            
        }).catch(error=>{
                console.log("Error",error);
                alert(error.body.message);
        });
    }

    @api
    filterRecordsWithSearchKey(searchKey) {
        debugger;
        console.log('searchKey --> ',searchKey);
        this.handleKeyChange(searchKey);
    }

    handleViewProjections(){
        debugger;
        this.showPopUp = true;
    }

    closeModalPopUp() {
        debugger;
        this.showPopUp = false;
    }



}