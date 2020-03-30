ansiColor('xterm') {
  stage('test') {
    node('docker') {
      checkout scm
      try {
      print "Building environment"
      sh "make test-env-up kerb-server-up kerb-ssh-up proxy-kerb-up kerb-rsp-build kerb-connect-build"
      sh "sleep 10"
      print "Running Kerberos RStudio tests"
      sh "make kerb-rsp-test"
      print "Running Kerberos Connect tests"
      sh "make kerb-connect-test"
      print "Cleanup environment"
      sh "make proxy-kerb-down kerb-ssh-down kerb-server-down test-env-down"
      print "Finished"
      } catch(err) {
        print "${err}"
        sh "make proxy-kerb-down kerb-ssh-down kerb-server-down test-env-down"
      }
    }
  }
}
