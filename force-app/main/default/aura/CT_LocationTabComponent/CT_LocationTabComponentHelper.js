({
    fetchDataFromApex : function(component) {
        console.log("Inside Helper");
        component.set("v.issearching", true);
        const recordId = component.get("v.recordId");
        const action = component.get("c.getLocationDetails");
        action.setParams({locationId: recordId});
        action.setCallback(this, function(response){
            console.log("response state ", response.getState());
            console.log("response ", JSON.stringify(response.getReturnValue()));
            if(response.getState()==='SUCCESS'){
                if(Object.keys(response.getReturnValue()).includes("name")){
                    component.set("v.data", response.getReturnValue());
                    component.set("v.showModal", true);
                    component.set("v.issearching", false);
                }else{
                    component.set("v.showModal", false);
                    component.set("v.issearching", false);
                    this.showToast("ERROR", "Please enter valid location id", "error");
                }
            }else{
                component.set("v.showModal", false);
                component.set("v.issearching", false);
                this.showToast("ERROR", "Some error occurred\n"+response.getError(), "error");
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(title, message, type){
        const toastEvt = $A.get("e.force:showToast");
        toastEvt.setParams({title,message,type});
        toastEvt.fire();
    }
})