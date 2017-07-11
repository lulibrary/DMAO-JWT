#!/usr/bin/env groovy
podTemplate(label: 'dmao-jwt-issuer', containers: [
  containerTemplate(name: 'jnlp', image: 'jenkinsci/jnlp-slave:2.62', args: '${computer.jnlpmac} ${computer.name}', workingDir: '/home/jenkins', resourceRequestCpu: '200m', resourceLimitCpu: '200m', resourceRequestMemory: '256Mi', resourceLimitMemory: '256Mi'),
  containerTemplate(name: 'docker', image: 'docker:17.06.0-ce', command: 'cat', ttyEnabled: true)
],
volumes:[
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
]){
  node ('dmao-jwt-issuer') {

    def app
    def imageName = "dmaonline/jwt-issuer"

    checkout scm

    slackSend channel: '#dmao-dev', color: 'warning', message: "Build Started: ${env.JOB_NAME} ${env.BUILD_NUMBER}"

    try {

      stage ('Build Docker Image'){
        container('docker') {
          sh "docker build -t ${imageName} ."
          app = docker.image(imageName)
        }
      }

      stage ('Write test env file') {
        container('docker') {
          sh "cat env.test"
          sh "cp env.test .env"
          sh "cat .env"
        }
      }

      stage ('Setup ci network') {
        container('docker') {
          sh 'docker network create -d bridge test_ci'
        }
      }

      stage ('Setup test DB') {
        container('docker') {
          sh 'docker pull "postgres:9.5.6"'
          sh '''POSTGRES_CONTAINER=`docker run -d --network=test_ci --name postgres postgres:9.5.6`
            until nc -z $(docker inspect --format=\'{{.NetworkSettings.Networks.test_ci.IPAddress}}\' $POSTGRES_CONTAINER) 5432
            do
                echo "waiting for postgres container..."
                sleep 0.5
            done'''
          sh "docker run --network=test_ci --env-file .env ${imageName} rake db:migrate"
        }
      }

      stage ('Run Tests') {
        container('docker') {
          sh "docker run --network=test_ci --env-file .env ${imageName} rake spec"
        }
      }

      stage ('Push Images') {
        container('docker') {
          docker.withRegistry('https://registry.dmao.org', 'dmao-registry-credentials') {
              app.push("${env.BRANCH_NAME}-${env.BUILD_NUMBER}")
              app.push("dev")
          }
        }
      }

      slackSend channel: '#dmao-dev', color: 'good', message: "Build Completed: ${env.JOB_NAME} ${env.BUILD_NUMBER}"

      container ('docker') {
        sh "echo 'Cleaning up containers'"
        sh 'docker stop postgres && docker rm postgres'
        sh 'docker network rm test_ci'
      }

    } catch (error) {
      
      slackSend channel: '#dmao-dev', color: 'danger', message: "Build Failed: ${env.JOB_NAME} ${env.BUILD_NUMBER}"

      container ('docker') {
        sh "echo 'Cleaning up containers'"
        sh 'docker stop postgres && docker rm postgres'
        sh 'docker network rm test_ci'
      }
      
      throw error
    }
  }
}