import * as Functions from './functions.js';

const mainContent = document.getElementById('mpList');
const loading = document.getElementById('loading');

async function fetchMPs() {
    try {
        // Use loadXMLfile to load the XML file
        const xmlDoc = await Functions.loadXMLfile('List_MP.xml');

        const links = Array.from(xmlDoc.getElementsByTagName("ManagementPack"))
            .map(a => a.getAttribute('ID') + '|' + a.getAttribute('LatestVersion') + '|' + a.getAttribute('Name') + '|' + a.getAttribute('Description'));

        displayMPs(links);
    } catch (error) {
        console.error('Failed to load MPs:', error);
        loading.textContent = 'Failed to load Management Packs.';
    }
}

function displayMPs(mps) {
    loading.style.display = 'none';
    mainContent.innerHTML = '';

    const table = document.createElement('table');
    table.border = '1'; // Add a border for visibility
    table.style.width = "auto";
    mainContent.appendChild(table);

    // Add a header row
    const thead = document.createElement('thead');
    table.appendChild(thead);
    const headerRow = document.createElement('tr');
    thead.appendChild(headerRow);
    const headers = ['ID', 'Last Version', 'DisplayName (ENU) or Manifest/Name', 'Description (ENU)'];
    headers.forEach(headerText => {
        const th = document.createElement('th');
        th.textContent = headerText;
        headerRow.appendChild(th);
    });

    const tbody = document.createElement('tbody');
    table.appendChild(tbody);

    mps.forEach(mp => {
        const row = tbody.insertRow();

        const mpID = mp.split('|')[0];
        const mpLatestVersion = mp.split('|')[1];
        const mpName = mp.split('|')[2];
        const mpDescription = mp.split('|')[3];

        let cell = row.insertCell();
        const link = document.createElement('a');
        link.href = `mp.html?file=${encodeURIComponent(mpID)}&version=${mpLatestVersion}`;
        link.textContent = mpID;
        cell.appendChild(link);

        cell = row.insertCell();
        cell.textContent = mpLatestVersion;
        cell.style.textAlign = "right";

        cell = row.insertCell();
        cell.textContent = mpName;

        cell = row.insertCell();
        cell.textContent = mpDescription;
    });

    const filterBox = document.getElementById('filterByText');
    if (filterBox) {
        filterBox.focus();
    }

    // Add a floating "Back to Top" button
    const backToTopButton = document.createElement('button');
    backToTopButton.id = 'backToTop';
    backToTopButton.title = 'Back to Top';
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

fetchMPs();

Functions.setupHeaderFooterStyleTitleSearch(mainContent);