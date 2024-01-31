// Code copied from https://salesforce.stackexchange.com/questions/272371/interacting-with-the-browser-clipboard-from-lwc

const copyTextToClipboard = async (content) => {
    // Create an input field with the minimum size and place in a not visible part of the screen
    let tempTextAreaField = document.createElement('textarea');
    tempTextAreaField.style = 'position:fixed;top:-5rem;height:1px;width:10px;';

    // Assign the content we want to copy to the clipboard to the temporary text area field
    tempTextAreaField.value = content;

    // Append it to the body of the page
    document.body.appendChild(tempTextAreaField);

    // Select the content of the temporary markup field
    tempTextAreaField.select();

    // Available when LWS is enabled
    if (navigator.clipboard) {
        const selection = document.getSelection();
        await navigator.clipboard.writeText(selection.toString());
    } else {
        // deprecated but still a good fallback because it is supported in most of the browsers
        document.execCommand('copy');
    }

    // Remove the temporary element from the DOM as it is no longer needed
    tempTextAreaField.remove();
};

export { copyTextToClipboard };
