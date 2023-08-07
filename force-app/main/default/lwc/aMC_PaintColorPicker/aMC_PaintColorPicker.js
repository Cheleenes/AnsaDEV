import { LightningElement, wire, track, api } from 'lwc';
import getColors from '@salesforce/apex/AMC_PaintColorPickerController.getColors';
import setColor from '@salesforce/apex/AMC_PaintColorPickerController.setColor';

/*const COLS = [
    { label: 'Colour Name', fieldName: 'Paint_Color__r.Name', initialWidth: 250},
    { label: 'Colour', type: 'customColor', initialWidth: 100, typeAttributes: {hexColor: { fieldName: 'Paint_Color__r.Style_Text__c'}}}
];*/

const COLS = [
    { label: 'Colour Name', fieldName: 'Name', initialWidth: 250},
    { label: 'Colour', type: 'customColor', initialWidth: 100, typeAttributes: {hexColor: { fieldName: 'Style_Text__c'}}}
];

export default class AMC_PaintColorPicker extends LightningElement {
    colorsColumns = COLS;
    searchValue = '';
    render = false;
    selectedRow;

    @api recordId;
    //recordId = '01t3C000006iTHoQAM';

    @track colorsData;
    @track initialRecords;
    @track error;

    colorsDataSearch;

    @wire(getColors, { productId :  '$recordId'})
    colorsAllData({ error, data }) {
        if (data) {
            console.log(data);
            console.log('record id: ' + this.recordId);
            let colorsList = [];
            for (let record of data){
                console.log(record.Paint_Color__r);
                colorsList.push(record.Paint_Color__r);
            }
            this.colorsData = colorsList;
            this.initialRecords = colorsList;
            console.log(this.colorsData);
            console.log(this.initialRecords);
            //this.colorsData = data;
            //this.initialRecords = data;
            this.error = undefined;
            this.render = true;
        } else if (error) {
            this.error = error;
            this.colorsData = undefined;
            this.render = false;
        }
    }

    
    
    searchKeyword(event) {
              
        const searchKey = event.target.value.toLowerCase();
        console.log('searching for colors with key word: ' + searchKey);  
        this.colorsData = this.initialRecords;
        if(searchKey){
            let searchRecords = [];
            for (let record of this.colorsData) {
                let valuesArray = Object.values(record);
                let strVal = String(valuesArray[0]);
                if (strVal) {

                    if (strVal.toLowerCase().includes(searchKey)) {
                        searchRecords.push(record);
                    }
                }
            }
            this.colorsData = searchRecords;
        }else{
            this.colorsData = this.initialRecords;
        }
        console.log('new colors: ' + this.colorsData);
    }

    getSelectedRow(event) {
        let styleText = event.detail.selectedRows[0].Style_Text__c;
        this.selectedRow = styleText.substring(styleText.length - 7);
        console.log('color selected: ' + this.selectedRow);
        setColor({ colorHex: this.selectedRow });
    }
}