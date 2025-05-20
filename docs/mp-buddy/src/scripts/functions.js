const productNameInHeader = "MP Buddy";
const productNameInTitle = productNameInHeader; // Name of the product for the Title
const teamName = "Microsoft System Center Support team"; // Name of the team for the Footer
const teamSupportUrl = "https://microsoft.github.io/CSS-SystemCenter/"
const confidentialityText = "For internal use only";

// Function to load an XML file and return the parsed XML document
export function createHeader() {
    const header = document.createElement('header');
    header.innerHTML = `
        <div class="container">
            <a href="../index.html" style="text-decoration: none">
                <h1 title="Back to MP list">${productNameInHeader}</h1>
            </a>
            <input type="text" id="filterByText" placeholder="Filter on any text..." />
        </div>
    `;
    document.body.prepend(header); // Add the header at the top of the body
}

export function createFooter() {
    const footer = document.createElement('footer');
    footer.innerHTML = `
        <p><a href="${teamSupportUrl}" target="_blank">${teamName}</a></p>
    `;
    document.body.appendChild(footer); // Add the footer at the bottom of the body
}

export function createHeaderAndFooter() {
    createHeader();
    createFooter();
}

export async function loadXMLfile(relativePath) {
    const filePath = `../MP_data/${relativePath}`;
    try {
        const response = await fetch(filePath);

        // Check if the response status is OK (status code 200-299)
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status} - ${response.statusText}`);
        }

        // Read the response as a Uint8Array
        const buffer = await response.arrayBuffer();

        // Decode the buffer using the appropriate encoding
        const decoder = new TextDecoder("utf-16"); // Change "utf-8" to the desired encoding if needed
        const xmlText = decoder.decode(buffer);

        // Parse the XML text
        const parser = new DOMParser();
        return parser.parseFromString(xmlText, "application/xml");
    } catch (err) {
        console.error('Failed to load XML file:', err);
        throw new Error("Error loading XML file " + filePath);
    }
}


// Function to load a Management Pack (MP) using loadXMLfile
export async function loadMP(filename, mpVersion) {
    const relativePath = `${filename}/${mpVersion}/MP.xml`; // Construct relative path

    try {
        // Attempt to load the MP.xml file
        return await loadXMLfile(relativePath);
    } catch (err) {
        console.warn(`Failed to load ${relativePath}. Attempting to load List_MPVersion.xml...`);

        try {
            // Attempt to load List_MPVersion.xml
            const listXml = await loadXMLfile(`${filename}/List_MPVersion.xml`);

            // Parse the List_MPVersion.xml to find versions greater than mpVersion
            const mpVersions = Array.from(listXml.getElementsByTagName('MPVersion'));
            if (mpVersions.length === 0) {
                throw new Error("No MPVersion nodes found in List_MPVersion.xml.");
            }

            // Filter versions greater than mpVersion
            const validVersions = mpVersions.filter(node => {
                const version = node.getAttribute('Version');
                return compareVersions(version, mpVersion) > 0; // Keep only versions greater than mpVersion
            });

            if (validVersions.length === 0) {
                throw new Error(`No version equal or greater than ${mpVersion} found for MP '${filename}''`);
            }

            // Find the highest version among the valid versions
            const highestVersionNode = validVersions.reduce((maxNode, currentNode) => {
                const maxVersion = maxNode.getAttribute('Version');
                const currentVersion = currentNode.getAttribute('Version');

                if (compareVersions(currentVersion, maxVersion) > 0) {
                    return currentNode;
                }
                return maxNode;
            });

            const highestVersion = highestVersionNode.getAttribute('Version');
            console.info(`Highest version greater than ${mpVersion} found: ${highestVersion}`);

            // Attempt to load the MP.xml file for the highest version
            return await loadXMLfile(`${filename}/${highestVersion}/MP.xml`);
        } catch (fallbackErr) {
            console.error(`Failed to load List_MPVersion.xml or the highest version MP.xml:`, fallbackErr);
            throw fallbackErr; // Rethrow the error if fallback also fails
        }
    }
}

