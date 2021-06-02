node{
        def mavenHome
        def mavenCMD
        def docker
        def dockerCMD
        def tagName = "1.0"

        stage('Preparation of Jenkins'){
            try{
                echo "Setting up the Jenkins environment..."
                mavenHome = tool name: 'maven', type: 'maven'
                mavenCMD = "${mavenHome}/bin/mvn"
                docker = tool name: 'docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'
                dockerCMD = "$docker/bin/docker"
            }
            catch(Exception err){
                echo "Exception occured during Preparation Of Jenkins step..."
                currentBuild.result="FAILURE"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed at step - Preparation Of Jenkins", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details and verify the cause for the build failure. \n Error:\n $err \n\n Regards, \n DevOps Team "
		        throw err
            }            
        }

       stage('git checkout'){
           try{
                echo "Checking out the code from git repository..."
                git 'https://github.com/ailamadu/batch10.git'
            }
            catch(Exception err){
                echo "Exception occured during git checkout step..."
                currentBuild.result="FAILURE"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed at step - git checkout", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details and verify the cause for the build failure. \n Error:\n $err \n\n Regards, \n DevOps Team "
                throw err
            }

        stage('Build, Test and Package'){
            try{
                echo "Building the application..."
                sh "${mavenCMD} clean package"
            }
            catch(Exception err){
                echo "Exception occured during Build, Test and Package..."
                currentBuild.result="FAILURE"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed at step - Build, Test and Package", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details and verify the cause for the build failure. \n  Error:\n $err \n\n Regards, \n DevOps Team "
                throw err
            }
        }
    
        stage('Generating UnitTest Report'){
            try{
                echo "Generating Report"
                sh "${mavenCMD} surefire-report:report-only"
            }
            catch(Exception err){
                echo "Exception occured during Generating UnitTest Report..."
                currentBuild.result="FAILURE"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed at step - Generating UnitTest Report", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details and verify the cause for the build failure. \n Error:\n  $err \n\n Regards, \n DevOps Team "
                throw err
            }
        } 
        stage('Sonar Scan'){
            try{
               echo "Scanning application for vulnerabilities using Sonar..."
                sh "${mavenCMD} sonar:sonar -Dsonar.host.url=http://35.188.131.222:9000  -Dsonar.login=03c8b31da2e09c29b8eb5078385d4eeff321735d"
            }
            catch(Exception err){
                echo "Exception occured during Sonar Scan..."
                currentBuild.result="FAILURE"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed at step - Sonar Scan", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details and verify the cause for the build failure. \n Error:\n $err \n\n Regards, \n DevOps Team "
                throw err
            }           
        }
    
        stage('Publish Report'){
            try{
                echo " Publishing HTML report.."
                publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'target/site/', reportFiles: 'surefire-report.html', reportName: 'HTML Report', reportTitles: ''])
            }
            catch(Exception err){
                echo "Exception occured during Publish Report..."
                currentBuild.result="FAILURE"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed at step - Publish Report", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details and verify the cause for the build failure. \n  Error:\n $err \n\n Regards, \n DevOps Team "
                throw err
            } 
        }

        stage('Build Docker Image'){
            try{
                echo "Building docker image for application ..."
                sh "${dockerCMD} build -t ailamadu/casestudy:${tagName} ."
            }
            catch(Exception err){
                echo "Exception occured during Build Docker Image..."
                currentBuild.result="FAILURE"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed at step - Build Docker Image", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details and verify the cause for the build failure. \n  Error:\n $err \n\n Regards, \n DevOps Team "
                throw err
            } 
        }
    
        stage("Push Docker Image to Docker Registry"){
            try{
                echo "Log into the dockerhub and Pushing image"
                withCredentials([string(credentialsId: 'dockerpwd', variable: 'dockerhubPwd')]) {   
                    sh ("${dockerCMD}" + login -u ailamadu -p ${dockerhubPwd}')
                    sh "${dockerCMD} push ailamadu/casestudy:${tagName}"
                }
            }
            catch(Exception err){
                echo "Exception occured during Push Docker Image to Docker Registry..."
                currentBuild.result="FAILURE"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed at step - Push Docker Image to Docker Registry", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details and verify the cause for the build failure. \n  Error:\n $err \n\n Regards, \n DevOps Team "
                throw err
            } 
        }
    
        stage('Deploy Application using Ansible'){
            try{
                echo "Deploying the applicaiton using Ansible Playbook.."
                ansiblePlaybook credentialsId: 'ssh', disableHostKeyChecking: true, installation: 'ansible', inventory: '/etc/ansible/hosts', playbook: 'deploy-playbook.yml' , extras: '-u ubuntu'
            }
            catch(Exception err){
                echo "Exception occured during Deploy Application using Ansible..."
                currentBuild.result="FAILURE"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed at step - Deploy Application using Ansible", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details and verify the cause for the build failure. \n   Error:\n $err \n\n Regards, \n DevOps Team "
                throw err
            }
        }
    
        stage('Workspace Cleanup'){
            try{
                echo "Clean the Jenkin Pipeline's workspace..."
                cleanWs()
            }
            catch(Exception err){
                echo "Exception occured during Workspace Cleanup..."
                currentBuild.result="FAILURE"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed at step - Workspace Cleanup", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details and verify the cause for the build failure. \n  Error:\n $err \n\n Regards, \n DevOps Team "
                throw err
            }
            finally{
                echo "Build is Completed"
                mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Completed Successfully", body: "Hi Team, \n\n Please go to ${BUILD_URL} for more details. \n\n Regards, \n DevOps Team "
            }
        }
     }
}
