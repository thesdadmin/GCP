
# Docker containers in GCP
How to create a container using GCP build and Dockerfiles. 
For this example, we're using NGINX non-privileged. 

docker.io/nginxinc/nginx-unprivileged:latest

## Installation

Use the package manager [pip](https://pip.pypa.io/en/stable/) to install foobar.

```bash
pip install foobar
```

## Usage

```python
import foobar

# returns 'words'
foobar.pluralize('word')

# returns 'geese'
foobar.pluralize('goose')

# returns 'phenomenon'
foobar.singularize('phenomena')
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
usr/share/nginx/html/index.html

ARTIFACT_REGISTRY

REPOSITORY: sandbox-repo
FORMAT: DOCKER
MODE: STANDARD_REPOSITORY
DESCRIPTION: Sandbox docker repository
LOCATION: us-central1
LABELS: 
ENCRYPTION: Google-managed key
CREATE_TIME: 2023-08-25T20:51:22
UPDATE_TIME: 2023-08-25T20:51:22
SIZE (MB): 0\


gcloud builds submit "gs://bucket/object.zip" --tag=gcr.io/my-project/image --config=config.yaml

gcloud builds submit Nginx.dockerfile --region=us-central1 --tag us-central1-docker.pkg.dev/prj-rpittman-sandbox-01/sandbox-repo/nginx-nonroot:latest --project prj-prittman-sandbox-01