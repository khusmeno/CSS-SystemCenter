import * as Functions from './functions.js';

const mainContent = document.getElementById('mpDetails');
const loading = document.getElementById('loading');
const params = new URLSearchParams(window.location.search);

Functions.setupHeaderFooterStyleTitleSearch(mainContent);
////////////////////////////////////////////

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
        <a href="../MP_data/${filename}/${mpVersion}/MP.xml" download="${filename}.xml" class="download-link">
            Download MP XML
        </a>
    </div>`;

    sections.push(combinedHeader);

    if (description) {
        sections.push(`
        <div id="mpDetailsLine" class="detailsLine">
            <h3 title="The English (ENU) DisplayName of the MP. Fallback is the Name element in the MP Manifest." style="margin: 0;">${displayName}</h3>
            <p title="The English (ENU) Description of the MP." style="margin: 0;">${description}</p>
        </div>
    `);
    } else {
        sections.push(`
        <div id="mpDetailsLine" class="detailsLine">
            <h3 title="The English (ENU) Name of the MP. Fallback is the Name element in the MP Manifest." style="margin: 0;">${displayName}</h3>
        </div>
    `);
    }

    const sectionTitles = []; // Track titles of sections that are successfully added
    const sectionGroups = {}; // Object to group sections by category
    const addSection = async (tagName, title, type) => {
        const section = await parseSection(xmlDoc, tagName, title, type); // Await the result of parseSection
        if (section) {
            sections.push(section);
            sectionTitles.push(title); // Track the title of the successfully added section

            // Dynamically group sections by their tagName prefix
            const category = tagName.split(' ')[0]; // Extract the first part of the tagName
            if (!sectionGroups[category]) {
                sectionGroups[category] = [];
            }
            sectionGroups[category].push({ id: title.toLowerCase(), title });
        }
    };

    //ManagementPack Schema v2.0  https://learn.microsoft.com/en-us/system-center/scsm/work-mps-xml?#changes-to-the-system-center-common-schema
    await addSection('TypeDefinitions EntityTypes ClassTypes ClassType', 'ClassTypes', 'ClassType');
    await addSection('TypeDefinitions EntityTypes RelationshipTypes RelationshipType', 'RelationshipTypes', 'RelationshipType');
    await addSection('TypeDefinitions EnumerationTypes EnumerationValue', 'EnumerationTypes', 'EnumerationValue');
    await addSection('TypeDefinitions TypeProjections TypeProjection', 'TypeProjections', 'TypeProjection');
    await addSection('TypeDefinitions DataTypes DataType', 'DataTypes', 'DataType');
    await addSection('TypeDefinitions SchemaTypes SchemaType', 'SchemaTypes', 'SchemaType');
    await addSection('TypeDefinitions SecureReferences SecureReference', 'SecureReferences', 'SecureReference');
    await addSection('TypeDefinitions ModuleTypes DataSourceModuleType', 'DataSourceModuleTypes', 'DataSourceModuleType');
    await addSection('TypeDefinitions ModuleTypes ProbeActionModuleType', 'ProbeActionModuleTypes', 'ProbeActionModuleType');
    await addSection('TypeDefinitions ModuleTypes ConditionDetectionModuleType', 'ConditionDetectionModuleTypes', 'ConditionDetectionModuleType');
    await addSection('TypeDefinitions ModuleTypes WriteActionModuleType', 'WriteActionModuleTypes', 'WriteActionModuleType');
    await addSection('TypeDefinitions MonitorTypes UnitMonitorType', 'UnitMonitorTypes', 'UnitMonitorType');
    //await addSection('TypeDefinitions Extensions', 'Extensions?', 'Extension?');  //todo ?

    await addSection('Categories Category', 'Categories', 'Category');

    await addSection('Monitoring Discoveries Discovery', 'Discoveries', 'Discovery');
    await addSection('Monitoring Rules Rule', 'Rules', 'Rule');
    await addSection('Monitoring Tasks Rule', 'Tasks', 'Task');
    await addSection('Monitoring Monitors AggregateMonitor', 'AggregateMonitors', 'AggregateMonitor');
    await addSection('Monitoring Monitors UnitMonitor', 'UnitMonitors', 'UnitMonitor');
    await addSection('Monitoring Monitors DependencyMonitor', 'DependencyMonitors', 'DependencyMonitor');
    await addSection('Monitoring Diagnostics Diagnostic', 'Diagnostics', 'Diagnostic');
    await addSection('Monitoring Recoveries Diagnostic', 'Recoveries', 'Recovery');
    await addSection('Monitoring Overrides CategoryOverride', 'CategoryOverrides', 'CategoryOverride');
    await addSection('Monitoring Overrides MonitoringOverride', 'MonitoringOverrides', 'MonitoringOverride');
    await addSection('Monitoring Overrides RuleConfigurationOverride', 'RuleConfigurationOverrides', 'RuleConfigurationOverride');
    await addSection('Monitoring Overrides RulePropertyOverride', 'RulePropertyOverrides', 'RulePropertyOverride');
    await addSection('Monitoring Overrides MonitorConfigurationOverride', 'MonitorConfigurationOverrides', 'MonitorConfigurationOverride');
    await addSection('Monitoring Overrides MonitorPropertyOverride', 'MonitorPropertyOverrides', 'MonitorPropertyOverride');
    await addSection('Monitoring Overrides DiagnosticConfigurationOverride', 'DiagnosticConfigurationOverrides', 'DiagnosticConfigurationOverride');
    await addSection('Monitoring Overrides DiagnosticPropertyOverride', 'DiagnosticPropertyOverrides', 'DiagnosticPropertyOverride');
    await addSection('Monitoring Overrides RecoveryConfigurationOverride', 'RecoveryConfigurationOverrides', 'RecoveryConfigurationOverride');
    await addSection('Monitoring Overrides RecoveryPropertyOverride', 'RecoveryPropertyOverrides', 'RecoveryPropertyOverride');
    await addSection('Monitoring Overrides DiscoveryConfigurationOverride', 'DiscoveryConfigurationOverrides', 'DiscoveryConfigurationOverride');
    await addSection('Monitoring Overrides DiscoveryPropertyOverride', 'DiscoveryPropertyOverrides', 'DiscoveryPropertyOverride');
    await addSection('Monitoring Overrides SecureReferenceOverride', 'SecureReferenceOverrides', 'SecureReferenceOverride');
    await addSection('Monitoring ServiceLevelObjectives MonitorSLO', 'MonitorSLOs', 'MonitorSLO');
    await addSection('Monitoring ServiceLevelObjectives PerformanceCounterSLO', 'PerformanceCounterSLOs', 'PerformanceCounterSLO');
    //await addSection('Monitoring Extensions', 'Extensions?', 'Extension?');  //todo ?

    await addSection('ConfigurationGroups ConfigurationGroup', 'ConfigurationGroups', 'ConfigurationGroup');

    await addSection('Templates Template', 'Templates', 'Template');
    await addSection('Templates ObjectTemplate', 'ObjectTemplates', 'ObjectTemplate');

    await addSection('PresentationTypes ViewTypes ViewType', 'ViewTypes', 'ViewType');
    await addSection('PresentationTypes UIPages UIPage', 'UIPages', 'UIPage');
    await addSection('PresentationTypes UIPageSets UIPageSet', 'UIPageSets', 'UIPageSet');
    //await addSection('PresentationTypes Extensions', 'Extensions?', 'Extension?');  //todo ?

    await addSection('Presentation Forms Form', 'Forms', 'Form');
    await addSection('Presentation ConsoleTasks ConsoleTask', 'ConsoleTasks', 'ConsoleTask');
    await addSection('Presentation Views View', 'Views', 'View');
    await addSection('Presentation Folders Folder', 'Folders', 'Folder');
    await addSection('Presentation FolderItems FolderItem', 'FolderItems', 'FolderItem');
    await addSection('Presentation ImageReferences ImageReference', 'ImageReferences', 'ImageReference');
    await addSection('Presentation StringResources StringResource', 'StringResources', 'StringResource');
    await addSection('Presentation ComponentTypes ComponentType', 'ComponentTypes', 'ComponentType');
    await addSection('Presentation ComponentReferences ComponentReference', 'ComponentReferences', 'ComponentReference');
    await addSection('Presentation ComponentOverrides ComponentOverride', 'ComponentOverrides', 'ComponentOverride');
    await addSection('Presentation ComponentImplementations ComponentImplementation', 'ComponentImplementations', 'ComponentImplementation');
    await addSection('Presentation ComponentBehaviors ComponentBehavior', 'ComponentBehaviors', 'ComponentBehavior');
    await addSection('Presentation BehaviorTypes BehaviorType', 'BehaviorTypes', 'BehaviorType');
    await addSection('Presentation BehaviorImplementations BehaviorImplementation', 'BehaviorImplementations', 'BehaviorImplementationComponentType');
    //await addSection('Presentation Extensions', 'Extensions?', 'Extension?');  //todo ?

    await addSection('Warehouse Outriggers Outrigger', 'Outriggers', 'Outrigger');
    await addSection('Warehouse Dimensions Dimension', 'Dimensions', 'Dimension');
    await addSection('Warehouse Measures Measure', 'Measures', 'Measure');
    await addSection('Warehouse Facts Fact', 'Facts', 'Fact');
    await addSection('Warehouse Facts RelationshipFact', 'RelationshipFacts', 'RelationshipFact');
    await addSection('Warehouse WarehouseModules WarehouseModule', 'WarehouseModules', 'WarehouseModule');
    //await addSection('Warehouse Extensions', 'Extensions?', 'Extension?');  //todo ?

    await addSection('Reporting DataWarehouseScripts DataWarehouseScript', 'DataWarehouseScripts', 'DataWarehouseScript');
    await addSection('Reporting DataWarehouseDataSets DataWarehouseDataSet', 'DataWarehouseDataSets', 'DataWarehouseDataSet');
    await addSection('Reporting Reports Report', 'Reports', 'Report');
    await addSection('Reporting LinkedReports LinkedReport', 'LinkedReports', 'LinkedReport');
    await addSection('Reporting ReportParameterControls ReportParameterControl', 'ReportParameterControls', 'ReportParameterControl');
    //await addSection('Reporting Extensions', 'Extensions?', 'Extension?');  //todo ?

    await addSection('LanguagePacks LanguagePack', 'LanguagePacks', 'LanguagePack'); // todo: ???

    await addSection('Resources Resource', 'Resources', 'Resource');
    await addSection('Resources Assembly', 'Assemblies', 'Assembly');
    await addSection('Resources ReportResource', 'ReportResources', 'ReportResource');
    await addSection('Resources Image', 'Images', 'Image');
    await addSection('Resources DeployableResource', 'DeployableResources', 'DeployableResource');
    await addSection('Resources DeployableAssembly', 'DeployableAssemblies', 'DeployableAssembly');

    // addSection('Extensions ?', 'Extensions?', 'Extension?'); //todo: e.g. ServiceOffering, RequestOffering ...

    // Flatten and sort sections alphabetically by title
    const sortedSections = Object.values(sectionGroups)
        .flat() // Flatten the grouped sections into a single array
        .sort((a, b) => a.title.localeCompare(b.title)); // Sort alphabetically by title

    // Generate a flat, sorted list for navigation
    const tableLinks = `
