import * as Functions from './functions.js';

const mainContent = document.getElementById('elementDetails');
const loading = document.getElementById('loading');
const params = new URLSearchParams(window.location.search);
const file = params.get('file');
const mpVersion = params.get('version');
const elementID = params.get('id');
let elementType = params.get('type');

Functions.setupHeaderFooterStyleTitleSearch(mainContent);
///////////////////////////

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

    const backToMpUrl = `mp.html?file=${encodeURIComponent(filename)}&version=${encodeURIComponent(mpVersion)}`;
    // Add combinedHeader-like output
    const combinedHeader = `
    <div id="combinedHeader">
        <a href="${backToMpUrl}" class="back-to-mp-btn" title="Back to Management Pack">
            &#8592; Back to MP
        </a>
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

    let metaDesr = "";
    // Only push if displayName or description has a value
    if (displayName || description) {
        sections.push(`
        <div id="elementDetailsLine" class="detailsLine">
            ${displayName ? `<h3 title="The DisplayName of the Element">${displayName}</h3>` : ''}
            ${description ? `<p title="The Description of the Element">${description}</p>` : ''}
        </div>
    `);
        if (description) {
            metaDesr = description;
        }
        else {
            metaDesr = displayName;
        }       
    }

    Functions.setDocumentTitle(elementID.replace(/<[^>]+>/g, ' ').trim());
    Functions.addMetaDescription(metaDesr.replace(/<[^>]+>/g, ' ').trim());

    sections.push('<div id="attributes-table-placeholder"></div>');

    return sections.join('');
}

async function showAttributesAsTable(node) {
    if (!node || !node.attributes || node.attributes.length === 0) {
        return '<p>No attributes available for this element.</p>';
    }

    // Get context from URL for file, version, and type
    const params = new URLSearchParams(window.location.search);
    const file = params.get('file');
    const mpVersion = params.get('version');
    const type = params.get('type');

    // Load MP references for cross-MP links
    const xmlDoc = await Functions.loadMP(file, mpVersion);
    const mpRefs = xmlDoc.evaluate(
        `/ManagementPack/Manifest/References`,
        xmlDoc,
        null,
        XPathResult.FIRST_ORDERED_NODE_TYPE,
        null
    ).singleNodeValue;

    let html = `
        <table class="attributes-table">
            <thead>
                <tr>
                    <th colspan="2">Attributes</th>
                </tr>
            </thead>
            <tbody>
    `;

    for (let attr of node.attributes) {
        if (attr.name !== 'ID') {
            // Check if this attribute is a reference
            const targetElementType = await Functions.getTargetElementType(type, attr.name);
            let valueHtml = attr.value;
            if (targetElementType) {
                let referencedFile = file;
                let referencedVersion = mpVersion;
                let referencedElementId = attr.value;

                if (mpRefs && attr.value.includes('!')) {
                    const [alias, elementName] = attr.value.split('!');
                    const referenceNode = mpRefs.querySelector(`Reference[Alias="${alias}"]`);
                    if (referenceNode) {
                        referencedFile = referenceNode.querySelector("ID").textContent;
                        referencedVersion = referenceNode.querySelector("Version").textContent;
                        referencedElementId = elementName;
                    }
                }
                valueHtml = `<a href="element.html?file=${referencedFile}&version=${referencedVersion}&type=${targetElementType}&id=${referencedElementId}">${referencedElementId}</a>`;
            }
            else {                
                if (valueHtml.includes('!')) {
                    valueHtml = `<a title="Click to fix" href="https://github.com/microsoft/CSS-SystemCenter/blob/main/docs/mp-buddy/README.md#how-to-add-missing-links-to-other-elements" target="_blank" rel="noopener">?? </a>${valueHtml}`
                }                
            }
            html += `
                <tr>
                    <td>${attr.name}</td>
                    <td>${valueHtml}</td>
                </tr>
            `;
        }
    }

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

            const container = document.querySelector('header .container');
            const filterInput = container.querySelector('#filterByText');
            const typeSpan = document.createElement('span');
            typeSpan.className = 'element-type-label';
            typeSpan.textContent = elementType;
            // Insert before the filter input
            container.insertBefore(typeSpan, filterInput);

            // Hide the filter input in element.js
            filterInput.style.display = 'none';

            mainContent.innerHTML += displayElement(xmlDoc, file, mpVersion, elementType, elementID); // Call the function to display the element details

            // After rendering, call the async function and insert the result
            showAttributesAsTable(elementIDNode).then(html => {
                const placeholder = document.getElementById('attributes-table-placeholder');
                if (placeholder) {
                    placeholder.outerHTML = html;
                }
            });

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

