window.execTestMethod = function(event){
        let dataLayer = {};
        let dataIntent = event.target.dataset.intent;
        let dataScope = event.target.dataset.intent;
        let dataText = event.target.dataset.intent;
        let dataId = event.target.dataset.id;
        dataLayer.linkName  = `${dataIntent} | ${dataScope} | ${dataText}`;
        dataLayer.linkIntent  = dataIntent;
        dataLayer.linkScope  = dataScope;
        this.dispatchEvent(new CustomEvent('testclick', {
            bubbles: true,
            composed: false,
            detail: {
                'dataLayer' : dataLayer
            }
        }));
}