<nav>
    <ul class="sorted-list">
        ${sortedSections
            .map(
                (section) =>
                    `<li><a href="#${section.id}">${section.title}</a></li>`
            )
            .join('')}
    </ul>
</nav>
`;

    // Insert the navigation after mpDetailsLine
    const mpDetailsLineIndex = sections.findIndex((section) =>
        section.includes('id="mpDetailsLine"')
    );
    sections.splice(mpDetailsLineIndex + 1, 0, tableLinks);


    mainContent.innerHTML = sections.join('');

    // Add event listener for version change
    const versionSelectElement = document.getElementById('versionSelect');
    if (versionSelectElement) {
        versionSelectElement.addEventListener('change', (event) => {
            const selectedVersion = event.target.value;

            // Update the URL with the new version parameter
            const urlParams = new URLSearchParams(window.location.search);
            urlParams.set('version', selectedVersion);

            // Refresh the page with the updated URL
            window.location.search = urlParams.toString();
        });
    }

    // Add a floating "Back to Top" button
    const backToTopButton = document.createElement('button');
    backToTopButton.id = 'backToTop';
    backToTopButton.title = 'Back to Top';
    //backToTopButton.innerHTML = `<img src="../images/up-arrow.png" alt="Back to Top" style="width: 30px; height: 30px;">`;
    backToTopButton.innerHTML = `⬆`; // Unicode up arrow
    backToTopButton.style.fontSize = '30px'; // Adjust size

    document.body.appendChild(backToTopButton);

    // Add scroll event listener to show/hide the button
    window.addEventListener('scroll', () => {
        if (window.scrollY > 200) {
            backToTopButton.style.display = 'block';
        } else {
            backToTopButton.style.display = 'none';
        }
    });

    // Add click event listener to scroll to the top
    backToTopButton.addEventListener('click', () => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    });

    // Focus on the filter box when the page loads
    const filterBox = document.getElementById('filterByText');
    if (filterBox) {
        filterBox.focus();
    }

}

/// Function to parse sections of the XML and generate HTML
/// This function takes the XML document, the tag name to search for, the title for the section, and the type of element to be passed to element.html
async function parseSection(xmlDoc, tagName, title, type) {
    const nodes = xmlDoc.querySelectorAll(tagName);
    if (nodes.length === 0) return '';

    // Generate a unique id for the table based on the title
    const tableId = Functions.generateElementId(title);

    // Create table headers dynamically based on the attributes
    let html = `<table id="${tableId}" class="table-section">
           <caption>
               ${title} (${nodes.length})
           </caption>
           <thead><tr>`;
    const allAttributes = new Set();
    nodes.forEach(node => {
        Array.from(node.attributes).forEach(attr => {
            allAttributes.add(attr.name);
        });
    });

    const attributeList = ['ID', 'DisplayName', ...Array.from(allAttributes).filter(attr => attr !== 'ID'), 'Description'];
    attributeList.forEach(attr => {
        if (attr === 'ID') {
            html += `<th class="id-column">${attr}</th>`;
        }
        else if (attr === 'Description') {
            html += `<th class="description-column">${attr}</th>`;
        } else {
            html += `<th>${attr}</th>`;
        }
    });
    html += `</tr></thead><tbody>`;

    // Populate table rows with attribute values

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

    const mpRefs = xmlDoc.evaluate(
        `/ManagementPack/Manifest/References`,
        xmlDoc,
        null,
        XPathResult.FIRST_ORDERED_NODE_TYPE,
        null
    ).singleNodeValue;

    // Process rows asynchronously
    const rows = await Promise.all(
        Array.from(nodes).map(async (node) => {
            let rowHtml = `<tr>`;
            const idValue = node.getAttribute('ID') || '';
            let displayName = '';
            let description = '';

            if (idValue && displayStringsBase) {
                const displayNode = displayStringsBase.querySelector(`DisplayString[ElementID="${idValue}"]`);
                if (displayNode) {
                    displayName = displayNode.querySelector('Name')?.textContent || '';
                    description = displayNode.querySelector('Description')?.textContent || '';
                }
            }

            rowHtml += `<td class="id-column"><a href="element.html?file=${file}&version=${mpVersion}&type=${type}&id=${idValue}">${idValue}</a></td>`;
            rowHtml += `<td>${displayName}</td>`;

            for (const attr of Array.from(allAttributes).filter(attr => attr !== 'ID')) {
                const value = node.getAttribute(attr) || '';
                const isRefElem = await Functions.getTargetElementType(type, attr) != ''
                if (isRefElem) {
                    let referencedFile = file;
                    let referencedVersion = mpVersion;
                    const targetElementType = await Functions.getTargetElementType(type, attr);
                    let referencedElementId = value;

                    if (mpRefs && value.includes('!')) {
                        const [alias, elementName] = value.split('!');
                        const referenceNode = mpRefs.querySelector(`Reference[Alias="${alias}"]`);

                        if (referenceNode) {
                            
                            referencedFile = referenceNode.querySelector("ID").textContent;
                            referencedVersion = referenceNode.querySelector("Version").textContent;
                            referencedElementId = elementName;
                            //rowHtml += `<td><a target="_blank" href="element.html?file=${referenceNode.querySelector("ID").textContent}&version=${referenceNode.querySelector("Version").textContent}&type=${targetElementType}&id=${elementName}">${elementName}</a></td>`;
                        }
                    }
                    rowHtml += `<td><a target="_blank" href="element.html?file=${referencedFile}&version=${referencedVersion}&type=${targetElementType}&id=${referencedElementId}">${referencedElementId}</a></td>`;
                } else {
                    rowHtml += `<td>${value}</td>`;
                }
            }

            rowHtml += `<td class="description-column">${description}</td>`;
            rowHtml += `</tr>`;
            return rowHtml;
        })
    );
    // Append all rows to the table
    html += rows.join('');

    html += `</tbody></table>`;
    return html; // Removed the "Back to Top" button
}



document.addEventListener('DOMContentLoaded', () => {
    const waitForNav = setInterval(() => {
        const navLinks = document.querySelectorAll('nav ul li a');
        const tableSections = document.querySelectorAll('.table-section');

        if (navLinks.length > 0 && tableSections.length > 0) {
            clearInterval(waitForNav); // Stop checking once nav items and table sections are found

            // Define start and end colors for the gradient
            const startColor = [255, 193, 161]; // RGB for #FFC1A1 (Softer peach tone)
            const endColor = [51, 255, 87]; // RGB for #33FF57

            // Generate gradient colors
            const gradientColors = generateGradientColors(startColor, endColor, navLinks.length);

            navLinks.forEach((link, index) => {
                const gradientColor = gradientColors[index];

                // Convert RGB to hex
                const hexColor = rgbToHex(gradientColor[0], gradientColor[1], gradientColor[2]);

                // Apply solid background color to the navigation item
                link.style.setProperty('background-color', hexColor, 'important');

                // Calculate brightness to determine appropriate text color
                const brightness = (gradientColor[0] * 299 + gradientColor[1] * 587 + gradientColor[2] * 114) / 1000;

                // Apply text color to the navigation item
                const textColor = brightness > 125 ? '#000000' : '#ffffff';
                link.style.setProperty('color', textColor, 'important');

                // Find the table section by id (from the href of the link)
                const href = link.getAttribute('href');
                if (href && href.startsWith('#')) {
                    const tableId = href.substring(1);
                    const table = document.getElementById(tableId);
                    const caption = table?.querySelector('caption');
                    if (caption) {
                        caption.style.setProperty('background', `linear-gradient(to right, ${hexColor}, #ffffff)`, 'important');
                        caption.style.setProperty('color', textColor, 'important');
                    }
                }

            });
        }
    }, 100); // Check every 100ms
});

// Helper function to generate gradient colors
function generateGradientColors(startColor, endColor, steps) {
    const colors = [];
    for (let i = 0; i < steps; i++) {
        const r = Math.round(startColor[0] + ((endColor[0] - startColor[0]) * i) / (steps - 1));
        const g = Math.round(startColor[1] + ((endColor[1] - startColor[1]) * i) / (steps - 1));
        const b = Math.round(startColor[2] + ((endColor[2] - startColor[2]) * i) / (steps - 1));
        colors.push([r, g, b]);
    }
    return colors;
}

// Helper function to convert RGB to hex
function rgbToHex(r, g, b) {
    return `#${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1).toUpperCase()}`;
}

