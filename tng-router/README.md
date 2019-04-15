[![Build Status](https://jenkins.sonata-nfv.eu/buildStatus/icon?job=tng-api-gtw/master)](https://jenkins.sonata-nfv.eu/job/tng-api-gtw/master)
[![Join the chat at https://gitter.im/5gtango/tango-schema](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/5gtango/tango-schema)

<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>

# API Router
This is the 5GTANGO Gatekeeper API Router for the Verification&amp;Validation and Service Platforms (built on top of [SONATA](https://github.com/sonata-nfv)) component. It is deployed in the two different kinds of platforms, with two different configurations.

## Supported endpoints
Supported endpoints, alphabetically sorted and with the indication of the platform in which it is available, are the following.

**Endpoints**|**Description**|**V&V**|**SP**
:----|:----:|:---:|:---:
`/`|The root of the API.|x|x
`/api/v3`|The v3 root of the API.|x|x
`/api/v3/functions`|The list of available functions (VNFs) in the Catalogue.|x|x
`/api/v3/packages`||x|x
`/api/v3/pings`||x|x 
`/api/v3/policies`|||x
`/api/v3/policies/placement`|||x
`/api/v3/records/functions`|The list of function records available in the Repository.||x
`/api/v3/records/services`|The list of service records available in the Repository.||x
`/api/v3/requests`|||x
`/api/v3/services`||x|x
`/api/v3/settings/platforms`||x|
`/api/v3/settings/vims`|||x
`/api/v3/settings/wims`|||x
`/api/v3/slas/agreements`|||x
`/api/v3/slas/configurations`|||x
`/api/v3/slas/licenses`|||x
`/api/v3/slas/templates`|||x
`/api/v3/slas/violations`|||x
`/api/v3/slices`|||x
`/api/v3/slice-instances`|||x
`/api/v3/tests`||x|
`/api/v3/tests/descriptors`||x|
`/api/v3/tests/plans`||x|
`/api/v3/tests/results`||x|
`/api/v3/users`||x|x
`/api/v3/users/roles`||x|x
`/api/v3/users/sessions`||x|x

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







## Api Reference

The current version supports an `api_root` like `http://pre-int-sp-ath.5gtango.eu:32002`.
We have specified this micro-service's API in a [swagger](https://github.com/sonata-nfv/tng-gtk-vnv/blob/master/doc/swagger.json)-formated file. Please check it there.

### Authentication and authorization
TBD

### Packages
Packages constitute the unit for uploading information into the [Catalogue](http://github.com/sonata-nfv/tng-cat).

You can get examples of packages [here (the good one)](https://github.com/sonata-nfv/tng-sdk-package/blob/master/misc/5gtango-ns-package-example.tgo) and [here (the malformed one)](https://github.com/sonata-nfv/tng-sdk-package/blob/master/misc/5gtango-ns-package-example-malformed.tgo).

#### On-boarding
On-boarding (i.e., uploading) a package is an **asynchronous** process that involves several components until the package is stored in the [Catalogue](http://github.com/sonata-nfv/tng-cat) (please see the wiki for details).

1. the [API Gateway](https://github.com/sonata-nfv/tng-api-gtw/) component;
1. this component, the [Gatekeeper Common](https://github.com/sonata-nfv/tng-gtk-common/);
1. the [Packager](https://github.com/sonata-nfv/tng-sdk-package) component;
1. and the already mentioned [Catalogue](http://github.com/sonata-nfv/tng-cat).

On-boarding a package can be done by the following command:

```shell
$ curl -X POST :api_root/api/v3/packages -F "package=@./5gtango-ns-package-example.tgo"
```

The `package` field is the only one that is mandatory, but there are a number of optional ones that you can check [here](https://github.com/sonata-nfv/tng-sdk-package).

```json
{
    "package_process_uuid": "b295e010-1fbc-4ff7-922a-a1703295f63f"
}
```

This `package_process_uuid` can be used to query the package processing status (see below).

#### Querying

We may query the on-boarding process by issuing

```shell
$ curl :api_root/api/v3/packages/status/b295e010-1fbc-4ff7-922a-a1703295f63f
```

The `package_process_uuid` is the value obtained when a package has been submitted successfuly (see above). Check [this gist](https://gist.github.com/jbonnet/5fea8faddba2bb54dcb42518622d2556) for an example of the answer. This answer will have the `package_uuid` that can be used to query the package (used below).

A package meta-data can be queried like the following:

```shell
$ curl :api_root/api/v3/packages/d367ed3b-e401-48be-af96-fc03487b12b5
```
Check [this gist](https://gist.github.com/jbonnet/af2ba6c78bada133fcca9c67c5bc84bd) for an example of the answer.

Besides the package meta-data, it's file can also be fetched:

```shell
$ curl :api_root/api/v3/packages/d367ed3b-e401-48be-af96-fc03487b12b5/package-file
```

Querying all existing packages can be done using the following command

```shell
$ curl :api_root/api/v3/packages
```

Check [this gist](https://gist.github.com/jbonnet/b8c4546e4fa2be4c3942c07357bc8d74) for an example of the answer.
  
If different default values for the starting page number and the number of records per page are needed, these can be used as query parameters:

```shell
$ curl ":api_root/api/v3/packages?page_size=20&page_number=2"
```

Note the `""` used around the command, in order for the `shell` used to consider the `&` as part of the command, instead of considering it a background process command.

In case we want to download the package's file, we can use the following command:

```shell
$ curl :api_root/api/v3/packages/:package_uuid/package-file
```

Expected returned data is:

* `HTTP` code `200` (`Ok`) if the package is found, with the package's file in the body (binary format);
* `HTTP` code `400` (`Bad Request`), if the `:package_uuid` is mal-formed;
* `HTTP` code `404` (`Not Found`), if the package is not found.

In case we want to download the any of the other files the package may contain, we can use the following command, where the `:file_uuid` can be fetched from the packages metada:

```shell
$ curl :api_root/api/v3/packages/:package_uuid/files/:file_uuid
```

Expected returned data is:

* `HTTP` code `200` (`Ok`) if the file is found, with its content in the body (binary format);
* `HTTP` code `400` (`Bad Request`), if the `:package_uuid` or `:file_uuid` is mal-formed;
* `HTTP` code `404` (`Not Found`), if the package or the file is not found.

#### Deleting
We may delete an on-boarded package by issuing the following command:

```shell
$ curl -X DELETE :api_root/api/v3/packages/:package_uuid
```

Expected returned data is:

* `HTTP` code `204` (`No Content`) if the package is found and successfuly deleted (the body will be empty);
* `HTTP` code `400` (`Bad Request`), if the `:package_uuid` is mal-formed;
* `HTTP` code `404` (`Not Found`), if the package is not found.

### Services 
Are are on-boarded within packages (see above), so one can not `POST`, `PUT`, `PATCH` or `DELETE` them.

#### Querying

Querying all existing services can be done using the following command (default values for `DEFAULT_PAGE_SIZE` and `DEFAULT_PAGE_NUMBER` mentioned above are used):

```shell
$ curl :api_root/api/v3/services
```

If different default values for the starting page number and the number of records per page are needed, these can be used as query parameters:

```shell
$ curl ":api_root/api/v3/services?page_size=20&page_number=2"
```

Note the `""` used around the command, in order for the `shell` used to consider the `&` as part of the command, instead of considering it a background process command.

Expected returned data is:

* `HTTP` code `200` (`Ok`) with an array of services' metadata in the body (`JSON` format), or an empty array (`[]`) if none is found according to the parameters passed;

A specific service's metadata can be fetched using the following command:

```shell
$ curl :api_root/api/v3/services/:service_uuid
```

Expected returned data is:

* `HTTP` code `200` (`Ok`) if the service is found, with the service's metadata in the body (`JSON` format);
* `HTTP` code `400` (`Bad Request`), if the `:service_uuid` is mal-formed;
* `HTTP` code `404` (`Not Found`), if the service is not found.

Check [this gist](https://gist.github.com/jbonnet/1887b09327ac9b0ebfcb000e283d79f3) for an example of the answer.







## Licensing

This 5GTANGO component is published under Apache 2.0 license. Please see the [LICENSE](https://github.com/sonata-nfv/tng-api-gtw/blob/master/LICENSE) file for more details.

