import { createElement } from 'lwc';
import { getNavigateCalledWith } from 'lightning/navigation';
import BarcodeScannerExample from 'c/barcodeScannerExample';

// Mock various barcode functionality from mobileCapabilites.js
import {
    resetBarcodeScannerStubs,
    setBarcodeScannerAvailable,
    setUserCanceledScan,
    setBarcodeScanError
} from 'lightning/mobileCapabilities';

// Mock various barcode functionality from platformShowToastEvent.js
import {
    resetAllShowToastEventStubs,
    showToastEventCalledWith
} from 'lightning/platformShowToastEvent';

describe('c-barcode-scanner-example', () => {
    afterEach(() => {
        // Reset the JSDOM instance shared across test cases in a single file
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();

        // Reset stubs
        resetBarcodeScannerStubs();
        resetAllShowToastEventStubs();
    });

    // Helper function to wait until the microtask queue is empty.
    // Used when having to wait for asynchronous/DOM updates.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('directs the user to the mobile app when Barcode Scanner is unavailable', async () => {
        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const elementBarcodeScannerExample = createElement(
            'c-barcode-scanner-example',
            { is: BarcodeScannerExample }
        );
        document.body.appendChild(elementBarcodeScannerExample);

        // Mount `Scan QR Code` button and trigger scan of property record ID
        const elementScannerDirections =
            elementBarcodeScannerExample.shadowRoot.querySelector(
                '[data-test="scanner-directions"]'
            );

        expect(elementScannerDirections).not.toBeNull();
    });

    it('shows the `Scan QR Code` button when BarcodeScanner is available', async () => {
        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const elementBarcodeScannerExample = createElement(
            'c-barcode-scanner-example',
            { is: BarcodeScannerExample }
        );
        // Stub barcodeScanner as available
        setBarcodeScannerAvailable();

        document.body.appendChild(elementBarcodeScannerExample);

        // Mount `Scan QR Code` button and trigger scan of property record ID
        const elementScanQRCodeButton =
            elementBarcodeScannerExample.shadowRoot.querySelector(
                'lightning-button'
            );

        expect(elementScanQRCodeButton).not.toBeNull();
    });

    it('navigates to the expected record view when a QR code is correctly scanned', async () => {
        // Property record values to compare component output against
        const NAV_TYPE = 'standard__recordPage';
        const NAV_ACTION_NAME = 'view';
        const NAV_RECORD_ID = '0031700000pJRRWAA4';

        // Stub barcodeScanner availability to true
        setBarcodeScannerAvailable();

        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const elementBarcodeScannerExample = createElement(
            'c-barcode-scanner-example',
            { is: BarcodeScannerExample }
        );
        document.body.appendChild(elementBarcodeScannerExample);

        // Mount `Scan QR Code` button and trigger scan of property record ID
        const elementScanQRCodeButton =
            elementBarcodeScannerExample.shadowRoot.querySelector(
                'lightning-button'
            );
        elementScanQRCodeButton.click();

        // Wait for async scan function to settle
        await flushPromises();

        // Get data the NavigationMixin was called with
        const { pageReference } = getNavigateCalledWith();

        // Confirm redirection to expected property record
        expect(pageReference.type).toBe(NAV_TYPE);
        expect(pageReference.attributes.actionName).toBe(NAV_ACTION_NAME);
        expect(pageReference.attributes.recordId).toBe(NAV_RECORD_ID);
    });

    it('triggers an error toast notification when the user cancels the scan', async () => {
        // Stub barcodeScanner as available
        setBarcodeScannerAvailable();

        // Mock user canceling the scan
        setUserCanceledScan();

        // Create initial BarcodeScannerExample element and attach to virtual DOM
        const elementBarcodeScannerExample = createElement(
            'c-barcode-scanner-example',
            { is: BarcodeScannerExample }
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

        // Check that cancelation toast was triggered
        const { title } = showToastEventCalledWith();
        expect(title).toBe('Scanning Canceled');
    });

    it('shows an error toast when there was a problem with the scan', async () => {
        // Stub barcodeScanner as available
        setBarcodeScannerAvailable();

        // Mock scan erroring out
        setBarcodeScanError();

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

        // Check that generic BarcodeScanner toast was triggered
        const { title } = showToastEventCalledWith();
        expect(title).toBe('Barcode Scanner Error');
    });
});
