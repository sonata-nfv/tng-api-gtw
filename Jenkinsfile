pipeline {
  agent any
  stages {
    stage('Container Build') {
      parallel {
        stage('Container Build') {
          steps {
            echo 'Building..'
          }
        }
        stage('tng-api-gtw') {
          steps {
            sh 'docker build -t registry.sonata-nfv.eu:5000/tng-api-gtw -f tng-router/Dockerfile tng-router/'
          }
        }
        stage('tng-sec-gtw') {
          steps {
            sh 'docker build -t registry.sonata-nfv.eu:5000/tng-sec-gtw -f tng-sec-gtw/Dockerfile tng-sec-gtw/'
          }
        }
      }
    }
    stage('Unit Tests') {
      steps {
        echo 'Unit Testing..'
      }
    }
    stage('Code Style check') {
      steps {
        echo 'Code Style check....'
      }
    }
    stage('Containers Publication') {
      parallel {
        stage('Containers Publication') {
          steps {
            echo 'Publication of containers in local registry....'
          }
        }
        stage('tng-api-gtw') {
          steps {
            sh 'docker push registry.sonata-nfv.eu:5000/tng-api-gtw'
          }
        }
        stage('tng-sec-gtw') {
          steps {
            sh 'docker push registry.sonata-nfv.eu:5000/tng-sec-gtw'
          }
        }
      }
    }
    stage('Deployment in pre-integration') {
      parallel {
        stage('Deployment in Integration') {
          steps {
            echo 'Deploying in integration...'
          }
        }
        stage('Deploying') {
          steps {
            sh 'rm -rf tng-devops || true'
            sh 'git clone https://github.com/sonata-nfv/tng-devops.git'
            dir(path: 'tng-devops') {
              sh 'ansible-playbook roles/sp.yml -i environments -e "target=pre-int-sp-ath.5gtango.eu component=gatekeeper"'
              sh 'ansible-playbook roles/vnv.yml -i environments -e "target=pre-int-vnv-bcn.5gtango.eu component=gatekeeper"'
            }
          }
        }
      }
    }
    stage('Smoke Tests') {
      steps {
        sh 'echo "Will excute ./tests/integration/functionaltests.sh, but disabelled for now"'
      }
    }
    stage('Promoting containers to integration env') {
      when {
         branch 'master'
      }
      parallel {
        stage('Publishing containers to int') {
          steps {
            echo 'Promoting containers to integration'
          }
        }
        stage('tng-api-gtw') {
          steps {
            sh 'docker tag registry.sonata-nfv.eu:5000/tng-api-gtw:latest registry.sonata-nfv.eu:5000/tng-api-gtw:int'
            sh 'docker push  registry.sonata-nfv.eu:5000/tng-api-gtw:int'
          }
        }
        stage('tng-sec-gtw') {
          steps {
            sh 'docker tag registry.sonata-nfv.eu:5000/tng-sec-gtw:latest registry.sonata-nfv.eu:5000/tng-sec-gtw:int'
            sh 'docker push  registry.sonata-nfv.eu:5000/tng-sec-gtw:int'
          }
        }
      }
    }
    stage('Deployment in Integration') {
      when {
         branch 'master'
      }      
      parallel {
        stage('Deployment in Integration') {
          steps {
            echo 'Deploying in integration...'
          }
        }
        stage('Deploying') {
          steps {
            sh 'rm -rf tng-devops || true'
            sh 'git clone https://github.com/sonata-nfv/tng-devops.git'
            dir(path: 'tng-devops') {
              sh 'ansible-playbook roles/sp.yml -i environments -e "target=int-sp-ath.5gtango.eu component=gatekeeper"'
              sh 'ansible-playbook roles/vnv.yml -i environments -e "target=int-vnv.5gtango.eu component=gatekeeper"'
            }
          }
        }
      }
    }
    stage('Promoting release v5.0') {
      when {
        branch 'v5.0'
      }
      stages {
        stage('Generating release') {
          steps {
            sh 'docker tag registry.sonata-nfv.eu:5000/tng-api-gtw:latest registry.sonata-nfv.eu:5000/tng-api-gtw:v5.0'
            sh 'docker tag registry.sonata-nfv.eu:5000/tng-api-gtw:latest sonatanfv/tng-api-gtw:v5.0'
            sh 'docker push registry.sonata-nfv.eu:5000/tng-api-gtw:v5.0'
            sh 'docker push sonatanfv/tng-api-gtw:v5.0'
            sh 'docker tag registry.sonata-nfv.eu:5000/tng-sec-gtw:latest registry.sonata-nfv.eu:5000/tng-sec-gtw:v5.0'
            sh 'docker tag registry.sonata-nfv.eu:5000/tng-sec-gtw:latest sonatanfv/tng-sec-gtw:v5.0'
            sh 'docker push registry.sonata-nfv.eu:5000/tng-sec-gtw:v5.0'
            sh 'docker push sonatanfv/tng-sec-gtw:v5.0'
          }
        }
        stage('Deploying in v5.0 servers') {
          steps {
            sh 'rm -rf tng-devops || true'
            sh 'git clone https://github.com/sonata-nfv/tng-devops.git'
            dir(path: 'tng-devops') {
              sh 'ansible-playbook roles/sp.yml -i environments -e "target=sta-sp-v5-0 component=gatekeeper"'
              sh 'ansible-playbook roles/vnv.yml -i environments -e "target=sta-vnv-v5-0 component=gatekeeper"'
            }
          }
        }
      }
    }
  }
  post {
    success {
      emailext(subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'", body: """<p>SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                        <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""", recipientProviders: [[$class: 'DevelopersRecipientProvider']])
      
    }
    
    failure {
      emailext(subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'", body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                        <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""", recipientProviders: [[$class: 'DevelopersRecipientProvider']])
      
    }
    
  }
}
