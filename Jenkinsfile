try{
    node('master'){
        def mavenHome
        def mavenCMD
        def docker
        def dockerCMD
        def tagName = "1.0"
        
        stage('Preparation of Jenkins'){
            echo "Setting up the Jenkins environment..."
            mavenHome = tool name: 'maven', type: 'maven'
            mavenCMD = "${mavenHome}/bin/mvn"
            docker = tool name: 'docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'
            dockerCMD = "$docker/bin/docker"
        }

       stage('git checkout'){
            echo "Checking out the code from git repository..."
            git 'https://github.com/ailamadu/batch10.git'
        }

        stage('Build, Test and Package'){
            echo "Building the application..."
            sh "${mavenCMD} clean package"
        }
    
        stage('Generating UnitTest Report'){
            echo "Generating Report"
            sh "${mavenCMD} surefire-report:report-only"
        } 
        stage('Sonar Scan'){
            echo "Scanning application for vulnerabilities using Sonar..."
            sh "${mavenCMD} sonar:sonar -Dsonar.host.url=http://34.122.103.162:9000  -Dsonar.login=03c8b31da2e09c29b8eb5078385d4eeff321735d"
        }
    
        stage('publish report'){
            echo " Publishing HTML report.."
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'target/site/', reportFiles: 'surefire-report.html', reportName: 'HTML Report', reportTitles: ''])
        }

        stage('Build Docker Image'){
            echo "Building docker image for addressbook application ..."
            sh "${dockerCMD} build -t ailamadu/casestudy:${tagName} ."
        }
    
        stage("Push Docker Image to Docker Registry"){
            echo "Log into the dockerhub and Pushing image"
            withCredentials([string(credentialsId: 'dockerpwd', variable: 'dockerhubPwd')]) {
                sh "${dockerCMD} login -u ailamadu -p ${dockerhubPwd}"
                sh "${dockerCMD} push ailamadu/casestudy:${tagName}"
            }
        }
    
        stage('Deploy Application using Ansible'){
            echo "Deploying the applicaiton using Ansible Playbook.."
            ansiblePlaybook credentialsId: 'ssh', disableHostKeyChecking: true, installation: 'ansible', inventory: '/etc/ansible/hosts', playbook: 'deploy-playbook.yml' , extras: '-u ubuntu'
        }
    
        stage('Workspace Cleanup'){
            echo "Clean the Jenkin Pipeline's workspace..."
            cleanWs()
        }
    }
}
catch(Exception err){
    echo "Exception occured..."
    currentBuild.result="FAILURE"
    mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is  Failed", body: "Hi Team, \n\n Please go to ${BUILD_URL} and verify the cause for the build failure. \n  $err \n\n Regards, \n DevOps Team "
}
finally {
    (currentBuild.result!= "ABORTED") && node("master") && (currentBuild.result!= "FAILURE"){
    echo "finally gets executed and sends an email notification for every successful Build"
    mail to: 'ailamadu@gmail.com', subject: "Job ${JOB_NAME} (${BUILD_NUMBER}) is Success", body: "Hi Team, \n\n Please go to ${BUILD_URL} and verify the success logs. \n\n Regards, \n DevOps Team "
    }
}
