pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
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
            withCredentials([string(credentialsId: 'Trivy-Scan-Theo', variable: 'TOKEN')]) {

                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                  sh "sed -i 's#Trivy-Scan-Theo#${TOKEN}#g' trivy-scan-theo.sh"      
                  sh "sudo bash trivy-scan-theo.sh"
//code sh here 
                }

            }
          }
        }

      stage('Docker Build and Push') {
  	      steps {
    	      withCredentials([string(credentialsId: 'Docker-Hub-Pass-Théo', variable: 'DOCKER_HUB_PASSWORD')]) {
      	        sh 'sudo docker login -u virtu0zz -p $DOCKER_HUB_PASSWORD'
              	sh 'printenv'
      	        sh 'sudo docker build -t virtu0zz/hello-word:""$GIT_COMMIT"" .'
      	        sh 'sudo docker push virtu0zz/hello-word:""$GIT_COMMIT""'
        	}

  	}
	}


    }
}