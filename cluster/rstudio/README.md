# Kerberos Authentication to RStudio #

This docker image installs RStudio Server Pro, as well as the necessary PAM and Kerberos tools to facilitate kerberos authentication.

## Getting Started ##

The license manager sees hardware and therefore will fail the trial license if you have ever had a trial license before.  As a result, you will either need an actual license to work with or you will need to go through the offline trial activation process at [http://apps.rstudio.com/trial-activation/](http://apps.rstudio.com/trial-activation/).  

## To Do ##

There is a strange issue occurring when logging into the server... An error modal pops up that says "RStudio Initialization Error: Unable to Connect to Service."  Nothing is captured in the logs, but a message comes through after refreshing, which seems to clear the problem.  Namely, the following.  (Please excuse any typos...)

```bash
[rsession-bobo] ERROR r error 4 (R code execution error) [errormsg=]; OCCURRED AT: rstudio::core::Error rstudio::r::exec::executeSafely(rstudio_boost::function<void()>) /home/ubuntu/rstudio-pro/src/cpp/r/RExec.cpp:212; LOGGED FROM: void rstudio::session::{anonymous}::processEvents() /home/ubuntu/rstudio-pro/src/cpp/session/SessionHttpMethods.cpp:91

ERROR system error 111 (Connection refused); OCCURRED AT: void rstudio::core::http::LocalStreamAsyncClient::handleConnect(const rstudio_boost::system::error_code&) /home/ubuntu/rstudio-pro/src/cpp/core/include/core/http/LocalStreamAsyncClient.hpp:119
```
