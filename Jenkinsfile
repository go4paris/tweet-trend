pipeline {
    agent {
        
        node {label 'maven'
            
        }
    }

environment {
    PATH ="/opt/apache-maven-3.9.6/bin:$PATH"
}

    stages {
        
         stage("build")
            {
            steps {
                 echo "----------- build started ----------"
                 sh 'mvn clean package -Dmaven.test.skip=true'
                 echo "----------- build complted ----------"
                 }
            }
        stage("test")
            {
            steps{
                echo "----------- unit test started ----------"
                sh 'mvn surefire-report:report'
                 echo "----------- unit test Complted ----------"
                }
        }
        stage("Sonarqube Analysis")
                {
                    environment {
                        scannerHome = tool 'sonar-scanner'
                        PATH ="/usr/bin:$PATH"
                    }
            steps{
                  withSonarQubeEnv('sonarqube-server') {
                    sh "${scannerHome}/bin/sonar-scanner"
                    sh 'export NODE_OPTIONS="--max-old-space-size=4096"'
                  }
                }

             }

        stage("Quality Gate")
            {
            steps {
                script {
                        timeout(time: 1, unit: 'HOURS') 
                        { // Just in case something goes wrong, pipeline will be killed after a timeout
                            def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
                            if (qg.status != 'OK') {
				            error "Pipeline aborted due to quality gate failure: ${qg.status}"
			                }
                        }
                        }
                    }
            }
           
    }
}