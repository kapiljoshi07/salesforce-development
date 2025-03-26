({
    doInit : function(component, event, helper) {
        const data = component.get("v.data");
        console.log("Data ");
        console.log(JSON.stringify(data));
        const contactsColumns = [
            {label: "Token", fieldName:"token", type:"String"},
            {label: "Contact Status", fieldName:"status", type:"String"},
            {label: "Contact Date", fieldName:"contactDate", type:"Date"}
        ];
        component.set("v.contacts_columns", contactsColumns);
        const personData = data.closeContacts;
        component.set("v.contacts_data", personData);
    }   
})