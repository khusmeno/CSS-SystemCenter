import * as Functions from './functions.js';

function formatXmlNode(node, level) {
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
                    html += '\n' + formatXmlNode(child, level + 1);
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

function displayElement(xmlDoc, filename, mpVersion, elementType, elementID) {
    const elementIDNode = xmlDoc.querySelector(`${elementType}[ID='${elementID}']`) || {};

    const sections = [];

    // Add combinedHeader-like output
    const combinedHeader = `
    <div id="combinedHeader">
        <h1 title="The ID of the Element">${elementID}</h1>
        <span class="versionText">Version: ${mpVersion}</span>        
    </div>`;
    sections.push(combinedHeader);

    // Pre-select the base path for DisplayStrings for the selected language, e.g. ENU
    let displayStringsBase = xmlDoc.evaluate(
        `/ManagementPack/LanguagePacks/LanguagePack[@ID='ENU']/DisplayStrings`,
        xmlDoc,
        null,
        XPathResult.FIRST_ORDERED_NODE_TYPE,
        null
    ).singleNodeValue;
    // If not found, fallback to the "default" language pack
    if (!displayStringsBase) {
        displayStringsBase = xmlDoc.evaluate(
            `/ManagementPack/LanguagePacks/LanguagePack[@IsDefault='true']/DisplayStrings`,
            xmlDoc,
            null,
            XPathResult.FIRST_ORDERED_NODE_TYPE,
            null
        ).singleNodeValue;
    }
    let displayName = '';
    let description = '';
    if (elementID && displayStringsBase) {
        const displayNode = displayStringsBase.querySelector(`DisplayString[ElementID="${elementID}"]`);
        if (displayNode) {
            displayName = displayNode.querySelector('Name')?.textContent || '';
            description = displayNode.querySelector('Description')?.textContent || '';
        }
    }

    // Add description if available
    if (description) {
        sections.push(`
        <div id="elementDetailsLine" class="detailsLine">
            <h3 title="The DisplayName of the Element">${displayName}</h3>
            <p title="The Description of the Element">${description}</p>
        </div>
    `);
    } else {
        sections.push(`
        <div id="elementDetailsLine" class="detailsLine">
            <h3 title="The DisplayName of the Element">${displayName}</h3>
        </div>
    `);
    }

    sections.push(showAttributesAsTable(elementIDNode));

    /*
        sections.push(parseSection(elementIDNode, 'Property', 'Properties'));
        sections.push(parseSection(xmlDoc, 'RelationshipType', 'RelationshipType')); 
        sections.push(parseSection(xmlDoc, 'Rule', 'Rules'));
        sections.push(parseSection(xmlDoc, 'Monitor', 'Monitors'));
        sections.push(parseSection(xmlDoc, 'Discovery', 'Discoveries'));
        sections.push(parseSection(xmlDoc, 'View', 'Views'));
        sections.push(parseSection(xmlDoc, 'Override', 'Overrides'));
        sections.push(parseSection(xmlDoc, 'SchemaTypes SchemaType', 'SchemaType'));
    */

    //elementDetails.innerHTML += sections.join('');
    return sections.join('');
}

function showAttributesAsTable(node) {
    if (!node || !node.attributes || node.attributes.length === 0) {
        return '<p>No attributes available for this element.</p>';
    }

    // Start building the table
    let html = `
        <table class="attributes-table">
            <thead>
                <tr>
                    <th colspan="2">Attributes</th>                    
                </tr>
            </thead>
            <tbody>
    `;

    // Iterate over the attributes and add rows to the table, excluding the "ID" attribute
    for (let attr of node.attributes) {
        if (attr.name !== 'ID') {
            html += `
                <tr>
                    <td>${attr.name}</td>
                    <td>${attr.value}</td>
                </tr>
            `;
        }
    }

    // Close the table
    html += `
            </tbody>
        </table>
    `;

    return html;
}

function parseSection(xmlDoc, tagName, title) {
    const nodes = xmlDoc.querySelectorAll(tagName);
    if (nodes.length === 0) return '';

    let html = `<h2>${title} (${nodes.length})</h2>`;
    html += `<table style="width: auto"><thead><tr><th>Name</th><th>Description</th></tr></thead><tbody>`;

    nodes.forEach(node => {
        const id = node.getAttribute('ID') || '';
        const name = node.getAttribute('DisplayName') || id;
        const description = node.getAttribute('Description') || '';
        html += `<tr><td>${name}</td><td>${description}</td></tr>`;
    });

    html += '</tbody></table>';
    return html;
}

const mainContent = document.getElementById('elementDetails');
const loading = document.getElementById('loading');
Functions.setupHeaderFooterStyleTitleSearch(mainContent);


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

            const elementIDNode = xmlDoc.querySelector(`${elementType}[ID='${elementID}']`);
            if (!elementIDNode) {
                elementType = "Element"
            }
            if (elementType === "Element") {
                elementType = xmlDoc.querySelector(`[ID="${elementID}"]`)?.tagName;
            }

            mainContent.innerHTML += displayElement(xmlDoc, file, mpVersion, elementType, elementID); // Call the function to display the element details

            // Load the specific script for the element type
            const scriptUrl = `../scripts/${elementType}.js`;
            Functions.loadDynamicScript(scriptUrl, () => {
                if (typeof displayElement === 'function') {
                    displayElement(xmlDoc, file, mpVersion, elementID); // Call the function from the loaded script
                } else {
                    console.warn('displayElement is not defined in the loaded script.');
                }
            });

            // At the bottom, extract and display the XML fragment for the given elementID
            const xmlFragment = xmlDoc.querySelector(`${elementType}[ID="${elementID}"]`);  //todo                    
            if (xmlFragment) {
                const highlightedXml = formatXmlNode(xmlFragment, 0); // Format the XML node for display)                       

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


        })
        .catch((err) => {
            loading.textContent = err.message;
        });
}

