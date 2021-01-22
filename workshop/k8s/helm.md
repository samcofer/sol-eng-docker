# Helm

Getting started with Helm. Ideally you have already [gotten started with
Kubernetes](../k8s.md#getting-started-with-kubernetes) and have a development
environment functional.

Let's get started!

## What is Helm?

Helm is a Go-templating, packaging, and versioning tool for Kubernetes yaml
files. Say what?

### Go Templating

Go templating is a template syntax built into / on top of Golang (the programming language).
It uses Go syntax, parts of the Go standard library, and heavy use of braces (`{{` and `}}`) to
build / templatize documents.

When added to the world of Kubernetes YAML files, it allows things like:
  - parameterize your YAML
  - Be DRY ("don't repeat yourself") and reuse items
  - Make dynamic / run-time decisions

This unfortunately often comes at the cost of readability and simplicity.

### Packaging

Helm is oriented into packages that have versions. You can get the packages off of
your local filesystem or out of [repositories]().

This way, your kubernetes project (also known as a YAML-project)  becomes a
proper software project with [semantic versioning](), backwards compatibility
guarantees, etc.

## An example
