import * as Functions from './functions.js';

const mainContent = document.getElementById('mpDetails');
const loading = document.getElementById('loading');
const params = new URLSearchParams(window.location.search);

Functions.setupHeaderFooterStyleTitleSearch(mainContent);
//////////////////////////////////////////////////////////////////////////////

const file = params.get('file');
const mpVersion = params.get('version');

if (!file || !mpVersion) {
    loading.textContent = "Missing parameters.";
} else {
    Functions.loadMP(file, mpVersion)
        .then(xmlDoc => {
            displayMP(xmlDoc, file);
        })
        .catch(err => {
            loading.textContent = err.message;
        });
}

async function displayMP(xmlDoc, filename) {
    loading.style.display = 'none';
    mainContent.style.display = 'block';

    const manifest = xmlDoc.querySelector('Manifest Identity') || {};
    const version = manifest.querySelector("Version").textContent || 'Unknown';

    const displayName = xmlDoc.evaluate(`/ManagementPack/LanguagePacks/LanguagePack[@ID='ENU']/DisplayStrings/DisplayString[@ElementID='${filename}']/Name`, xmlDoc, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue?.innerHTML
        || xmlDoc.evaluate(`/ManagementPack/Manifest/Name`, xmlDoc, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue?.innerHTML;

    const description = xmlDoc.evaluate(`/ManagementPack/LanguagePacks/LanguagePack[@ID='ENU']/DisplayStrings/DisplayString[@ElementID='${filename}']/Description`, xmlDoc, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue?.innerHTML;

    const sections = [];

    sections.push(`<a href="../MP_data/${filename}/${mpVersion}/MP.xml" target="_blank">Show MP XML</a>`);

    // Fetch available versions and populate the <select> element
    const versionsXml = await Functions.getAvailableMPVersions(filename);
    const versions = Array.from(versionsXml.getElementsByTagName('MPVersion'))
        .map(versionNode => versionNode.getAttribute('Version'));

    const combinedHeader = `
    <div id="combinedHeader">
        <h1 title="The ID of the MP">${filename}</h1>
        ${versions.length > 1
            ? `<label for="versionSelect">Version:</label>
               <select id="versionSelect" title="Other versions of this MP are available.">
                   ${versions.map(version => `<option value="${version}" ${version === mpVersion ? 'selected' : ''}>${version}</option>`).join('')}
               </select>`
            : `<span class="versionText">Version: ${versions[0]}</span>`}
    </div>`;
    sections.push(combinedHeader);

    if (description) {
        sections.push(`
        <div id="mpDetailsLine" style="display: flex; align-items: center; gap: 1em;">
            <h3 title="The English (ENU) Name of the MP. Fallback is the Name element in the MP Manifest." style="margin: 0;">${displayName}</h3>
            <p title="The English (ENU) Description of the MP." style="margin: 0;">${description}</p>
        </div>
    `);
    } else {
        sections.push(`
        <div id="mpDetailsLine" style="display: flex; align-items: center; gap: 1em;">
            <h3 title="The English (ENU) Name of the MP. Fallback is the Name element in the MP Manifest." style="margin: 0;">${displayName}</h3>
        </div>
    `);
    }


    /*
    //*[@ID]   ==> returns the "parent" node of the ID attribute
    //@ID      ==> returns "just" the ID attribute of the node
    */
    //const countOfIDs = xmlDoc.evaluate("//*[@ID]", xmlDoc, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null).snapshotLength;  
    //sections.push(`<h3>ID attrs count: ${countOfIDs}</h3>`);

    sections.push(parseSection(xmlDoc, 'ClassTypes ClassType', 'Class Types', 'ClassType'));
    sections.push(parseSection(xmlDoc, 'RelationshipType', 'Relationship Types', 'RelationshipType'));
    sections.push(parseSection(xmlDoc, 'Rule', 'Rules', 'Rule'));
    sections.push(parseSection(xmlDoc, 'Monitor', 'Monitors', 'Monitor'));
    sections.push(parseSection(xmlDoc, 'Discovery', 'Discoveries', 'Discovery'));
    sections.push(parseSection(xmlDoc, 'View', 'Views', 'View'));
    sections.push(parseSection(xmlDoc, 'Override', 'Overrides', 'Override'));
    sections.push(parseSection(xmlDoc, 'SchemaTypes SchemaType', 'Schema Types', 'SchemaType'));
    sections.push(parseSection(xmlDoc, 'DataSourceModuleType', 'DataSource Module Types', 'DataSourceModuleType'));


    mainContent.innerHTML = sections.join('');

    // Add event listener for version change
    const versionSelectElement = document.getElementById('versionSelect');
    versionSelectElement.addEventListener('change', (event) => {
        const selectedVersion = event.target.value;

        // Update the URL with the new version parameter
        const urlParams = new URLSearchParams(window.location.search);
        urlParams.set('version', selectedVersion);

        // Refresh the page with the updated URL
        window.location.search = urlParams.toString();
    });

}

/// Function to parse sections of the XML and generate HTML
/// This function takes the XML document, the tag name to search for, the title for the section, and the type of element to be passed to element.html
function parseSection(xmlDoc, tagName, title, type) {
    const nodes = xmlDoc.querySelectorAll(tagName);
    if (nodes.length === 0) return '';

    //let html = `<h2>${title} (${nodes.length})</h2>`;

    // Collect all unique attribute names from the nodes
    const allAttributes = new Set();
    nodes.forEach(node => {
        Array.from(node.attributes).forEach(attr => {
            allAttributes.add(attr.name);
        });
    });

    // Ensure "ID" is the first column, followed by "DisplayName" and "Description", and then other attributes
    const attributeList = ['ID', 'DisplayName', 'Description', ...Array.from(allAttributes).filter(attr => attr !== 'ID')];

    // Create table headers dynamically based on the attributes
    let html = `<table class="table-section"><caption>${title} (${nodes.length})</caption><thead><tr>`;
    attributeList.forEach(attr => {
        html += `<th>${attr}</th>`;
    });
    html += `</tr></thead><tbody>`; // Ensure <tbody> is explicitly added

    // Populate table rows with attribute values
    nodes.forEach(node => {
        html += `<tr>`;

        // Extract ID, DisplayName, and Description first
        const idValue = node.getAttribute('ID') || '';
        let displayName = '';
        let description = '';

        if (idValue) {
            // Search for LanguagePack with ID="ENU"
            let displayNode = xmlDoc.evaluate(
                `/ManagementPack/LanguagePacks/LanguagePack[@ID='ENU']/DisplayStrings/DisplayString[@ElementID='${idValue}']`,
                xmlDoc,
                null,
                XPathResult.FIRST_ORDERED_NODE_TYPE,
                null
            ).singleNodeValue;

            // If not found, search for LanguagePack with IsDefault="true"
            if (!displayNode) {
                displayNode = xmlDoc.evaluate(
                    `/ManagementPack/LanguagePacks/LanguagePack[@IsDefault='true']/DisplayStrings/DisplayString[@ElementID='${idValue}']`,
                    xmlDoc,
                    null,
                    XPathResult.FIRST_ORDERED_NODE_TYPE,
                    null
                ).singleNodeValue;
            }

            // Extract the DisplayName and Description values if found
            if (displayNode) {
                displayName = displayNode.querySelector('Name')?.textContent || '';
                description = displayNode.querySelector('Description')?.textContent || '';
            }
        }

        // Add ID column
        html += `<td><a href="element.html?file=${file}&version=${mpVersion}&type=${type}&id=${idValue}">${idValue}</a></td>`;

        // Add DisplayName and Description columns
        html += `<td>${displayName}</td>`;
        html += `<td>${description}</td>`;

        // Add other attributes to the row
        Array.from(allAttributes)
            .filter(attr => attr !== 'ID')
            .forEach(attr => {
                const value = node.getAttribute(attr) || '';

                if (value.includes('!')) {
                    // Handle "MPalias!elementName" format
                    const [alias, elementName] = value.split('!');
                    const referenceNode = xmlDoc.evaluate(
                        `/ManagementPack/Manifest/References/Reference[@Alias='${alias}']`,
                        xmlDoc,
                        null,
                        XPathResult.FIRST_ORDERED_NODE_TYPE,
                        null
                    ).singleNodeValue;

                    if (referenceNode) {
                        html += `<td><a target="_blank" href="element.html?file=${referenceNode.querySelector("ID").textContent}&version=${referenceNode.querySelector("Version").textContent}&type=${type}&id=${elementName}">${elementName}</a> in ${referenceNode.querySelector("ID").textContent}(${referenceNode.querySelector("Version").textContent})</td>`;
                    } else {
                        html += `<td>${value}</td>`; // should never happen
                    }
                } else {
                    // Display value as is if it doesn't contain "!"
                    html += `<td>${value}</td>`;
                }
            });

        html += `</tr>`;
    });

    html += '</tbody></table>';
    return html;
}

