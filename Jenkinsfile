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

        stage('Initial Notification') {
            steps {
                 //put webhook for your notification channel 
                 echo 'Pipeline Start Notification'
            }
        }

        stage('Static Code Analysis') { 
            //put your code scanner 
            parallel {
                stage('Build') {
                    steps {
                        container('maven') {
                            sh 'Build w/o SAST'
                        }
                    }
                }
                stage('SAST Analysis') {
                    steps {
                        container('maven') {
                            sh 'Build w SAST'
                        }
                    }
                }
            }
            post{
                success{
                    echo "Code Analysis Successfully"
                }
                failure{
                    echo "Code Analysis Failed"
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

        stage("Deploy to Staging w IAST"){
              when {
                  branch 'cloudbees-ci'
              }
              parallel {
                stage('Deploy') {
                    steps {
                        container('maven') {
                            sh 'Build w/o SAST'
                        }
                    }
                }
                stage('Deploy with Seeker IAST') {
                    steps {
                        container('maven') {
                            sh 'Build w SAST'
                        }
                    }
                }
              }
              post{
                  success{
                      echo "Successfully deployed to Staging"
                  }
                  failure{
                      echo "Failed deploying to Staging"
                  }
              }
          }

        stage("Deploy to Production"){
                when {
                    branch 'master'
                }
                steps { 
                    // kubernetesDeploy kubeconfigId: 'kubeconfig-credentials-id', configs: 'build-pod.yaml', enableConfigSubstitution: true  // REPLACE kubeconfigId
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
        always{
    step([
             //put your Testing
            ])
        }
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