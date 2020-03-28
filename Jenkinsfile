ansiColor('xterm') {
  stage('test') {
    node('docker') {
      checkout scm
      try {
      print "Building environment"
      sh "make test-env-up kerb-server-up kerb-ssh-up proxy-kerb-up kerb-rsp-build"
      print "Running Kerberos RStudio tests"
      sh "sleep 10"
      sh "make kerb-rsp-test"
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
