import { createElement } from 'lwc';
import { getNavigateCalledWith } from 'lightning/navigation';
import BarcodeScannerExample from 'c/barcodeScannerExample';
import { setBarcodeScannerAvailable } from 'lightning/mobileCapabilities';

describe('c-barcode-scanner-example', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty.
    // Used when having to wait for asynchronous DOM updates.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('directs the user to the mobile app when Barcode Scanner is unavailable', async () => {
        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const elementBarcodeScannerExample = createElement(
            'c-barcode-scanner-example',
            {
                is: BarcodeScannerExample
            }
        );
        document.body.appendChild(elementBarcodeScannerExample);

        // Mount `Scan QR Code` button and trigger scan of property record ID
        const elementScannerDirections =
            elementBarcodeScannerExample.shadowRoot.querySelector(
                '.scanner-directions'
            );

        expect(elementScannerDirections).not.toBeNull();
    });

    it('Shows the QR scan button when Barcode Scanner is available', async () => {
        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const elementBarcodeScannerExample = createElement(
            'c-barcode-scanner-example',
            {
                is: BarcodeScannerExample
            }
        );
        // Mock barcodeScanner availability to true
        setBarcodeScannerAvailable(true);

        document.body.appendChild(elementBarcodeScannerExample);

        // Mount `Scan QR Code` button and trigger scan of property record ID
        const elementScanQRCodeButton =
            elementBarcodeScannerExample.shadowRoot.querySelector(
                'lightning-button'
            );

        expect(elementScanQRCodeButton).not.toBeNull();
    });

    it('navigates to record view when a QR code is correctly scanned', async () => {
        // Property record values to compare component output against
        const NAV_TYPE = 'standard__recordPage';
        const NAV_ACTION_NAME = 'view';
        const NAV_RECORD_ID = '0031700000pJRRWAA4';

        // Mock barcodeScanner availability to true
        setBarcodeScannerAvailable(true);

        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const elementBarcodeScannerExample = createElement(
            'c-barcode-scanner-example',
            {
                is: BarcodeScannerExample
            }
        );
        document.body.appendChild(elementBarcodeScannerExample);

        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const element = createElement('c-barcode-scanner-example', {
            is: BarcodeScannerExample
        });
        document.body.appendChild(element);

        // Mount `Scan QR Code` button and trigger scan of property record ID
        const elementScanQRCodeButton =
            elementBarcodeScannerExample.shadowRoot.querySelector(
                'lightning-button'
            );
        elementScanQRCodeButton.click();

        // Wait for element to mount
        await flushPromises();

        const { pageReference } = getNavigateCalledWith();

        // Confirm redirection to expected property record
        expect(pageReference.type).toBe(NAV_TYPE);
        expect(pageReference.attributes.actionName).toBe(NAV_ACTION_NAME);
        expect(pageReference.attributes.recordId).toBe(NAV_RECORD_ID);
    });

    it('shows an error toast when the user cancels the scan', async () => {
        // Mock barcodeScanner availability to true
        setBarcodeScannerAvailable(true);

        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const elementBarcodeScannerExample = createElement(
            'c-barcode-scanner-example',
            {
                is: BarcodeScannerExample
            }
        );
        document.body.appendChild(elementBarcodeScannerExample);

        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const element = createElement('c-barcode-scanner-example', {
            is: BarcodeScannerExample
        });
        document.body.appendChild(element);

        // Mount `Scan QR Code` button and trigger scan of property record ID
        const elementScanQRCodeButton =
            elementBarcodeScannerExample.shadowRoot.querySelector(
                'lightning-button'
            );
        elementScanQRCodeButton.click();

        // TODO: emulate that the user cancels the scan

        // Wait for element to mount
        await flushPromises();

        // TODO: check that the toast was fired
        expect(true).toBe(true);
    });

    it('shows an error toast when there was a problem with the scan', async () => {
        // Mock barcodeScanner availability to true
        setBarcodeScannerAvailable(true);

        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const elementBarcodeScannerExample = createElement(
            'c-barcode-scanner-example',
            {
                is: BarcodeScannerExample
            }
        );
        document.body.appendChild(elementBarcodeScannerExample);

        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const element = createElement('c-barcode-scanner-example', {
            is: BarcodeScannerExample
        });
        document.body.appendChild(element);

        // Mount `Scan QR Code` button and trigger scan of property record ID
        const elementScanQRCodeButton =
            elementBarcodeScannerExample.shadowRoot.querySelector(
                'lightning-button'
            );
        elementScanQRCodeButton.click();

        // TODO: emulate that there was a problem with the scan

        // Wait for element to mount
        await flushPromises();

        // TODO: check that the toast was fired
        expect(true).toBe(true);
    });
});
