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
        <div id="mpDetailsLine">
            <h3 title="The English (ENU) Name of the MP. Fallback is the Name element in the MP Manifest." style="margin: 0;">${displayName}</h3>
            <p title="The English (ENU) Description of the MP." style="margin: 0;">${description}</p>
        </div>
    `);
    } else {
        sections.push(`
        <div id="mpDetailsLine">
            <h3 title="The English (ENU) Name of the MP. Fallback is the Name element in the MP Manifest." style="margin: 0;">${displayName}</h3>
        </div>
    `);
    }

    const sectionTitles = []; // Track titles of sections that are successfully added
    // Add all parseSection calls and track successful sections
    const addSection = (tagName, title, type) => {
        const section = parseSection(xmlDoc, tagName, title, type);
        if (section) {
            sections.push(section);
            sectionTitles.push(title); // Track the title of the successfully added section
        }
    };
    //ManagementPack Schema v2.0  https://learn.microsoft.com/en-us/system-center/scsm/work-mps-xml?#changes-to-the-system-center-common-schema
    addSection('TypeDefinitions EntityTypes ClassTypes ClassType', 'ClassTypes', 'ClassType');
    addSection('TypeDefinitions EntityTypes RelationshipTypes RelationshipType', 'RelationshipTypes', 'RelationshipType');
    addSection('TypeDefinitions EnumerationTypes EnumerationValue', 'EnumerationTypes', 'EnumerationValue');
    addSection('TypeDefinitions TypeProjections TypeProjection', 'TypeProjections', 'TypeProjection');
    addSection('TypeDefinitions DataTypes DataType', 'DataTypes', 'DataType');
    addSection('TypeDefinitions SchemaTypes SchemaType', 'SchemaTypes', 'SchemaType');
    addSection('TypeDefinitions SecureReferences SecureReference', 'SecureReferences', 'SecureReference');
    addSection('TypeDefinitions ModuleTypes DataSourceModuleType', 'DataSourceModuleTypes', 'DataSourceModuleType');
    addSection('TypeDefinitions ModuleTypes ProbeActionModuleType', 'ProbeActionModuleTypes', 'ProbeActionModuleType');
    addSection('TypeDefinitions ModuleTypes ConditionDetectionModuleType', 'ConditionDetectionModuleTypes', 'ConditionDetectionModuleType');
    addSection('TypeDefinitions ModuleTypes WriteActionModuleType', 'WriteActionModuleTypes', 'WriteActionModuleType');
    addSection('TypeDefinitions MonitorTypes UnitMonitorType', 'UnitMonitorTypes', 'UnitMonitorType');
    //addSection('TypeDefinitions Extensions', 'Extensions?', 'Extension?');  //todo ?

    addSection('Categories Category', 'Categories', 'Category');

    addSection('Monitoring Discoveries Discovery', 'Discoveries', 'Discovery');
    addSection('Monitoring Rules Rule', 'Rules', 'Rule');
    addSection('Monitoring Tasks Rule', 'Tasks', 'Task');
    addSection('Monitoring Monitors AggregateMonitor', 'AggregateMonitors', 'AggregateMonitor');
    addSection('Monitoring Monitors UnitMonitor', 'UnitMonitors', 'UnitMonitor');
    addSection('Monitoring Monitors DependencyMonitor', 'DependencyMonitors', 'DependencyMonitor');
    addSection('Monitoring Diagnostics Diagnostic', 'Diagnostics', 'Diagnostic');
    addSection('Monitoring Recoveries Diagnostic', 'Recoveries', 'Recovery');
    addSection('Monitoring Overrides CategoryOverride', 'CategoryOverrides', 'CategoryOverride');
    addSection('Monitoring Overrides MonitoringOverride', 'MonitoringOverrides', 'MonitoringOverride');
    addSection('Monitoring Overrides RuleConfigurationOverride', 'RuleConfigurationOverrides', 'RuleConfigurationOverride');
    addSection('Monitoring Overrides RulePropertyOverride', 'RulePropertyOverrides', 'RulePropertyOverride');
    addSection('Monitoring Overrides MonitorConfigurationOverride', 'MonitorConfigurationOverrides', 'MonitorConfigurationOverride');
    addSection('Monitoring Overrides MonitorPropertyOverride', 'MonitorPropertyOverrides', 'MonitorPropertyOverride');
    addSection('Monitoring Overrides DiagnosticConfigurationOverride', 'DiagnosticConfigurationOverrides', 'DiagnosticConfigurationOverride');
    addSection('Monitoring Overrides DiagnosticPropertyOverride', 'DiagnosticPropertyOverrides', 'DiagnosticPropertyOverride');
    addSection('Monitoring Overrides RecoveryConfigurationOverride', 'RecoveryConfigurationOverrides', 'RecoveryConfigurationOverride');
    addSection('Monitoring Overrides RecoveryPropertyOverride', 'RecoveryPropertyOverrides', 'RecoveryPropertyOverride');
    addSection('Monitoring Overrides DiscoveryConfigurationOverride', 'DiscoveryConfigurationOverrides', 'DiscoveryConfigurationOverride');
    addSection('Monitoring Overrides DiscoveryPropertyOverride', 'DiscoveryPropertyOverrides', 'DiscoveryPropertyOverride');
    addSection('Monitoring Overrides SecureReferenceOverride', 'SecureReferenceOverrides', 'SecureReferenceOverride');
    addSection('Monitoring ServiceLevelObjectives MonitorSLO', 'MonitorSLOs', 'MonitorSLO');
    addSection('Monitoring ServiceLevelObjectives PerformanceCounterSLO', 'PerformanceCounterSLOs', 'PerformanceCounterSLO');
    //addSection('Monitoring Extensions', 'Extensions?', 'Extension?');  //todo ?

    addSection('ConfigurationGroups ConfigurationGroup', 'ConfigurationGroups', 'ConfigurationGroup');

    addSection('Templates Template', 'Templates', 'Template');
    addSection('Templates ObjectTemplate', 'ObjectTemplates', 'ObjectTemplate');

    addSection('PresentationTypes ViewTypes ViewType', 'ViewTypes', 'ViewType');
    addSection('PresentationTypes UIPages UIPage', 'UIPages', 'UIPage');
    addSection('PresentationTypes UIPageSets UIPageSet', 'UIPageSets', 'UIPageSet');
    //addSection('PresentationTypes Extensions', 'Extensions?', 'Extension?');  //todo ?

    addSection('Presentation Forms Form', 'Forms', 'Form');
    addSection('Presentation ConsoleTasks ConsoleTask', 'ConsoleTasks', 'ConsoleTask');
    addSection('Presentation Views View', 'Views', 'View');
    addSection('Presentation Folders Folder', 'Folders', 'Folder');
    addSection('Presentation FolderItems FolderItem', 'FolderItems', 'FolderItem');
    addSection('Presentation ImageReferences ImageReference', 'ImageReferences', 'ImageReference');
    addSection('Presentation StringResources StringResource', 'StringResources', 'StringResource');
    addSection('Presentation ComponentTypes ComponentType', 'ComponentTypes', 'ComponentType');
    addSection('Presentation ComponentReferences ComponentReference', 'ComponentReferences', 'ComponentReference');
    addSection('Presentation ComponentOverrides ComponentOverride', 'ComponentOverrides', 'ComponentOverride');
    addSection('Presentation ComponentImplementations ComponentImplementation', 'ComponentImplementations', 'ComponentImplementation');
    addSection('Presentation ComponentBehaviors ComponentBehavior', 'ComponentBehaviors', 'ComponentBehavior');
    addSection('Presentation BehaviorTypes BehaviorType', 'BehaviorTypes', 'BehaviorType');
    addSection('Presentation BehaviorImplementations BehaviorImplementation', 'BehaviorImplementations', 'BehaviorImplementationComponentType');
    //addSection('Presentation Extensions', 'Extensions?', 'Extension?');  //todo ?

    addSection('Warehouse Outriggers Outrigger', 'Outriggers', 'Outrigger');
    addSection('Warehouse Dimensions Dimension', 'Dimensions', 'Dimension');
    addSection('Warehouse Measures Measure', 'Measures', 'Measure');
    addSection('Warehouse Facts Fact', 'Facts', 'Fact');
    addSection('Warehouse Facts RelationshipFact', 'RelationshipFacts', 'RelationshipFact');
    addSection('Warehouse WarehouseModules WarehouseModule', 'WarehouseModules', 'WarehouseModule');
    //addSection('Warehouse Extensions', 'Extensions?', 'Extension?');  //todo ?

    addSection('Reporting DataWarehouseScripts DataWarehouseScript', 'DataWarehouseScripts', 'DataWarehouseScript');
    addSection('Reporting DataWarehouseDataSets DataWarehouseDataSet', 'DataWarehouseDataSets', 'DataWarehouseDataSet');
    addSection('Reporting Reports Report', 'Reports', 'Report');
    addSection('Reporting LinkedReports LinkedReport', 'LinkedReports', 'LinkedReport');
    addSection('Reporting ReportParameterControls ReportParameterControl', 'ReportParameterControls', 'ReportParameterControl');
    //addSection('Reporting Extensions', 'Extensions?', 'Extension?');  //todo ?

    addSection('LanguagePacks LanguagePack', 'LanguagePacks', 'LanguagePack'); // todo: ???

    addSection('Resources Resource', 'Resources', 'Resource');
    addSection('Resources Assembly', 'Assemblies', 'Assembly');
    addSection('Resources ReportResource', 'ReportResources', 'ReportResource');
    addSection('Resources Image', 'Images', 'Image');
    addSection('Resources DeployableResource', 'DeployableResources', 'DeployableResource');
    addSection('Resources DeployableAssembly', 'DeployableAssemblies', 'DeployableAssembly');

    // addSection('Extensions ?', 'Extensions?', 'Extension?'); //todo: e.g. ServiceOffering, RequestOffering ...

    // Dynamically generate navigation based on sections that exist
    const tableLinks = `
    <nav>
        <ul>
            ${sectionTitles.map(title => `<li><a href="#${title.toLowerCase()}">${title}</a></li>`).join('')}
        </ul>
    </nav>
    `;

    // Insert the navigation after mpDetailsLine
    const mpDetailsLineIndex = sections.findIndex(section => section.includes('id="mpDetailsLine"'));
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

}

/// Function to parse sections of the XML and generate HTML
/// This function takes the XML document, the tag name to search for, the title for the section, and the type of element to be passed to element.html
function parseSection(xmlDoc, tagName, title, type) {
    const nodes = xmlDoc.querySelectorAll(tagName);
    if (nodes.length === 0) return '';

    // Generate a unique id for the table based on the title
    const tableId = title.replace(/\s+/g, '-').toLowerCase(); // Replace spaces with dashes and convert to lowercase

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

    const attributeList = ['ID', 'DisplayName', 'Description', ...Array.from(allAttributes).filter(attr => attr !== 'ID')];
    attributeList.forEach(attr => {
        html += `<th>${attr}</th>`;
    });
    html += `</tr></thead><tbody>`;

    // Populate table rows with attribute values
    nodes.forEach(node => {
        html += `<tr>`;
        const idValue = node.getAttribute('ID') || '';
        let displayName = '';
        let description = '';

        if (idValue) {
            let displayNode = xmlDoc.evaluate(
                `/ManagementPack/LanguagePacks/LanguagePack[@ID='ENU']/DisplayStrings/DisplayString[@ElementID='${idValue}']`,
                xmlDoc,
                null,
                XPathResult.FIRST_ORDERED_NODE_TYPE,
                null
            ).singleNodeValue;

            if (!displayNode) {
                displayNode = xmlDoc.evaluate(
                    `/ManagementPack/LanguagePacks/LanguagePack[@IsDefault='true']/DisplayStrings/DisplayString[@ElementID='${idValue}']`,
                    xmlDoc,
                    null,
                    XPathResult.FIRST_ORDERED_NODE_TYPE,
                    null
                ).singleNodeValue;
            }

            if (displayNode) {
                displayName = displayNode.querySelector('Name')?.textContent || '';
                description = displayNode.querySelector('Description')?.textContent || '';
            }
        }

        html += `<td><a href="element.html?file=${file}&version=${mpVersion}&type=${type}&id=${idValue}">${idValue}</a></td>`;
        html += `<td>${displayName}</td>`;
        html += `<td>${description}</td>`;

        Array.from(allAttributes)
            .filter(attr => attr !== 'ID')
            .forEach(attr => {
                const value = node.getAttribute(attr) || '';
                if (value.includes('!')) {
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
                        html += `<td>${value}</td>`;
                    }
                } else {
                    html += `<td>${value}</td>`;
                }
            });

        html += `</tr>`;
    });

    html += `</tbody></table>`;
    return html; // Removed the "Back to Top" button
}
