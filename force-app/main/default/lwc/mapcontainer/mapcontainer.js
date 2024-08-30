import { LightningElement,api,track } from 'lwc';
import getAccountDetails from '@salesforce/apex/MapcontainerController.getAccountDetails';
import getLeadDetail from '@salesforce/apex/MapcontainerController.getLeadDetail';
import GoogleMapReverseGeocodeCallout from '@salesforce/apex/MapcontainerController.GoogleMapReverseGeocodeCallout';
import baseURL from '@salesforce/label/c.orgBaseURLforVFPages';

export default class Mapcontainer extends LightningElement {

    @api recordId;
    @api leadId;
    @track accData;
    billingStreet = '';
    currentLocation = '';
    dataArray = {
        'accAddress' : '',
        'currentAddress': ''
    }
    vfHost = baseURL + 'apex/GoogleMapIframe';
    origin = baseURL;
    currentAddress = '';

    connectedCallback(){
        debugger;
        setTimeout(() => {
            this.getLocationDetails();
        }, 2000);
    }
   
    getLocationDetails(){
       debugger;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // Get the Latitude and Longitude from Geolocation API
                var latitude = position.coords.latitude;
                var longitude = position.coords.longitude;
                    GoogleMapReverseGeocodeCallout({lat : latitude,lng: longitude})
                    .then(result =>{
                        if(result){
                            this.currentAddress = result;
                            if(this.recordId.includes('001')){
                                this.sendData('Account');
                            }
                            else if(this.recordId.includes('00Q')){
                                this.sendData('Lead');
                            }
                        }
                    })
                    .catch(error =>{
                        console.log("ERROR")
                    })
            });
        }
    }
   
    sendData(sObject){ 
        debugger;
        if(sObject == 'Account'){
            getAccountDetails({ recordId : this.recordId })
            .then(result =>{
                this.accData = result;
                this.billingStreet = result.BillingStreet;
                this.dataArray.accAddress = this.billingStreet;
                this.dataArray.currentAddress = this.currentAddress;
                
                this.template.querySelector('iframe').contentWindow.postMessage(this.dataArray, this.origin);
            })
            .catch(error =>{
                console.log("ERROR")
            })
        }
        else{
            getLeadDetail({ recordId : this.recordId})
            .then(result =>{
                this.accData = result;
                this.billingStreet = result.Street;
                this.dataArray.accAddress = this.billingStreet;
                this.dataArray.currentAddress = this.currentAddress;
                
                this.template.querySelector('iframe').contentWindow.postMessage(this.dataArray, this.origin);
            })
            .catch(error =>{
                console.log("ERROR")
            })
        }
    }
}