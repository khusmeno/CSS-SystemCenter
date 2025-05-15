import * as Functions from './functions.js';

function formatNode(node, level) {
    const indent = '  '.repeat(level);
    let html = '';

    if (node.nodeType === Node.ELEMENT_NODE) {
        let attrs = '';
        for (let attr of node.attributes) {
            attrs += ` <span class="xml-attribute">${attr.name}</span>=<span class="xml-value">"${attr.value}"</span>`;
        }

        // Check if the element is self-closing
        if (node.childNodes.length === 0) {
            html += `${indent}&lt;<span class="xml-tag">${node.nodeName}</span>${attrs} /&gt;`;
        } else {
            html += `${indent}&lt;<span class="xml-tag">${node.nodeName}</span>${attrs}&gt;`;

            let hasChildElements = false;
            for (let child of node.childNodes) {
                if (child.nodeType === Node.ELEMENT_NODE || child.nodeType === Node.COMMENT_NODE) {
                    html += '\n' + formatNode(child, level + 1);
                    hasChildElements = true;
                } else if (child.nodeType === Node.TEXT_NODE) {
                    const text = child.textContent.trim();
                    if (text) {
                        html += `<span class="xml-text">${text}</span>`;
                    }
                }
            }

            if (hasChildElements) {
                html += `\n${indent}`;
            }
            html += `&lt;/<span class="xml-tag">${node.nodeName}</span>&gt;`;
        }
    } else if (node.nodeType === Node.TEXT_NODE) {
        const text = node.textContent.trim();
        if (text) {
            html += `${indent}<span class="xml-text">${text}</span>`;
        }
    } else if (node.nodeType === Node.COMMENT_NODE) {
        html += `${indent}&lt;!-- <span class="xml-text">${node.nodeValue}</span> --&gt;`;
    }
    return html;
}



const mainContent = document.getElementById('elementDetails');
const loading = document.getElementById('loading');

const params = new URLSearchParams(window.location.search);
const file = params.get('file');
const mpVersion = params.get('version');
const elementID = params.get('id');
let elementType = params.get('type');

if (!file || !mpVersion || !elementID || !elementType) {
    loading.textContent = "Missing parameters.";
} else {
    Functions.loadMP(file, mpVersion)
        .then((xmlDoc) => {
            loading.style.display = 'none';
            mainContent.style.display = 'block';

            if (elementType === "Element") {
                elementType = xmlDoc.querySelector(`[ID="${elementID}"]`)?.tagName;
            }

            const scriptUrl = `../scripts/${elementType}.js`;
            Functions.loadDynamicScript(scriptUrl, () => {
                if (typeof displayElement === 'function') {
                    displayElement(xmlDoc, file, mpVersion, elementID); // Call the function from the loaded script

                    // Extract and display the XML fragment for the given elementID
                    const xmlFragment = xmlDoc.querySelector(`[ID="${elementID}"]`);  //todo                    
                    if (xmlFragment) {
                        const highlightedXml = formatNode(xmlFragment, 0); // Format the XML node for display)                       

                        // Create a container to display the XML fragment
                        const xmlContainer = document.createElement('pre');
                        xmlContainer.style.backgroundColor = '#f9f9f9';
                        xmlContainer.style.border = '1px solid #ccc';
                        xmlContainer.style.padding = '1em';
                        xmlContainer.style.marginTop = '1em';
                        xmlContainer.style.overflowX = 'auto';
                        xmlContainer.style.fontFamily = 'Courier New, Courier, monospace';
                        xmlContainer.style.fontSize = '12px';
                        xmlContainer.innerHTML = highlightedXml; // Use innerHTML to render highlighted XML

                        // Append the XML container to the main content
                        mainContent.appendChild(xmlContainer);
                    } else {
                        console.warn(`No XML fragment found for elementID: ${elementID}`);
                    }

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
