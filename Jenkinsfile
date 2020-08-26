pipeline {
  
    agent {
      kubernetes {
        label 'maven-app'
        defaultContainer 'jnlp'
        yaml """
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: maven
                image: maven:3.3.9-jdk-8-alpine
                command:
                - cat
                tty: true
            """
      }
    }

    environment {
        //put your own environment variables
        REGISTRY_URI = "docker.io/gautambaghel"
        BLACKDUCK_ACCESS_TOKEN  = credentials('jenkins-blackduck-access-token')
        POLARIS_ACCESS_TOKEN = credentials('jenkins-polaris-access-token')
    }
 
    stages {

        stage('Pipeline Start Notification') {
            steps {
                 //put webhook for your notification channel 
                 echo 'Pipeline Start Notification'
            }
        }

        stage('Build Phase') { 
            //put your code scanner 
            parallel {
                stage('mvn package') {
                    steps {
                        container('maven') {
                            echo 'Build w/o SAST'
                        }
                    }
                }
                stage('Static Code Analysis') {
                    steps {
                        container('maven') {
                            echo 'Build w SAST'
                            sh 'export POLARIS_HOME="/root/.synopsys" && \
                                sourceDir=$(pwd) && \
                                cd $POLARIS_HOME || exit && \
                                wget "https://sipse.polaris.synopsys.com/api/tools/polaris_cli-linux64.zip" && \
                                DIR=$(zipinfo -1 polaris_cli-linux64.zip | grep -oE "^[^/]+" | uniq) && \
                                unzip polaris_cli-linux64.zip && rm polaris_cli-linux64.zip && \
                                cd "${DIR}"/bin || exit && \
                                polaris=$(pwd)/polaris && \
                                cd "$sourceDir" || exit && \
                                "$polaris" -c polaris.yml analyze 2>&1 | tee polaris_logs.log'
                        }
                    }
                }
            }
        }
  
        stage('Automated Testing') {
            steps {
                //put your Testing
                container('maven') {
                    echo 'Robot Testing Start'
                    echo 'mvn test'
                }
            }

            post{
                success{
                    echo "Automated Testing Successfully"
                }
                failure{
                    echo "Automated Testing Failed"
                }
            }
            
        }

        stage('Open Source Composition Scan') {
            steps {
                container('maven') {
                    //Put your image scanning tool 
                    echo 'Open Source Scanning Start'
                    // sh 'curl -O https://detect.synopsys.com/detect.sh && \
                    //     chmod +x detect.sh && \
                    //     ./detect.sh \
                    //     --blackduck.url="https://bizdevhub.blackducksoftware.com" \
                    //     --blackduck.api.token="${BLACKDUCK_ACCESS_TOKEN}" \
                    //     --blackduck.trust.cert=true \
                    //     --detect.project.name="CloudBeesDucky" \
                    //     --detect.tools="DETECTOR" \
                    //     --detect.project.version.name="DETECTOR_${BUILD_TAG}"'
                }
            }

            post{
                success{
                    echo "Composition Scanning Successfully"
                }
                failure{
                    echo "Composition Scanning Failed"
                }
            }
        }

        stage("Staging"){
            when {
                branch 'cloudbees-ci'
            }
            parallel {
                stage('Deploy') {
                    steps {
                        container('kubectl') {
                            echo 'Deploy w/o IAST'
                        }
                    }
                }
                stage('Deploy with Seeker IAST') {
                    steps {
                        container('maven') {
                            echo 'Deploy w IAST'
                        }
                    }
                }
            }
        }

        stage("Production"){
            when {
                branch 'master'
            }
            steps { 
                kubernetesDeploy kubeconfigId: 'kubeconfig-credentials-id', configs: 'build-pod.yaml', enableConfigSubstitution: true  // REPLACE kubeconfigId
            }
            post{
                success{
                    echo "Successfully deployed to Production"
                }
                failure{
                    echo "Failed deploying to Production"
                }
            }
        }

      }
        
    post{
        success{
            //notification webhook
            echo 'Pipeline Execution Successfully Notification'
        }
        failure{
            //notification webhook
            echo 'Pipeline Execution Failed Notification'
        }
    }
}