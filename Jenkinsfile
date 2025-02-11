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
                 sh 'mvn clean deploy package -Dmaven.test.skip=true'
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
           
    }
}