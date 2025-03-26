({
    updateStatusToRed : function(component, self) {
        const action = component.get("c.updateStatusToRed");
        console.log("Helper:recordid ", component.get("v.recordid"));
        action.setParams({
            personId : component.get("v.recordid")
        });
        action.setCallback(self, function(response){
            if(response.getState() === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})