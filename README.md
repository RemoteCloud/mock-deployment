# Mock Deployment
We use this repo to test our auto update functionallity. Once working it will be deleted and the actual deployment repository will be created.

## Note
The repo uses two environment files. One is the public called `.env` and the second is the location specific file called  `.env-secrets`. The `.env-secrets` will be created on the first deployment (not the scope of this repository). It will contain additional environment variables specific to the current location and can also be used to override variables from the `.env` file. The `.env-secrets` file is required for the scripts to work.