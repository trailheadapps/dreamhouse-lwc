import { LightningElement, wire } from 'lwc';
import getDefaultView from '@salesforce/apex/PropertySettingsController.getDefaultView';

export default class PropertyExplorerDynamic extends LightningElement {
    componentConstructor;
    error;
    @wire(getDefaultView)
    wireView({ error, data }) {
        if (data) {
            // Dynamic assignment. Not statically analyzable
            const componentToRender = `c/${data}`;
            this.renderComponent(componentToRender);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.componentConstructor = undefined;
        }
    }
    
    async renderComponent(componentToRender) {
        const ctor = await import(componentToRender);
        this.componentConstructor = ctor.default;
    }
}