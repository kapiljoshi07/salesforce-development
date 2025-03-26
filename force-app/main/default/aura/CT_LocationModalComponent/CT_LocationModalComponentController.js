({
    doInit : function(component, event, helper) {
        const columns = [
            {label: "Token", fieldName: "token", type: "String"},
            {label: "Contact Status", fieldName: "status", type: "String"},
            {label: "Visit Date", fieldName: "visitDate", type: "Date"}
        ];
        component.set("v.visitors_columns", columns);
    }
})