ansiColor('xterm') {
  stage('test') {
    node('docker') {
      checkout scm
      print "Building environment"
      sh "make test-env-up kerb-server-up kerb-ssh-up proxy-kerb-up kerb-rsp-build"
      print "Running Kerberos RStudio tests"
      sh "make kerb-rsp-test"
      print "Cleanup environment"
      sh "make kerb-server-down"
      print "Finished"
    }
  }
}
