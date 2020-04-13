ansiColor('xterm') {
  stage('test') {
    node('docker') {
      checkout scm
      //======================= BEGIN: Kerberos tests ================================
      print "==> BEGIN: Kerberos tests"
      try {
      print "====> Building environment"
      sh "make test-env-up kerb-server-up kerb-ssh-up proxy-kerb-up kerb-rsp-build kerb-connect-build"
      sh "make ldap-server-up ldap-rsp-build"
      sh "sleep 10"
      print "====> Running Kerberos RStudio tests"
      sh "make kerb-rsp-test"
      print "====> Running Kerberos Connect tests"
      sh "make kerb-connect-test"
      } catch(err) {
        print "${err}"
      } finally {
        print "====> Cleanup environment"
        sh "make proxy-kerb-down kerb-ssh-down kerb-server-down kerb-rsp-down kerb-connect-down test-env-down"
        sh "make ldap-server-down ldap-rsp-down"
      }
      print "==> END: Kerberos tests"
      //======================= END: Kerberos tests ================================
      print "Finished"
    }
  }
}
