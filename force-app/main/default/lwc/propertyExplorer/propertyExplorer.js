import { LightningElement } from 'lwc';
// Example with statically analyzable dynamic import
const COMPONENT_MAP = {
    tile: () => import('c/propertyTileList'),
    table: () => import('c/propertyListDataTable')
};
export default class PropertyExplorer extends LightningElement {
    componentConstructor;
    viewType = 'table';
    // Use connectedCallback() on the dynamic component
    // to signal when it's attached to the DOM
    async connectedCallback() {
        const ctor = await COMPONENT_MAP[this.viewType]();
        this.componentConstructor = ctor.default;
    }

    async handleToggleChange(event) {
        if (event.target.checked) {
            this.viewType = 'tile';
        } else {
            this.viewType = 'table';
        }
        const ctor = await COMPONENT_MAP[this.viewType]();
        this.componentConstructor = ctor.default;
    }
}