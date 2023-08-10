
# Python Scripts for GCP Certificate Manager

Scripts to interact with [GCP Certificate Manager](https://cloud.google.com/certificate-manager/docs/overview)







## Prerequisites
For Windows: 
  1. Install Python 3.11 or higher.
  2. Create a Virtual Environment for Python
     ```
      python -m venv venv
     ```
  3. Activate Virtual Environment
     ```
     PS> venv\Scripts\activate
     (venv) PS>
     ```
  4. Install packages
     ```
     <your-env>\Scripts\pip.exe install google-cloud-certificate-manager
     ```
  5. Configure authentication for gcloud cli (assumes Google Cloud SDK is already installed, [Google Cloud SDK installation](https://cloud.google.com/sdk/docs/install))
     ```
     gcloud auth login
     ```
  6. Configure authetication for Client libraries
     ```
     gcloud auth application-default login
     ```
  5. Deactivate VENV when finished
     ```
      PS> venv\Scripts\deactivate
     ```
## Certificate Rotation

Use Python SDK to list and rotate scripts. Then use script in Cloud Run. 
