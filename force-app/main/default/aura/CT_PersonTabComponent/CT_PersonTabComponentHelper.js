({
    fetchDataFromApex : function(component) {
        component.set("v.data", null);
        component.set("v.showModal", false);
        component.set("v.issearching", true);
        const personId = component.get("v.searchQuery");
        const action = component.get("c.getUserDetails");
        action.setParams({
            personId : personId
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                if(Object.keys(response.getReturnValue()).includes("name")){
                    component.set("v.data", response.getReturnValue());
                    component.set("v.showModal", true);
                }else{
                    component.set("v.showModal", false);
                    this.showToast("ERROR", "Please enter a valid person Id", "error");
                }
            }else{
                component.set("v.showModal", false);
                this.showToast("ERROR", "Some error occurred"+"\n"+response.getError(), "error");
            }
            console.log(response.getState());
            console.log(JSON.stringify(response.getReturnValue()));
            component.set("v.issearching", false);
        });
        $A.enqueueAction(action);
    },

    showToast: function (title, message, type) {
        //Method definition goes here
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title,
            message,
            type
        });
        toastEvent.fire();
    }
})