pipeline {
  agent any
  stages {
    stage('copia do grafana image') {
      steps {
        git(url: 'https://github.com/grafana/grafana.git', branch: 'main')
      }
    }

  }
}