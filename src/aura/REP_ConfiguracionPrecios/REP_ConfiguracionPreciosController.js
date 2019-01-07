({
	init: function (component,helper) {
        
        var items = [];
        for (var i = 0; i < 79; i++) {
            var item = {
                "label": "0002" + i,
                "value": "opt" + i,
            };
            items.push(item);
        }
        component.set("v.optionsCP", items);
        component.set("v.valuesCP", ["opt10", "opt5", "opt7"]);
        component.set("v.requiredOptionsCP", ["opt10"]);

        var itemsGasoleo = [];
        for (var i = 1; i <= 3; i++) {
            var item = {
                "label": "Gasolea " + i,
                "value": "gas" + i,
            };
            itemsGasoleo.push(item);
        }
        component.set("v.optionsTipoGasoleo", itemsGasoleo);

        
       var itemFiltrosCodigoPostal = [];
       var item1 = {"label": "Todos",  "value": "Todos" };
       var item1 = {"label": "Seleccion Personalizada",  "value": "Seleccion Personalizada" };
       var item2 = {"label": "Grupo 1",  "value": "Grupo 1" };
       var item3 = {"label": "Grupo 2",  "value": "Grupo 2" };
       itemFiltrosCodigoPostal.push(item1);
       itemFiltrosCodigoPostal.push(item2);
       itemFiltrosCodigoPostal.push(item3);
        
       component.set("v.optionsFiltroCodigoPostal", itemFiltrosCodigoPostal);

         

        // data
       /*var columns = [
            {
                type: 'text',
                fieldName: 'CodigoPostal',
                label: 'Codigo Postal',
                initialWidth: 300
            },
            {
                type: 'text',
                fieldName: 'Producto',
                label: 'Producto'
            },
            {
                type: 'currency',
                fieldName: 'Precio',
                label: 'Precio',
                typeAttributes: {
                    label: { fieldName: 'accountOwnerName' }
                }
            },
            {
                type: 'number',
                fieldName: 'Litros',
                label: 'Litros'
            }
        ];

        component.set('v.gridColumns', columns);

        var nestedData = [
            {
                "CodigoPostal": "123555",
                "Producto": "Rewis Inc",
                "Precio": 0.54,
                "Litros": 1200
            }
        ];

        component.set('v.gridData', nestedData);
        helper = this;
        var rowActions = helper.getRowActions.bind(this, component);*/
        
    },
    
    handleChange: function (component, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        //alert("Option selected with value: '" + selectedOptionValue.toString() + "'");
    },
    openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   }
 
})