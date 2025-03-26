({
    onRender : function(component, event, helper){
        const type = component.get("v.view");
        const action = type === 'Person View' ? component.get("c.getPersonHealthStatusCount") : component.get("c.getLocationHealthStatusCount");
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state==='SUCCESS'){
                const responseMap = new Map(Object.entries(response.getReturnValue()));
                const statusToCountMap = helper.getMapWithAllKeys(responseMap);
                if(statusToCountMap){
                    component.set("v.greenCount", statusToCountMap.get('Green'));
                    component.set("v.yellowCount", statusToCountMap.get('Yellow'));
                    component.set("v.orangeCount", statusToCountMap.get('Orange'));
                    component.set("v.redCount", statusToCountMap.get('Red'));
                }
            }else{
                console.log('An error occured while getting values from server');
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    handleClick : function(component, event, helper) {
        let objectType = component.get("v.view") === 'Person View' ? 'Person__c' : 'Location__c';
        helper.createRecords(objectType);
    }
})