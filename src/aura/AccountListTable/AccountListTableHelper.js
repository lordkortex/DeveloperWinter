({
      // Fetch the accounts from the Apex controller
      getAccountList: function(component) {
        var action = component.get('c.getAccounts');
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
         component.set('v.accounts', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
      },
    
     manualShareRead: function(component,recordIdInput) {
        var action = component.get('c.manualShareRead');
	    action.setParams({
		    recordId:recordIdInput
		});

        var self = this;
        action.setCallback(this, function(actionResult) {
         //component.set('v.accounts', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
      }
      
    })