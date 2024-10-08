# Welcome to the Auth Workshop!

This workshop (or series of workshops) is designed as an opinionated and "hands
on" playground for reproducing customer environments on a desktop, trying
different authentication mechanisms, and learning about auth and our products
through that process!!

What it is not:
- an introduction to our professional products. For this, see #team-admin-training
- a theoretical overview of the different auth providers and how they work. For
  this, see [this
  writeup](https://docs.google.com/document/d/1ZGEeCsGoNGVKgmRPQCPISozXXdDwtuK3HqNhpZP7TOo/edit?usp=sharing)
- a practical overview of how auth providers work with our professional
  products. For this, see [this page](https://solutions.rstudio.com/auth/overview/)
- a "full" customer environment. For this, see
  [https://github.com/rstudio/sol-eng-terraform](https://github.com/rstudio/sol-eng-terraform)

What it is:
- I want to set up SAML in 1 minute to see if I can reproduce a customer
  problem
- Let me try this `ldapsearch` command to be sure it works the way I thought
- I have some time. Let me try to configure RStudio Server Pro to use SAML for
  myself
- What happens if I tweak this nginx configuration?
- I either use `docker` or am interested in learning more about `docker`

# Sounds Fun! What's next!?

Let's get started!

<!--toc-->

Rough ordering. The first two introduce most concepts.  Global tips throughout.

1. [Get Started](./get_started.md)
1. [SAML](./saml.md)
1. [Kerberos](./kerberos.md)
1. [Proxy](./proxy.md)
1. [LDAP](./ldap.md)
1. [Jupyter](./jupyter.md)
1. [Kubernetes](./k8s.md)
<!--end toc-->

# What about past workshops?

You can definitely follow the instructions above solo or buddied up with
someone else. Please feel free to ask questions in `#auth-workshop`.

If you want a "video walkthrough" along with some common problems / pain
points, then you can have a look at our past recordings! We will also announce
future meetings in `#auth-workshop`

## Recordings

- [2020-06-17 - Getting
  Started](https://drive.google.com/file/d/1yEFzh4A0sGa7j1Tpk-HuY3JFiaMP1wtZ/view?usp=sharing)
- [2020-07-02 -
  Kerberos](https://drive.google.com/file/d/1ogotNEVLQ-XrQtD__8vsYSHrfklbPjLx/view?usp=sharing)
- [2020-07-23 - Proxies](https://drive.google.com/file/d/1kFxPdvfbSTuTvDnSybLqhO16UWpsn6PV/view?usp=sharing)
- [2021-02-09 - Jupyter](https://drive.google.com/file/d/1MjC3I0e67Kp4BZp4vZNWms0QZIndQNQo/view?usp=sharing)
