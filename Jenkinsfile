pipeline {
  agent any
 
  stages {
     
 
 
    stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they  be d
            }
        }
 
 
    stage('UNIT test & jacoco ') {
      steps {
        sh "mvn test"
      }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
        }
      }
 
    }
 
 
      stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
              }
      post {
        always {
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
      }
      }
 
 
 
 
 
    stage('Vulnerability Scan - Docker Trivy') {
       steps {
//--------------------------replace variable  token_github on file trivy-image-scan.sh
         withCredentials([string(credentialsId: '	Trivy-Scan-Theo', variable: 'TOKEN')]) {

          catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            sh "sed -i 's#token_github#${TOKEN}#g' trivy-scan-theo.sh"      
            sh "sudo bash trivy-scan-theo.sh"
//code sh here 
          }
        }
       }
     }

  stage('SonarQube Analysis - SAST') {
       steps {

         withSonarQubeEnv('SonarQube') {

             mvn clean verify sonar:sonar \
                -Dsonar.projectKey=theo-jenkins-pipeline \
                -Dsonar.projectName='theo-jenkins-pipeline' \
                -Dsonar.host.url='http://127.0.0.1:9020' \
                -Dsonar.token=sqp_3645cfa3383be4ebe1f4800e5fbc85fa6a992e59

          }
        }
       }

 
      stage('Docker Build and Push') {
    steps {
      withCredentials([string(credentialsId: 'Docker-Hub-Pass-Théo', variable: 'DOCKER_HUB_PASSWORD')]) {
        sh 'sudo docker login -u virtu0zz -p $DOCKER_HUB_PASSWORD'
        sh 'printenv'
        sh 'sudo docker build -t virtu0zz/hello-word-theo:""$GIT_COMMIT"" .'
        sh 'sudo docker push virtu0zz/hello-word-theo:""$GIT_COMMIT""'
      }
 
    }
  }
 
      stage('Deployment Kubernetes  ') {
    steps {
      withKubeConfig([credentialsId: 'kubeconfig']) {
            sh "sed -i 's#replace#virtu0zz/hello-word-theo:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
      }
 
    }
 
 
 
 
 
 
    }
}