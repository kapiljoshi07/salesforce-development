({
    createRecords : function(objectApiName) {
        let createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": objectApiName,
        });
        createRecordEvent.fire();
    },

    getMapWithAllKeys: function(resMap){
        let completeMap = new Map();
        if(resMap.get('Green')){
            completeMap.set('Green', resMap.get('Green'))
        }else{
            completeMap.set('Green', 0);
        }
        if(resMap.get('Yellow')){
            completeMap.set('Yellow', resMap.get('Yellow'))
        }else{
            completeMap.set('Yellow', 0);
        }
        if(resMap.get('Orange')){
            completeMap.set('Orange', resMap.get('Orange'))
        }else{
            completeMap.set('Orange', 0);
        }
        if(resMap.get('Red')){
            completeMap.set('Red', resMap.get('Red'))
        }else{
            completeMap.set('Red', 0);
        }
        return completeMap;
    }
})