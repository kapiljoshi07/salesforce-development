({
    handleActive : function(component, event, helper) {
        const tab = event.getSource();
        const viewType = tab.get("v.id") === 'person' ? 'Person View' : 'Location View';
        component.set("v.viewType", viewType);
        const viewCmp = viewType === 'Person View' ? component.find('personView') : component.find('locationView');
        viewCmp.renderView();
    }
})