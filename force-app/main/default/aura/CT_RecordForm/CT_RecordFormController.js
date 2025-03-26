({
    handleAppEvent : function(component, event, helper) {
        console.log("record Id "+event.getParam("recordId"));
        console.log("status "+event.getParam("status"));
        console.log("objectApiName "+event.getParam("objApiName"));
        const recId = event.getParam("recordId");
        const objApiName = event.getParam("objApiName");
        const healthStatus = event.getParam("status");
        component.set("v.recordid", recId);
        component.set("v.objectapiname", objApiName);
        component.set("v.status", healthStatus);
        component.set("v.mode", "view");
        const personFields = ["Name", "Health_Status__c", "Mobile__c", "Status_Update_Date__c", "CreatedDate"];
        const locationFields = ["Name", "Status__c", "Address__c", "Pincode__c", "Red_Score__c", "Status_Update_Date__c"];
        const fields = component.get("v.objectapiname") === "Person__c" ? personFields : locationFields;
        component.set("v.fields", fields);
        const showButton = component.get("v.objectapiname") === "Location__c" || component.get("v.status") === "Red" ? false : true;
        component.set("v.showButton", showButton);
        // let showData = false;
        // if(component.get("v.recordid") && component.get("v.objectapiname") && component.get("v.fields")){
        //     showData = true;
        // }
        // component.set("v.showData", showData);
        // console.log("showData", component.get("v.showData"));
    },

    handleClick : function(component, event, helper){
        helper.updateStatusToRed(component, this);
    }
})