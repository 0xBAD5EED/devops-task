pipeline {
    agent {
        kubernetes {
            label 'python-worker'
            defaultContainer 'python-worker'
        }
    }

    environment {
        REGISTRY       = '10.97.29.44:5000' // registry:2 runs inside the minikube cluster to serve images.
        IMAGE_NAME     = 'helloapp'
        IMAGETAG     = "${REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT}"
        CREDENTIALS_ID = 'github-pat'
    }

    stages {
        stage('Build & Push with Kaniko') {
            agent {
                kubernetes {
                    label 'kaniko'
                    defaultContainer 'kaniko'
                }
            }
            steps { // Using Kaniko since it's faster, no need to run privileged DinD, and minikube does not play well with the Docker socket.
                sh '''
                    /kaniko/executor \
                      --context ${WORKSPACE} \
                      --dockerfile Dockerfile \
                      --destination=${IMAGETAG} \
                      --insecure \
                      --skip-tls-verify
                '''
            }
        }

        stage('Install requirements') { // The executor already has the dependencies pre-installed for faster build time, this is a refresher.
            steps {
                sh '''
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Testing') { // Default pipeline behavior will fail the build if any of these return non-zero exit
            steps {        // It would be good to include pylint, pyright, and possibly sonarscan/cloud here.
                sh '''
                    python -m unittest helloapp.test
                '''
            }
        }

        stage('Deploy with Helm') { // Simple deployment using ./helm/ where the chart is located. Atomic to make sure it is successful.
            steps {
                sh '''
                    helm upgrade --install helloapp ./chart -n formlabs --set image=${IMAGETAG} --atomic
                '''
            }
        }
    }
}
