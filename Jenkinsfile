ansiColor('xterm') {
  stage('test') {
    parallel 'kerberos': {
      node('docker') {
        checkout scm
        //======================= BEGIN: Kerberos tests ================================
        print "==> BEGIN: Kerberos tests"
        try {
        print "====> Building environment"
        sh "make test-env-up"
        sh "make kerb-server-up kerb-ssh-up proxy-kerb-up kerb-rsp-build kerb-connect-build"
        sh "sleep 10"
        print "====> Running Kerberos RStudio tests"
        sh "make kerb-rsp-test"
        print "====> Running Kerberos Connect tests"
        sh "make kerb-connect-test"
        } catch(err) {
          print "${err}"
        } finally {
          print "====> Cleanup environment"
          sh "make proxy-kerb-down kerb-ssh-down kerb-server-down kerb-rsp-down kerb-connect-down"
          sh "make test-env-down"
        }
        print "==> END: Kerberos tests"
        //======================= END: Kerberos tests ================================
        print "Finished"
      }
    },
    'ldap': {
      node('docker') {
        checkout scm
        //======================= BEGIN: LDAP tests ================================
        print "==> BEGIN: LDAP tests"
        try {
        print "====> Building environment"
        sh "make test-env-up"
        sh "make ldap-server-up ldap-rsp-build"
        sh "sleep 10"
        } catch(err) {
          print "${err}"
        } finally {
          print "====> Cleanup environment"
          sh "make ldap-server-down ldap-rsp-down"
          sh "make test-env-down"
        }
        print "==> END: LDAP tests"
        //======================= END: LDAP tests ================================
        print "Finished"
      }
    },
    'saml': {
      node('docker') {
        checkout scm
        //======================= BEGIN: SAML tests ================================
        print "==> BEGIN: SAML tests"
        try {
        print "====> Building environment"
        sh "make test-env-up"
        sh "make saml-idp-up"
        sh "sleep 10"
        } catch(err) {
          print "${err}"
        } finally {
          print "====> Cleanup environment"
          sh "make saml-idp-down"
          sh "make test-env-down"
        }
        print "==> END: SAML tests"
        //======================= END: SAML tests ================================
        print "Finished"
      }
    },
    'proxy': {
      node('docker') {
        checkout scm
        //======================= BEGIN: Proxy tests ================================
        print "==> BEGIN: Proxy tests"
        try {
        print "====> Building environment"
        sh "make test-env-up"
        sh "make proxy-saml-up proxy-basic-up"
        sh "sleep 10"
        } catch(err) {
          print "${err}"
        } finally {
          print "====> Cleanup environment"
          sh "make proxy-basic-down proxy-saml-down"
          sh "make test-env-down"
        }
        print "==> END: Proxy tests"
        //======================= END: Proxy tests ================================
        print "Finished"
      }
    }
  }
}
