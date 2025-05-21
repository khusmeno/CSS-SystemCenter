# MP Buddy
Web site to help SCEM support engineers in troubleshooting SCOM and SCSM cases. Easily find and navigate inside Management Packs.

Just open https://aka.ms/MP-Buddy to start using it.
## Table of Contents
- [How to add missing Management Packs or newer versions?](#how-to-add-missing-management-packs-or-newer-versions)
- [How to add missing links to other elements?](#how-to-add-missing-links-to-other-elements)


## How to add missing Management Packs or newer versions?
### Prerequisites:
- You need to have a GitHub account. [Sign up](https://github.com/) if you don't have one.  
- Download and install [Git for Windows](https://git-scm.com/downloads/win) 

### Step-by-step guide:
- Create a [`Fork`](https://github.com/microsoft/CSS-SystemCenter/fork) from Microsoft's official CSS-SystemCenter repository. (Skip if already done)
- `Clone` your forked repository. (Skip if already done) For more details, see [GitHub documentation](https://docs.github.com/en/get-started/git-basics/about-remote-repositories#cloning-with-https-urls).
	- Open a Command Prompt window.
	- Navigate to the folder where you want to clone the repository.
	- Replace _YourUserName_ and run: `git clone https://github.com/YourGitHubUserName/CSS-SystemCenter.git`
	- Navigate to the cloned folder: `cd CSS-SystemCenter`  
<br/>

- Create a `staging` folder inside the `docs\mp-buddy` folder
- Put your _new_ Management Pack(s) into the `staging` folder with XML, MP or MPB extensions. The name of the file does not matter. Subfolders are supported. 
You may delete existing files if previously built and pushed.

- _Run_ the `build.ps1` script which is located in the `docs\mp-buddy\build` folder
	- or open a PowerShell window, navigate to the `docs\mp-buddy\build` folder and run `build.ps1` script
- _Push_ your changes to GitHub:  ```git add . && git commit -m "new MPs" && git push```
	- You need to pass GitHub authentication. If you have 2FA enabled, you need to use a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) instead of your password.
- Create a _Pull Request_ (PR) from your forked repository to the original Microsoft repository.  
	- Replace _YourUserName_ and go to your forked repository on GitHub: https://github.com/YourGitHubUserName/CSS-SystemCenter
	- Click on the `Pull requests` tab.
	- Click on the `New pull request` button.
	- Compare the changes with the `main` branch of the original Microsoft repository.
	- Click on `Create pull request`.
	- Add a title and description for your PR, then click on `Create pull request`.
- Wait for the PR to be reviewed and merged by Microsoft. You will be notified via email when the PR is merged.
- After the PR is merged, the changes will be automatically deployed to the [MP Buddy](https://aka.ms/MP-Budd) website. You can check the website to see if your changes are live.
	- If still not there, check if the GitHub Action `pages-build-deployment` is still running at https://github.com/microsoft/CSS-SystemCenter/actions

## How to add missing links to other elements?
You may see something like the below instead of a link:

![Missing link](https://raw.githubusercontent.com/microsoft/CSS-SystemCenter/main/docs/mp-buddy/images/MP-Buddy-MissingLink.png)

To fix this please submit a [GitHub Issue](https://github.com/microsoft/CSS-SystemCenter/issues).

If you want to fix by yourself, you need to add a line to the `assets/MpElementReferences.xml` file.

- [Fork/Clone](#how-to-add-missing-management-packs-or-newer-versions) the repository.
- Navigate to the `docs/mp-buddy/src/assets` folder.
- Open the `MpElementReferences.xml` file in a text editor and add a new line with the following format and correct values.
	- If you don't know the exact value for the TaegetType attribute, set it to `Element` and it will be automatically detected.
```xml
<MpElementReference SourceType="AggregateMonitor" SourceProperty="Target" TargetType="Element" />
```