// Helper function to compare semantic version strings
function compareVersions(versionA, versionB) {
    const aParts = versionA.split('.').map(Number);
    const bParts = versionB.split('.').map(Number);

    for (let i = 0; i < Math.max(aParts.length, bParts.length); i++) {
        const a = aParts[i] || 0; // Default to 0 if part is missing
        const b = bParts[i] || 0; // Default to 0 if part is missing

        if (a > b) return 1;
        if (a < b) return -1;
    }
    return 0; // Versions are equal
}


export function setupSearchFilter(tableSelector) {
    const searchInput = document.getElementById("filterByText");
    searchInput.addEventListener('input', () => {
        const filter = searchInput.value.toLowerCase();
        const rows = document.querySelectorAll(`#${tableSelector.id} tbody tr`);
        for (let i = 0; i < rows.length; i++) {
            const cells = rows[i].getElementsByTagName("td");
            let match = false;

            for (let j = 0; j < cells.length; j++) {
                if (cells[j].textContent.toLowerCase().includes(filter)) {
                    match = true;
                    break;
                }
            }

            rows[i].style.display = match ? "" : "none";
        }
    });
}

export function loadDynamicScript(scriptUrl, onLoad) {
    try {
        const script = document.createElement('script');
        script.src = scriptUrl;
        script.type = 'text/javascript';
        script.onload = onLoad; // Call the provided callback when the script is loaded
        script.onerror = () => {
            console.warn(`Failed to load script: ${scriptUrl}`);
        };
        document.head.appendChild(script);
    } catch (err) {
        console.warn('Unexpected error while loading script:', err);
    }
}

export function loadCSS(href) {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = href;
    document.head.appendChild(link);
}

export function loadCommonCSS() {
    loadCSS('../styles/style.css');
}

export function setDocumentTitle() {
    document.title = productNameInTitle;
}

export function setupHeaderFooterStyleTitleSearch(mainContent) {
    createHeaderAndFooter();
    setupSearchFilter(mainContent);
    loadCommonCSS();
    setDocumentTitle();
}

export async function getAvailableMPVersions(filename) {
    try {
        const relativePath = `${filename}/List_MPVersion.xml`;
        return await loadXMLfile(relativePath);
    } catch (err) {
        console.error('Failed to load List_MPVersion.XML:', err);
        throw new Error("Error loading List_MPVersion.XML .");
    }
}


let cachedMpElementReferences = null; // Cache for the parsed XML document
export async function getTargetElementType(sourceType, sourceProperty) {
    try {
        // Acquire the lock before entering the critical section
        await targetElementTypeLock.acquire();

        // Check if the XML document is already cached
        if (!cachedMpElementReferences) {
            // Load and parse MpElementReferences.xml only once
            const response = await fetch('../assets/MpElementReferences.xml');
            const xmlText = await response.text();
            const parser = new DOMParser();
            cachedMpElementReferences = parser.parseFromString(xmlText, 'application/xml');
        }

        // Release the lock after the critical section
        targetElementTypeLock.release();

        // Find the matching element in the cached XML document
        const referenceNode = cachedMpElementReferences.querySelector(
            `MpElementReference[SourceType="${sourceType}"][SourceProperty="${sourceProperty}"]`
        );

        // Return the TargetType if found, otherwise return an empty string
        return referenceNode?.getAttribute('TargetType') || '';
    } catch (error) {
        // Ensure the lock is released even if an error occurs
        targetElementTypeLock.release();
        console.error('Error loading or parsing MpElementReferences.xml:', error);
        return '';
    }
}


/**
 * Converts a string into a valid element ID for linking purposes.
 * @param {string} input - The string to convert.
 * @returns {string} - A valid element ID.
 */
export function generateElementId(input) {
    return input
        .trim() // Remove leading and trailing whitespace
        .replace(/\s+/g, '-') // Replace spaces with dashes
        .replace(/\./g, '-') // Replace dots with dashes
        .replace(/[^a-zA-Z0-9-_]/g, '') // Remove invalid characters
        .toLowerCase(); // Convert to lowercase
}


class AsyncLock {
    constructor() {
        this._locked = false;
        this._waiting = [];
    }

    async acquire() {
        while (this._locked) {
            await new Promise(resolve => this._waiting.push(resolve));
        }
        this._locked = true;
    }

    release() {
        this._locked = false;
        if (this._waiting.length > 0) {
            const resolve = this._waiting.shift();
            resolve();
        }
    }
}
const targetElementTypeLock = new AsyncLock();