> [!WARNING]
> Allxon Artifact Toolkit will be retired from our GitHub repository on **August 30th, 2024**. We recommend transitioning to the new Allxon Artifact Toolkit in **Allxon CLI**, supported by **Allxon Agent 3.11.2 or newer**, to enhance your experience in creating OTA artifacts.
For detailed instructions on the transition, please visit [Allxon Resource Center](https://www.allxon.com/knowledge/generate-allxon-ota-artifact-linux).
Thank you for your understanding and continued support. If you have any questions or concerns, our team is here to assist you. Please feel free to reach out via [support form](https://www.allxon.com/support) at any time. 

# What is Allxon Artifact Toolkit
Allxon Artifact Toolkit is a simple yet powerful tool that packages all kinds of files into a unified format to support seamless operations during Allxon OTA deployment across a mass fleet of remote edge AI devices. Allxon Artifact Toolkit not only allows you to intuitively customize your OTA script and process, but it only requires four simple steps to complete artifact packaging. Whether you want to update docker image, firmware, BSP image, application file, software, script, image, video, etc., you can easily package it into an Allxon verified artifact that is readable by Allxon Portal, giving you a smoother user experience. 

# Allxon Artifact Toolkit Structure 
The Allxon Artifact Toolkit Structure below shows you the path to correctly input your files and directories in order to successfully package your OTA artifact. 
```
allxon-artifact-toolkit-linux
├── ota_content
│   └── ota_deploy.sh
├── artifact_tool.sh
└── README.md
```
- **ota_content**:  the folder where you will put all the necessary files you want to deploy on your devices.
- **ota_deploy.sh**: the executable script that handles all operations related to OTA deployment, allowing you to customize your OTA deployment process to suit your needs. 
- **artifact_tool.sh**: a shell script that is used to generate and test an OTA artifact. 



# How to Generate OTA Artifact Using Allxon Artifact Toolkit 
1. Make sure you have put everything (docker image, firmware, BSP image, application file, software, script, image, video, etc.) you are going to deploy onto your devices into the `ota_content` directory. 
2. Edit `ota_deploy.sh` to suit your needs. (e.g. calling an executable file to execute an action or run an application update).
3. Run `$sudo artifact_tool.sh –-package` to generate an OTA artifact. 
4. Run `$sudo artifact_tool.sh --test {file name of artifact}` to test the Allxon OTA artifact you generated. This action will simulate OTA deployment by running `ota_deploy.sh`, therefore, the artifact will be deployed on the host. 
5. Verify if the deployment operation is executed as expected as specified in `ota_deploy.sh`.



> [!NOTE]
> By default, the architecuture of the artifact generated will be the same as the host architecture. (e.g. `x86`, `x86_64` or `aarch64`).
> * Specify the architecture for an artifact with `--arch` argument.
> `$sudo artifact_tool.sh --arch aarch64 –-package`
>    * List of supported architecture
>      * `x86`
>      * `x86_64`
>      * `aarch64`
> * Generate an artifact for all the supported architecture with `--arch all` 
> `$sudo artifact_tool.sh --arch all –-package` 
   
# What is Next
Once you have generated your Allxon Artifact Toolkit, head over to [Allxon Portal](https://dms.allxon.com/) to start performing OTA updates from the cloud portal to fleets of edge devices! 

Follow the instrustions to [deploy Allxon OTA artifact](https://www.allxon.com/knowledge/deploy-ota-artifact).
