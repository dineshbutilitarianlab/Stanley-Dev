import { LightningElement,api,wire,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import modal from "@salesforce/resourceUrl/customLookupParent";
import { loadStyle } from "lightning/platformResourceLoader";
export default class CustomLookupParent extends LightningElement { 
    @api recordId;
    @api recId ; 
    @api showProductWareHouse ;
    @api showRadioOptions;
    @api showProductWareHouseSearchBox = false;
    @track selectedOption = '';

    //  get options() {
    //     return [
    //         { label: 'B2B', value: 'B2B' },
    //         { label: 'B2C', value: 'B2C' }
    //     ];
    // }

      get options() {
        return [
            { label: 'B2B WareHouse', value: 'B2B' },
            { label: 'MarketPlace WareHouse', value: 'B2C' }
        ];
    }

    connectedCallback() {
    loadStyle(this, modal);
  }
  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  

   
    handleLookupSelection(event){
        debugger;
        if(event.detail.selectedRecord != undefined){
            console.log('Selected Record Value on Parent Component is ' +  
            JSON.stringify(event.detail.selectedRecord));
            //alert(event.detail.selectedRecord.Id + ' '+ event.detail.selectedRecord.Name);
            console.log('NAME--->',event.detail.selectedRecord.Name)
           this.recId =  event.detail.selectedRecord.Id;
           console.log(' this.recId---->', this.recId);
        }
    }
    handleClick(event)
        {
            debugger;
            if(this.recId==null || this.recId==undefined || this.recId==''){
                window.alert('Select a Warehouse');
            }else{
                    console.log('recId--',this.recId);
                    this.showProductWareHouseSearchBox = true;
                   this.showProductWareHouse = false;
                   this.showRadioOptions = true;
            }
            
        }

        handleRadioValue(event){
            debugger;
            this.selectedOption = event.detail.value;

        }
        
        handleRadio(event)
        {
            this.showProductWareHouse = true;
            this.showRadioOptions = false;
            this.showProductWareHouseSearchBox = true;

        }

        modalCloseHandler(){
            this.dispatchEvent(new CloseActionScreenEvent());
            //this.closeModalPopUp=false;
        }

}