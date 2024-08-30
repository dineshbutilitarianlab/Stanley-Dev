import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import getMessagesList from '@salesforce/apex/WhatsappMessangerController.getContactWhatsappHistory';
import { refreshApex } from '@salesforce/apex';
import sendMessageTemplate from '@salesforce/apex/WhatsappMessangerController.sendMessageTemplate';
import sendTextMessage from '@salesforce/apex/WhatsappMessangerController.sendMessageText';
import MOBILE_PHONE from '@salesforce/schema/Contact.MobilePhone';
import WTemplateModal from 'c/wtemplateModal';
import newMessageSoundUrl from '@salesforce/resourceUrl/wapp_new_message'; 

const fields = [MOBILE_PHONE];
export default class WhatsappMessanger extends LightningElement {

    @track _messages = [
        /* {
            id: 1,
            sender: 'other',
            content: 'Hi there! How can I help you today?',
            time: '10:00 AM',
            class: 'sent-message'
        } */
    ];
    @track error;

    disableSend = true;

    @api recordId = '';
    templateName;
    wiredMessagesResult;

    showReplyView = false;
    selectedMessage = undefined;

    @track newMessage = '';

    playNewMessageSound = false;
    renderedCallback() {
        // Check if the messages div reference exists and the component is rerendered
        if (this.playNewMessageSound) {
            this.playNewMessageSound = false;
            const audioElement = new Audio(newMessageSoundUrl);
            audioElement.play();
        }
        this.scrollToBottom();
       
    }

    get messages() {
        return this._messages;
    }

    // Method to check if the component is rerendered
    isRerendered() {
        const { isDirty } = this.template;
        return isDirty;
    }

    // Method to scroll the messages div to the bottom
    scrollToBottom() {
        if(this._messages && this._messages.length > 0) {
            const recentMessageClass = this._messages[this._messages.length - 1].id;
            const topDiv = this.template.querySelector('.'+recentMessageClass);
            if(topDiv) {
                topDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
            }

        }
    }

    

    @wire(getMessagesList, { contactId: '$recordId' })
    wiredMessages(result) {
        debugger;
        this.wiredMessagesResult = result;
        if (result && result.data) {
            console.log('---', result.data);
            this.playNewMessageSound = this._messages.length < result.data.length;
            this._messages = result.data;
            this.error = undefined;
        } else if (result && result.error) {
            this.error = result.error;
            this._messages = undefined;
        }
    }

    //3. Wire the output of the out of the box method getRecord to the property account
    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    contact;

    handleReply(event) {
        debugger;
        let msgId = event.currentTarget.dataset.id;
        console.log(msgId);
        if(msgId) {
            let message = this._messages.find(obj => obj.id === msgId);
            this.selectedMessage = message;
            this.showReplyView = true;
        }
    }

    handleCloseReply() {
        this.selectedMessage = undefined;
        this.showReplyView = false;
    }

    

   
    @track disableSend = true;
    handleChange(event) {
        this.newMessage = event.target.value;
        if(this.newMessage.length > 0) {
            this.disableSend = false;
        }else {
            this.disableSend = true;
        }
    }

    @track disableReplySend = true;
    handleReplyChange(event) {
        this.replyMessage = event.target.value;
        if(this.replyMessage.length > 0) {
            this.disableReplySend = false;
        }else {
            this.disableReplySend = true;
        }
    }

    get getMobilePhone() {
        return getFieldValue(this.contact.data, MOBILE_PHONE);
    }

    connectedCallback() {
        // Subscribe to the channel
        const channel = '/data/Messages__ChangeEvent';
        const messageCallback = (response) => {
            // Handle the update message
            this.handleUpdateMessage(response);
        };
        subscribe(channel, -1, messageCallback).then((subscription) => {
            console.log('Subscribed to EMP API successfully: ', subscription.channel);
            this.subscription = subscription;
        });
    }

    handleUpdateMessage(response) {
        debugger;
        // Handle the received message here.
        if (response.data.payload.ChangeEventHeader.entityName === 'Messages__c' && response.data.payload.ChangeEventHeader.changeType === 'CREATE' && response.data.payload.Contact__c && this.recordId === response.data.payload.Contact__c) {
            //const updatedRecordId = response.data.payload.Id;
            refreshApex(this.wiredMessagesResult);
        }
    }
    

    disconnectedCallback() {
        // Unsubscribe from the channel
        if (this.subscription) {
            unsubscribe(this.subscription, (response) => {
                console.log('unsubscribe() response: ', JSON.stringify(response));
            });
        }
    }

    
    //TODO: get the messages from backend, WHATSAPP server
    handleSendMessage(event) {
        debugger;
        //TODO: show message preview on template selection.
        let replyId = '';
        let inputField = '';
        if(this.selectedMessage) {
            replyId = this.selectedMessage.replyId;
            inputField = this.template.querySelector('.reply-textarea');
        }else {
            inputField = this.template.querySelector('.input-text');
        }

        const message = inputField.value.trim();

        if(!message) {
            console.debug('ideally button should be disabled in this case');
            return;
        }

        

        const phone = getFieldValue(this.contact.data, MOBILE_PHONE);
        if(phone) {
            if(this.templateName) {
                sendMessageTemplate({ templateName: this.templateName, phoneNumber : phone })
                .then(result => {
                    debugger;
                    console.log(result);
                })
                .catch(error => {
                    this.error = error;
                    console.log(error);
                });
            }else {
                sendTextMessage({textMessage: message, phoneNumber : phone, parentId: this.recordId, replyMessageId: replyId}).then(result => {
                    debugger;
                    console.log('--- RESULT '+result);
                    if(result) {
                        //attach to UI
                        const now = new Date();
                        const time = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit'});
                        let conversation = [... this._messages];
                        //this.messages = [...this.messages, newMessage];
                        conversation.push({
                            id: this.makeid(15),
                            content: message,
                            sender: phone,
                            timee: time,
                            messageClass: 'message current-user',
                            isCurrentUser: true
                        });
                        this._messages = conversation;
                        //this.newMessage = '';
                        inputField.value = '';
                        inputField.focus();

                        if(this.selectedMessage) {
                            this.showReplyView = false;
                        }
                    }
                }).catch(error => {
                    console.log('--- ERROR '+error);
                    this.error = error;
                });
            }
        }

    }

    

    handleTemplateSelection(event){
        debugger;
        if(event.detail) {
            this.templateName = event.detail;
            console.log("the selected record template name is"+event.detail);
            this.disableSend = false;
        }else {
            this.disableSend = true;
        }
    }

    async handleOpenModal() {
        debugger;
        const result = await WTemplateModal.open({
            // `label` is not included here in this example.
            // it is set on lightning-modal-header instead
            size: 'large',
            description: 'Choose Whatsapp Template',
        });
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result);
    }

    handleCloseModal() {
      
    }

    makeid(length) {
        let result = '';
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        const charactersLength = characters.length;
        let counter = 0;
        while (counter < length) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength));
            counter += 1;
        }
        return result;
    }


    
}