[![Build Status](https://jenkins.sonata-nfv.eu/buildStatus/icon?job=tng-api-gtw/master)](https://jenkins.sonata-nfv.eu/job/tng-api-gtw/master)
[![Join the chat at https://gitter.im/5gtango/tango-schema](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/5gtango/tango-schema)

<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>

# API Router
This is the 5GTANGO Gatekeeper API Router for the Verification&amp;Validation and Service Platforms (built on top of [SONATA](https://github.com/sonata-nfv)) component. It is deployed in the two different kinds of platforms, with two different configurations.

## Supported endpoints
Supported endpoints, alphabetically sorted and with the indication of the platform in which it is available, are the following.

### Service Platform
The entrypoints for the Service Platform are configured in the [config/sp_routes.yml](https://github.com/sonata-nfv/tng-api-gtw/blob/master/tng-router/config/sp_routes.yml) file.

**Endpoints**|**Description**
:----|:----
`/`|The root of the API.
`/api/v3`|The v3 root of the API.
`/api/v3/functions`|[Lists available functions (VNFs) in the Catalogue](https://github.com/sonata-nfv/tng-gtk-common/wiki/functions-querying)
`/api/v3/monitoring/data`|[Fetches different kinds of monitoring data](https://github.com/sonata-nfv/son-monitor/wiki/Usage-documentation)
`/api/v3/monitoring/graphs`|[Fetches different kinds of monitoring graphs](https://github.com/sonata-nfv/son-monitor/wiki/Usage-documentation)
`/api/v3/packages`|[Manages packages](https://github.com/sonata-nfv/tng-api-gtw/wiki/packages-management) (uploading, downloading, etc.)
`/api/v3/pings`|[The Gatekeeper's `readiness` and `liveness` endpoint](https://github.com/sonata-nfv/tng-api-gtw/wiki/readiness-liveliness-probe)
`/api/v3/policies`|[Manages placement and run-time policies](https://github.com/sonata-nfv/tng-api-gtw/wiki/Policies-usage)
`/api/v3/records/functions`|[Lists function records available in the Repository](https://github.com/sonata-nfv/tng-gtk-sp/wiki/function-records-queries)
`/api/v3/records/services`|[Lists service records available in the Repository](https://github.com/sonata-nfv/tng-gtk-sp/wiki/service-records-queries)
`/api/v3/requests`|[Manages services' and slices' lifecycle events](https://github.com/sonata-nfv/tng-api-gtw/wiki/Requests-management) (creation, scaling, deletion, etc.)
`/api/v3/services`|[Lists available services (NSs) in the Catalogue](https://github.com/sonata-nfv/tng-gtk-common/wiki/services-querying)
`/api/v3/settings`|[Manages different kinds of settings](https://github.com/sonata-nfv/tng-api-gtw/wiki/Settings-usage)
`/api/v3/settings/monitoring`|[Manages different kinds of monitoring settings](https://github.com/sonata-nfv/son-monitor/wiki/Usage-documentation)
`/api/v3/slas`|[Manages SLA aggreements, configurations, licenses, templates and violations](https://github.com/sonata-nfv/tng-sla-mgmt)
`/api/v3/slices`|[Manages slice templates](https://github.com/sonata-nfv/tng-slice-mngr)
`/api/v3/slice-instances`|[Lists slice instances](https://github.com/sonata-nfv/tng-slice-mngr) (creation and deletion are handled through requests) 
`/api/v3/users`|[Manages users](https://github.com/sonata-nfv/tng-api-gtw/wiki/users-management-usage)
`/api/v3/users/roles`|[List user's roles](https://github.com/sonata-nfv/tng-api-gtw/wiki/users-roles-listing-usage) (user's roles are defined together with [routes](https://github.com/sonata-nfv/tng-api-gtw/wiki/configure-new-routes))
`/api/v3/users/sessions`|[Manages user's sessions (logging in)](https://github.com/sonata-nfv/tng-api-gtw/wiki/users-management-usage#logging-in)

### Validation and Verification Platform
The entrypoints for the Validation and Verification Platform are configured in the [config/vnv_routes.yml](https://github.com/sonata-nfv/tng-api-gtw/blob/master/tng-router/config/vnv_routes.yml) file.

**Endpoints**|**Description**
:----|:----
`/`|The root of the API.
`/api/v3`|The v3 root of the API.
`/api/v3/functions`|[Lists available functions (VNFs) in the Catalogue](https://github.com/sonata-nfv/tng-gtk-common/wiki/functions-querying)
`/api/v3/monitoring/data`|[Fetches available monitoring data](https://github.com/sonata-nfv/son-monitor)
`/api/v3/monitoring/graphs`|[Fetches available monitoring graphs](https://github.com/sonata-nfv/son-monitor)
`/api/v3/packages`|[Manages packages](https://github.com/sonata-nfv/tng-api-gtw/wiki/packages-management) (uploading, downloading, etc.)
`/api/v3/pings`|[The Gatekeeper's `readiness` and `liveness` endpoint](https://github.com/sonata-nfv/tng-api-gtw/wiki/readiness-liveliness-probe)
`/api/v3/recommendations`|[Manages test recommendations](https://github.com/sonata-nfv/tng-vnv-dsm)
`/api/v3/services`|[Lists available services (NSs) in the Catalogue](https://github.com/sonata-nfv/tng-gtk-common/wiki/services-querying)
`/api/v3/settings/monitoring`|[Manages monitoring settings](https://github.com/sonata-nfv/son-monitor)
`/api/v3/settings/platforms`|[Manages different (testing) platforms](https://github.com/sonata-nfv/tng-api-gtw/wiki/Settings-usage)
`/api/v3/tests/descriptors`|[Lists available test descriptors (TDs) in the Catalogue](https://github.com/sonata-nfv/tng-gtk-vnv/wiki/test-descriptors-queries)
`/api/v3/tests/plans`|[Manages test plans](https://github.com/sonata-nfv/tng-vnv-planner)
`/api/v3/tests/results`|[Lists available test results (TRs) in the Repository](https://github.com/sonata-nfv/tng-gtk-vnv/wiki/test-results-queries)
`/api/v3/users`|[Manages users](https://github.com/sonata-nfv/tng-api-gtw/wiki/users-management-usage)
`/api/v3/users/roles`|[List user's roles](https://github.com/sonata-nfv/tng-api-gtw/wiki/users-roles-listing-usage) (user's roles are defined together with [routes](https://github.com/sonata-nfv/tng-api-gtw/wiki/configure-new-routes))
`/api/v3/users/sessions`|[Manages user's sessions (logging in)](https://github.com/sonata-nfv/tng-api-gtw/wiki/users-management-usage#logging-in)


## Installing / Getting started

This component is a [rack](https://rack.github.io/) application implemented in [ruby](https://www.ruby-lang.org/en/), version **2.4.3**, and is part of the [tng-api-gtw](https://github.com/sonata-nfv/tng-api-gtw).

### Installing from code

To have it up and running from code, please do the following:

```shell
$ git clone https://github.com/sonata-nfv/tng-api-gtw.git # Clone the parent repository
$ cd tng-api-gtw # Go to the newly created folder
$ bundle install # Install dependencies
$ PORT=5000 bundle exec rackup # dev server at http://localhost:5000
```

Everything being fine, you'll have a server running on that session, on port `5000`. You can use it by using `curl`, like in:

```shell
$ curl <host name>:5000/
```

### Installing from the Docker container
In case you prefer a `docker` based development, you can run the following commands (`bash` shell):

```shell
$ docker network create tango
$ docker run -d -p 27017:27017 --net=tango --name mongo mongo
$ docker run -d -p 4011:4011 --net=tango --name tng-cat sonatanfv/tng-cat:dev
$ docker run -d -p 4012:4012 --net=tango --name tng-rep sonatanfv/tng-rep:dev
$ docker run -d -p 5000:5000 --net=tango --name tng-gtk-vnv \
  -e CATALOGUE_URL=http://tng-cat:4011/catalogues/api/v2 \
  -e REPOSITORY_URL=http://tng-cat:4012 \
  sonatanfv/tng-gtk-vnv:dev
```
With these commands, you:

1. Create a `docker` network named `tango`;
1. Run the [MongoDB](https://www.mongodb.com/) container within the `tango` network;
1. Run the [Catalogue](https://github.com/sonata-nfv/tng-cat) container within the `tango` network;
1. Run the [Repository](https://github.com/sonata-nfv/tng-rep) container within the `tango` network;
1. Run the [V&V-specific Gatekeeper](https://github.com/sonata-nfv/tng-gtk-vnv) container within the `tango` network, with the `CATALOGUE_URL` and `REPOSITORY_URL` environment variables set to the previously created containers.

## Developing
This section covers all the needs a developer has in order to be able to contribute to this project.

### Built With
We are using the following libraries (also referenced in the [`Gemfile`](https://github.com/sonata-nfv/tng-gtk-vnv/Gemfile) file) for development:

* `puma` (`3.11.0`), an application server;
* `rack` (`2.0.4`), a web-server interfacing library, on top of which `sinatra` has been built;
* `rake`(`12.3.0`), a dependencies management tool for ruby, similar to *make*;
* `sinatra` (`2.0.2`), a web framework for implementing efficient ruby APIs;
* `sinatra-contrib` (`2.0.2`), several add-ons to `sinatra`;
* `sinatra-cross_origin` (`0.4.0`), a *middleware* to `sinatra` that helps in managing the [`Cross Origin Resource Sharing (CORS)`](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) problem;

The following *gems* (libraries) are used just for tests:
* `ci_reporter_rspec` (`1.0.0`), a library for helping in generating continuous integration (CI) test reports;
* `rack-test` (`0.8.2`), a helper testing framework for `rack`-based applications;
* `rspec` (`3.7.0`), a testing framework for ruby;
* `rubocop` (`0.52.0`), a library for white box tests; 
* `rubocop-checkstyle_formatter` (`0.4.0`), a helper library for `rubocop`;
* `webmock` (`3.1.1`), which alows *mocking* (i.e., faking) HTTP calls;

These libraries are installed/updated in the developer's machine when running the command (see above):

```shell
$ bundle install
```

### Prerequisites
We usually use [`rbenv`](https://github.com/rbenv/rbenv) as the ruby version manager, but others like [`rvm`](https://rvm.io/) may work as well.

### Setting up Dev
Developing this micro-service is straight-forward with a low amount of necessary steps.

Routes within the micro-service are defined in the [`config.ru`](https://github.com/sonata-nfv/tng-gtk-vnv/blob/master/config.ru) file, in the root directory. It has two sections:

* The `require` section, where all used libraries must be required (**Note:** `controllers` had to be required explicitly, while `services` do not, due to a bug we have found to happened in some of the environments);
* The `map` section, where this micro-service's routes are mapped to the controller responsible for it.

This new or updated route can then be mapped either into an existing controller or imply writing a new controller. This new or updated controller can use either existing or newly written services to fullfil it's role.

For further details on the micro-service's architecture please check the [documentation](https://github.com/sonata-nfv/tng-gtk-vnv/wiki/micro-service-architecture).

### Submiting changes
Changes to the repository can be requested using [this repository's issues](https://github.com/sonata-nfv/tng-gtk-vnv/issues) and [pull requests](https://github.com/sonata-nfv/tng-gtk-vnv/pulls) mechanisms.

## Versioning

The most up-to-date version is v4. For the versions available, see the [link to tags on this repository](https://github.com/sonata-nfv/tng-gtk-vnv/releases).

## Configuration
The configuration of the micro-service is done through just two environment variables, defined in the [Dockerfile](https://github.com/sonata-nfv/tng-gtk-vnv/blob/master/Dockerfile):

* `CATALOGUE_URL`, which should define the Catalogue's URL, where test descriptors are fetched from;
* `REPOSITORY_URL`, which should define the Repository's URL, where test plans and test results are fetched from;

## Tests
Unit tests are defined for both `controllers` and `services`, in the `/spec` folder. Since we use `rspec` as the test library, we configure tests in the [`spec_helper.rb`](https://github.com/sonata-nfv/tng-gtk-vnv/blob/master/spec/spec_helper.rb) file, also in the `/spec` folder.

To run these tests you need to execute the follwoing command:
```shell
$ CATALOGUE_URL=... REPOSITORY_URL=... bundle exec rspec spec
```
Wider scope (integration and functional) tests involving this micro-service are defined in [`tng-tests`](https://github.com/sonata-nfv/tng-tests).

## Style guide
Our style guide is really simple:

1. We try to follow a [Clean Code](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882) philosophy in as much as possible, i.e., classes and methods should do one thing only, have the least number of parameters possible, etc.;
1. we use two spaces for identation.

## Licensing

This 5GTANGO component is published under Apache 2.0 license. Please see the [LICENSE](https://github.com/sonata-nfv/tng-api-gtw/blob/master/LICENSE) file for more details.
