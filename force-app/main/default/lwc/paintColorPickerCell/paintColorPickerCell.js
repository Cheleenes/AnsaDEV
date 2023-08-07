import LightningDatatable from 'lightning/datatable';
import customColorTemplate from './CellTemplate.html';

export default class PaintColorPickerCell extends LightningDatatable {
    static customTypes = {
        customColor: {
            template: customColorTemplate,
            standardCellLayout: true,
            typeAttributes: ['hexColor'],
        }
    }
}