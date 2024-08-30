({
        doSave: function(component, event, helper) {
            debugger;
            if(component.find("fileId").get("v.files") == null)
                alert('Please Select a File');
            else if (component.find("fileId").get("v.files").length > 0) {
             helper.uploadHelper(component, event);
            }
          },
        handleFilesChange: function(component, event, helper) {
            debugger;
            var customFileName = 'No File Selected..';
            var customFileType = '';
            var fileExtension ='';
            if (event.getSource().get("v.files").length > 0) {
                customFileName = event.getSource().get("v.files")[0]['name'];
                customFileType = event.getSource().get("v.files")[0]['type'];
                fileExtension = customFileName.split('.')[1];
            }
            component.set("v.fileName", customFileName);
        },
        closeModel: function(component,event,helper){
            var cmpTarget = component.find('Modalbox');
            var cmpBack = component.find('Modalbackdrop');
            $A.util.removeClass(cmpBack,'slds-backdrop--open');
            $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
            component.set("v.showFileUpload",false);
        },
    })