({
	init: function (cmp, event, helper) {
        var refURL = 'apex/FSLMapToShowBoundaries?core.apexpages.request.devconsole=1';
        var URLforVF = $A.get("$Label.c.orgBaseURLforVFPages") + refURL;
        cmp.set('v.baseURL', URLforVF);
        cmp.set('v.mapMarkers', [
            {
                location: {
                    Street: '1600 Pennsylvania Ave NW',
                    City: 'Washington',
                    State: 'DC'
                },

                title: 'The White House',
                description: 'Landmark, historic home & office of the United States president, with tours for visitors.'
            }
        ]);
        cmp.set('v.zoomLevel', 16);
    }
})