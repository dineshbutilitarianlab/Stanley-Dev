import { LightningElement,api,wire,track } from 'lwc'; 
import getAllSObjects from '@salesforce/apex/ObjectFieldTemplateController.getAllSObjects';
import getFieldList from '@salesforce/apex/ObjectFieldTemplateController.getFieldList'; 
import getMatchList from '@salesforce/apex/ObjectFieldTemplateController.getMatchList'; 
import getPickListValue from '@salesforce/apex/ObjectFieldTemplateController.getPickListValue';  
import getEmailTemplates from '@salesforce/apex/ObjectFieldTemplateController.getEmailTemplates'; 
import makeQuery from '@salesforce/apex/ObjectFieldTemplateController.makeQuery';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ObjectFieldTemplate extends LightningElement {


    @track value ;
    @track fieldValue;
    @track fieldType;
    @track matchingValue;
   

     // tempObj = {'RelatedObject' : '', 'FieldName':'','fieldValue' : '','MatchingType' : '','MatchingValue' : '','Sequence' : '','Id' : ''};
    
    connectedCallback() {
        debugger;
        this.getEmailTemplates();
        this.getObjects();
       
    }

 
    
    @track  objectResults = [];//key value
    @track objectsData =[];
    showObj = false;

    getObjects(){
         debugger;
        getAllSObjects().then((result) =>{
            console.log('result-->',result);
                for(var key in result){
                    this.objectResults.push({label: key, value: result[key]});
                    this.objectsData.push(key);
                    this.showObj = true;
                }
                  console.log(' this.objectResults-->', this.objectResults);  
                  console.log('this.objectsData-->', this.objectsData);        
            
        }).catch((error)=>{
              console.log('error-->',error);
        });

    }


   
    handleChange(event) {
        debugger;
     
        let label = event.target.label;
        if(label =='Object'){
          this.value = event.detail.value;

          //fields
          this.mapOfField = [];
          this.fieldType = '';
          this.showFields=false; 

         //matchType
          this.matchTypeList = [];
          this.fieldTypeMap =[];
          this.showMatchType = false;
          this.getFields();
        }
        if(label =='Fields'){
            this.fieldValue = event.detail.value;

        const field = this.fieldTypeMap.find(item => item.label === this.fieldValue);
         // return field ? field.value : null;
         this.fieldType = field.value;

          if( this.fieldType == 'Picklist'){
                this.matchTypeList = [];
                this.matchingValue = '';
                this.getPickListValue();
            }else{
                   this.showMatchPick = false;
                   this.matchTypeList = [];
                       this.matchingValue = '';
            }
           
          this.matchTypeList = [];
          this.showMatchType = false;
          this.getMatchList();
        }

        if(label =='match Type'){
            this.matchTypeValue = event.detail.value;
        }
        if(label =='match value'){
            this.matchingValue = event.detail.value;
        }
        if(label =='Templates'){
            this.templateId = event.detail.value;
        }

      
        if(this.value){
            //call APex and get All field values
          //  this.getFields();
        }
    }
    
    @track mapOfField = [];
    @track fieldTypeMap =[];
     showFields =false;
    getFields(){
         debugger;
        getFieldList({objName:this.value}).then((result) =>{
            if(result){
               console.log('result-->',result);
                
                for(var i=0; i <=result.length;i++){
                   // this.mapOfField.push({label: result[i].api_Name, value: result[i].label});  
                   this.mapOfField.push({value: result[i].api_Name, label: result[i].label}); 
                  
                  
                   if(result[i].fielddataType != undefined){
                      this.fieldTypeMap.push({label: result[i].api_Name, value: result[i].fielddataType});
                   }else if(result[i].fielddataType == undefined){
                       this.fieldTypeMap.push({label: result[i].api_Name, value: 'Text'});
                   }                
                   
                    this.showFields=true;  
                }
                console.log('mapOfField-->',this.mapOfField);
                console.log('this.fieldTypeMap-->',this.fieldTypeMap);
            }    
        }).catch((error)=>{
              console.log('error-->',error);
        });

    }

      matchTypeList = [];
      matchTypeValue;
      showMatchType =false;
     getMatchList(){
         debugger;
        getMatchList({name:this.fieldType}).then((result) =>{
            if(result){
                for(var i=0;i<result.length;i++){
                     this.matchTypeList.push({label: result[i], value: result[i]});
                     this.showMatchType = true;
                }
                console.log('matchTypeList-->',this.matchTypeList);
            }   
        }).catch((error)=>{
              console.log('error-->',error);
        });

    }


 matchPickList = [];
 showMatchPick =false
      getPickListValue(){
         debugger;
        getPickListValue({Object_Api_Name:this.value,field_Api_Name:this.fieldValue}).then((result) =>{
            if(result){
                // for(var i=0;i<result.length;i++){
                //      this.matchPickList.push({label: result[i], value: result[i]});
                //      this.showMatchPick = true;
                // }

                 for(var key in result){
                    this.matchPickList.push({label: key, value: result[key]});
                     this.showMatchPick = true;
                }

                console.log('matchTypeList-->',this.matchTypeList);
            }   
        }).catch((error)=>{
              console.log('error-->',error);
        });

    }

    templateList = [];
    showTemp = false;
     templateId;
    getEmailTemplates(){
         debugger;
        getEmailTemplates().then((result) =>{
            if(result){
                 for(var key in result){
                    this.templateList.push({label: key, value: result[key]});      
                    this.showTemp =true;
                }

                console.log('templateList-->',this.templateList);
            }   
        }).catch((error)=>{
              console.log('error-->',error);
        });

    }

    handleClose(){
        debugger;
      this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleClear(){
        debugger;
        this.value ='';
      //  this.objectResults = [];
        this.fieldValue ='';
        this.mapOfField = [];
        this.fieldType ='';
        this.matchTypeValue = '';
        this.matchTypeList = [];
        this.matchingValue = '';
        this.matchPickList = [];
        this.templateId = [];
       // this.templateList = [];

    }

    handleSubmit(){
        debugger; //

         makeQuery({objectName:this.value,fieldName:this.fieldValue,matchType:this.matchTypeValue, matchValue:this.matchingValue, tempId:this.templateId}).then((result) =>{
            if(result){
            
            }   
        }).catch((error)=>{
              console.log('error-->',error);
        });

    }

}