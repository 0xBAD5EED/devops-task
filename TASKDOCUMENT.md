## Devops task solution document

### Environment information
I have opted to use Minikube with the Docker driver to deploy to due to its ease of use. After this, I created:
- Jenkins on minikube (Made a minimal helm chart for it)
- registry to serve as the local container registry for Jenkins builds and to host my custom python executor

Namespaces created:
- jenkins
- registry
- formlabs (For the app)

### The pipeline

The pipeline is configured as a "Discover all branches" multibranch pipeline.
Due to the constraint of Jenkins running inside a minikube cluster and not having an external endoint
to receive webhook pushes, the repo is scanned in tight intervals to discover changes and deploy the app.

Upon triggering and cloning the branch, the following is performed:

1. Kaniko executor will build the container (DinD, buildah(as mentioned) or other solutions could have been used here,
Kaniko was picked for being rootless and not requiring a docker socket which is an issue on Minikube when running on a Mac)
For the image tags, I opted to use the commit hash. The shortended commit hash would also have been a good option. Under prod
circumstances, the format would also include the version of the app when a version file is present to extract that from.

2. Executes the unit test - by default a non-zero exit here would trigger the pipeline to fail which is the desired outcome 
in case of failure. These can also be expanded to use pylint, pyright, and sonar among others to test both quality and security.

3. Deployment commences with the Helm chart. Atomic flag is set so it fails if the pod won't come up. This creates the pod inside the
formlabs namespace with a rolling update. Healthchecks are configured for the "/" endpoint.

### Alternative solutions
Alterantively this could also have been solved by Github actions or Gitlab CI if I had a cloud based kubernetes cluster.
