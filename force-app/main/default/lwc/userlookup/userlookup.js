import { LightningElement ,api } from 'lwc';
export default class Userlookup extends LightningElement {
    id;
    @api auraUserId;
    //on type we do search record according below marching where clouse
    matchingInfo = {
        primaryField: { fieldPath: "Name" },
        additionalFields: [{ fieldPath: "Email" }],
    };
    displayInfo = {
        additionalFields: ["Email", "Title"],
    };
    // filter Contacts having email
   
    handleChange(event) {
        debugger;
        console.log(`Selected record: ${event.detail.recordId}`);
      //  this.id = event.detail.recordId;
       const value = event.detail.recordId;

        // const auraEvent = new CustomEvent('sendidtoaura', {
        //         detail: this.id 
        //     });
        //     this.dispatchEvent(auraEvent);
        const auraEvent = new CustomEvent('sendidtoaura', {
            detail: {value}
        });
        this.dispatchEvent(auraEvent);
    }
    
    
}