def registry = 'https://money.jfrog.io/'
def version  = '2.1.6'
def imageName = 'money.jfrog.io/valaxy-docker-local/ttrend'

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
           

        stage("Jar Publish") 
            {
            steps {
                script {
                    echo '<--------------- Jar Publish Started --------------->'
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"artifact-cred"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "target/(*)",
                              "target": "sid01-libs-release-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                     def buildInfo = server.upload(uploadSpec)
                     buildInfo.env.collect()
                     server.publishBuildInfo(buildInfo)
                     echo '<--------------- Jar Publish Ended --------------->'  
            
                    }
                }   
            }


        stage(" Docker Build ") 
            {
            steps {
                    script {
                        echo '<--------------- Docker Build Started --------------->'
                        echo '<-----Docker build is used to convert jar into docker images inorder to use them as micro services --->'
                        app = docker.build(imageName+":"+version)
                        echo '<--------------- Docker Build Ends --------------->'
                   }
               }
           }


        stage (" Docker Publish ")
            {
            steps {
                    script {
                            echo '<--------------- Docker Publish Started --------------->'  
                            docker.withRegistry(registry, 'artifact-cred')
                            {
                            app.push()
                            }    
                            echo '<--------------- Docker Publish Ended --------------->'  
                        }
                }
            }
    }
}