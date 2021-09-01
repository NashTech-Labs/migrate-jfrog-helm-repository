# Migrate jfrog Helm Repository Charts

Using this script you can easily migrate whole jfrog helm repository to the new helm repository of the same artifactory or new artifactory.

## Required vars for migration
```
ARTIFACTORY_URL=""
ARTIFACTORY_PATH=""
USERNAME=""
PASSWORD=""
NEW_ARTIFACTORY_PATH=""
```

Update the above vars in the script and just run the script.

```
cd migrate-jfrog-helm-repository
chmod +x migrate-helm-repo.sh
./ migrate-helm-repo.sh
```
