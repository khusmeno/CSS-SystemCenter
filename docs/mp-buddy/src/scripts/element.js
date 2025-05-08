import * as Functions from './functions.js';

const mainContent = document.getElementById('elementDetails');
const loading = document.getElementById('loading');

const params = new URLSearchParams(window.location.search);
const file = params.get('file');
const mpVersion = params.get('version');
const elementID = params.get('id');
const elementType = params.get('type');

if (!file || !mpVersion || !elementID || !elementType) {
    loading.textContent = "Missing parameters.";
} else {
    Functions.loadMP(file, mpVersion)
        //.then(async (xmlDoc) => {
        //    const manifest = xmlDoc.querySelector('Manifest Identity');
        //    const loadedVersion = manifest?.querySelector('Version')?.textContent;

        //    if (loadedVersion && loadedVersion !== mpVersion) {
        //        console.warn(`Loaded version (${loadedVersion}) does not match requested version (${mpVersion}). Reloading...`);
        //        return Functions.loadMP(file, loadedVersion);   // todo : it's incorrect to call loadMP, instead (optionally) redirect to the new version
        //    }

        //    return xmlDoc; // Return the original document if versions match        // todo  ?????????? what is this ???
        //})
        .then((xmlDoc) => {
            loading.style.display = 'none';
            mainContent.style.display = 'block';

            const scriptUrl = `../scripts/${elementType}.js`;
            Functions.loadDynamicScript(scriptUrl, () => {
                if (typeof displayElement === 'function') {
                    displayElement(xmlDoc, file, mpVersion, elementID); // Call the function from the loaded script
                } else {
                    console.error('displayElement is not defined in the loaded script.');
                }
            });
        })
        .catch((err) => {
            loading.textContent = err.message;
        });
}

Functions.setupHeaderFooterStyleTitleSearch(mainContent);
