pipeline {
  agent any

  environment {
    deploymentName = "devsecops-theo"
    containerName = "devsecops-theo-container"
    serviceName = "devsecops-theo-svc"
    imageName = "virtu0zz/hello-word:${GIT_COMMIT}"
    applicationURL="http://mytpm.eastus.cloudapp.azure.com"
    applicationURI="/increment/99"

  }

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
 
 
      stage('SonarQube - SAST') {
       steps {
         withSonarQubeEnv('SonarQubeConfig') {
           sh "mvn sonar:sonar -Dsonar.projectKey=sonarqube_theo -Dsonar.projectName=sonarqube_theo -Dsonar.host.url=http://mytpm.eastus.cloudapp.azure.com:9999" 
         }
         timeout(time: 2, unit: 'MINUTES') {
           script {
             waitForQualityGate abortPipeline: true
           }
         }
       }
     }
 
 
    stage('Vulnerability Scan - Docker Trivy') {
       steps {
              withCredentials([string(credentialsId: '	Trivy-Scan-Theo', variable: 'TOKEN')]) {
		  	catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
               sh "sed -i 's#token_github#${TOKEN}#g' trivy-scan-theo.sh"      
               sh "sudo bash trivy-scan-theo.sh" 
          }
        }
       }
     }


     stage('Vulnerability Scan - Docker') {
        steps {
    	      catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
			        sh "mvn dependency-check:check"
    	   }
   	  }
   	      post {
  	        always {
   			      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
   			 }
   	 }
 }

//      stage('SonarQube Analysis - SAST') {
//        steps {
//           catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
//
//          withSonarQubeEnv('SonarQube') {
//              sh "mvn clean verify sonar:sonar \
//                    -Dsonar.projectKey=jenkins-token-theo \
//                    -Dsonar.projectName='jenkins-token-theo' \
//                    -Dsonar.host.url=http://mytpm.eastus.cloudapp.azure.com:9112 \
//                    -Dsonar.token=sqp_ace66f0d82667835e4210a1e6e1624fe699c38ad"
//              }
//            }
//        }
//    }


 
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
  
     stage('Vulnerability Scan - Kubernetes') {
           steps {
             parallel(
               "OPA Scan": {
                 sh 'sudo docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
               },
               "Kubesec Scan": {
                 sh "sudo bash kubesec-scan.sh"
               },
               "Trivy Scan": {
                 sh "sudo bash trivy-k8s-scan.sh"
               }
             )
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


      stage('OWASP ZAP - DAST') {
       steps {
         withKubeConfig([credentialsId: 'kubeconfig']) {
           sh 'sudo bash zap.sh'
         }
       }
     }

  stage('Integration Tests - DEV') {
           steps {
             script {
               try {
                 withKubeConfig([credentialsId: 'kubeconfig']) {
                   sh "bash integration-test.sh"
                 }
               } catch (e) {
                 withKubeConfig([credentialsId: 'kubeconfig']) {
                   sh "kubectl -n default rollout undo deploy ${deploymentName}"
                 }
                 throw e
               }
             }
           }
         }




    }
}