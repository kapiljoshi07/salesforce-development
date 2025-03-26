({
    viewHandler : function(component, event, helper) {
        let personColumns = [
            { label : "Name", fieldName : "Name", type : "String"},
            { label : "Health Status", fieldName : "Health_Status__c", type : "String"},
            { label : "Mobile", fieldName : "Mobile__c", type : "String"},
            { label : "Status Update Date", fieldName : "Status_Update_Date__c", type : "Date"},
            { label : "Token", fieldName : "Token__c", type : "String"},
            { label : "Action", type : "button", typeAttributes: { label : "View/Update", name: "view_update", title: "Click to view/update details"}}
        ];

        let locationColumns = [
            { label : "Name", fieldName : "Name", type : "String"},
            { label : "Status", fieldName : "Status__c", type : "String"},
            { label : "Address", fieldName : "Address__c", type : "String"},
            { label : "Pincode", fieldName : "Pincode__c", type : "Date"},
            { label : "Red Score", fieldName : "Red_Score__c", type : "Number"},
            { label : "Action", type : "button", typeAttributes: { label : "View/Update", name: "view_update", title: "Click to view/update details"}}
        ];

        const columns = component.get("v.view") === "Person View" ? personColumns : locationColumns;
        const action = component.get("v.view") === "Person View" ? component.get("c.getPersonRecentChanges") : component.get("c.getLocationRecentChanges");
        component.set("v.columns", columns);
        helper.fetchDataFromApex(component, action, null, this);
    },

    handleSearchEvent : function(component, event, helper) {
        component.set("v.issearching", true);
        const searchQuery = component.find("searchBar").get("v.value");
        let action;
        if(component.get("v.view")==="Person View"){
            action = component.get("c.getPersons");
        }else{
            action = component.get("c.getLocations");
        }
        const params = {"searchQuery": searchQuery};
        helper.fetchDataFromApex(component, action, params, this);
    },

    onRowActionHandler : function(component, event, helper){
        const row = event.getParam('row')
        const recordId = row.Id;
        const statusField = component.get("v.view") === "Person View" ? "Health_Status__c" : "Status__c";
        const objApiName = component.get("v.view") === "Person View" ? "Person__c" : "Location__c";
        const healthStatus = row[statusField];
        const appEvt = $A.get("e.c:CT_RecordViewOrUpdateAppEvent");
        appEvt.setParams({
            "recordId":recordId,
            "objApiName":objApiName,
            "status":healthStatus
        });
        appEvt.fire();
    }
})