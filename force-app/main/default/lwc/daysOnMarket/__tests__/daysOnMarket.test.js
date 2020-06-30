import { createElement } from 'lwc';
import DaysOnMarket from 'c/daysOnMarket';

describe('c-days-on-market', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders error if no property is selected', () => {
        // Create initial element
        const element = createElement('c-days-on-market', {
            is: DaysOnMarket
        });
        document.body.appendChild(element);

        const errorPanelElement = element.shadowRoot.querySelector(
            'c-error-panel'
        );
        expect(errorPanelElement.friendlyMessage).toBe(
            'Select a property to see days on the market'
        );
    });
});
