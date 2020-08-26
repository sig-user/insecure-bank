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
                image: gautambaghel/maven-with-wget:latest
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

        stage('Compile & Package') {
            steps {
                 container('maven') {
                        echo 'Compiling the project'
                        sh 'mvn clean package'
                }
            }
        }

        stage('Commit Time Checks') { 
            //put your code scanner 
            steps {
                container('maven') {
                    echo 'Build w SAST'
                    sh 'mkdir /root/.synopsys && \
                        export POLARIS_HOME="/root/.synopsys" && \
                        export POLARIS_SERVER_URL="https://sipse.polaris.synopsys.com" && \
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
  
        stage('Automated Testing') {
            steps {
                //put your Testing
                container('maven') {
                    echo 'Robot Testing Start'
                    sh 'mvn test'
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

        stage('Build Time Checks') {
            steps {
                container('maven') {
                    //Put your image scanning tool 
                    echo 'Open Source Scanning Start'
                    sh 'curl -O https://detect.synopsys.com/detect.sh && \
                        chmod +x detect.sh && \
                        ./detect.sh \
                        --blackduck.url="https://bizdevhub.blackducksoftware.com" \
                        --blackduck.api.token="${BLACKDUCK_ACCESS_TOKEN}" \
                        --blackduck.trust.cert=true \
                        --detect.project.name="CloudBeesInsecureBank" \
                        --detect.tools="DETECTOR" \
                        --detect.project.version.name="CloudBees_${BUILD_TAG}"'
                }
            }

            post{
                success{
                    echo "Software Composition Scanning Successfully"
                }
                failure{
                    echo "Software Composition Scanning Failed"
                }
            }
        }

        stage("Testing"){
            when {
                branch 'test'
            }
            steps { 
                kubernetesDeploy kubeconfigId: 'kubeconfig-credentials-id', configs: 'build-pod.yaml', enableConfigSubstitution: true  // REPLACE kubeconfigId
            }
            post{
                success{
                    echo "Successfully deployed to Testing"
                }
                failure{
                    echo "Failed deploying to Testing"
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
                        echo 'Deployment successful at http://34.66.139.87/login'
                        echo 'Please use john@example.com:test as login'
                    }
                }
                stage('Deploy with Seeker IAST') {
                    steps {
                        echo 'Deployment successful at http://34.66.139.87/login'
                        echo 'Please use john@example.com:test as login'
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