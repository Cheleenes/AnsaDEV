import LightningDatatable from 'lightning/datatable';
import customColorTemplate from './aMC_CellTemplate.html';

export default class AMC_PaintColorPickerCell extends LightningDatatable {
    static customTypes = {
        customColor: {
            template: customColorTemplate,
            standardCellLayout: true,
            typeAttributes: ['hexColor'],
        }
    }
}