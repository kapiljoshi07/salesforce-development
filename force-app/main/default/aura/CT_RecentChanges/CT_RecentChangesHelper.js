({
    fetchDataFromApex : function(component,action, params, self) {
        if(params != null){
            action.setParams(params);
        }
        action.setCallback(self, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.data", response.getReturnValue());
                component.set("v.issearching", false);
            }else{
                console.log("Some error occurred while fetching records");
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})