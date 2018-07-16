[![Build Status](https://jenkins.sonata-nfv.eu/buildStatus/icon?job=tng-api-gtw/master)](https://jenkins.sonata-nfv.eu/job/tng-api-gtw/master)
[![Join the chat at https://gitter.im/5gtango/tango-schema](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/5gtango/5gtango-sp)

<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>

# 5GTANGO API Gateway
This is the 5GTANGO API Gateway for the Verification&amp;Validation and Service Platforms (built on top of [SONATA](https://github.com/sonata-nfv)) repository.

Please see [details on the overall 5GTANGO architecture here](https://5gtango.eu/project-outcomes/deliverables/2-uncategorised/31-d2-2-architecture-design.html). 

## How does this work?

This component has the follwoing architecture:

<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/api_gtw.png" /></p>

All external requests enter the [security gateway](https://github.com/sonata-nfv/tng-api-gtw/tree/master/tng-sec-gtw), where they are redirected to the adequate port and to the [router](https://github.com/sonata-nfv/tng-api-gtw/tree/master/tng-router) component, where the request is delivered to the pre-defined component.

For further details on those components, please check their README files:

* [tng-common](https://github.com/sonata-nfv/tng-gtk-common/);
* [tng-gtk-sp](https://github.com/sonata-nfv/tng-gtk-sp);
* [tng-gtk-vnv](https://github.com/sonata-nfv/tng-gtk-vnv);
* [tng-policy-mngr](https://github.com/sonata-nfv/tng-policy-mngr);
* [tng-sla-mgmt](https://github.com/sonata-nfv/tng-sla-mgmt);
* [tng-slice-mngr](https://github.com/sonata-nfv/tng-slice-mngr);
* [tng-vnv-lcm](https://github.com/sonata-nfv/tng-vnv-lcm);
* [tng-vnv-tee](https://github.com/sonata-nfv/tng-vnv-tee);

```shell
commands here
```

Here you should say what actually happens when you execute the code above.

## Developing

### Built With
List main libraries, frameworks used including versions (React, Angular etc...)

### Prerequisites
What is needed to set up the dev environment. For instance, global dependencies or any other tools. include download links.


### Setting up Dev

This component has been developed in [ruby](https://ruby-lang.org), version `2.4.3`.

To get the code of this compoent you should execute the following `shell` commands:

```shell
git clone https://github.com/sonata-nfv/tng-api-gtw.git
cd tng-api-gtw/
bundle install
```

And state what happens step-by-step. If there is any virtual environment, local server or database feeder needed, explain here.

### Deploying / Publishing
give instructions on how to build and release a new version
In case there's some step you have to take that publishes this project to a
server, this is the right time to state it.

```shell
packagemanager deploy your-project -s server.com -u username -p password
```

And again you'd need to tell what the previous code actually does.

## Versioning

We can maybe use [SemVer](http://semver.org/) for versioning. For the versions available, see the [link to tags on this repository](/tags).


## Configuration

This component's configuration is done strictly through `ENV` variables.

The following `ENV` variables must be defined:

1. `PORT`, which sets the HTTP port to `5000`;
1. `ROUTES_FILE`, which sets the name of the file defining active routes as `sp_routes.yml` (the default name, for the Service Platform; for the V&V Platform, the deployment defines this `ENV` variable as `vnv_routes.yml`).

## Tests

**Unit** tests can be ran by executing the following set of commands:

```shell
$ cd tng-router
$ bundle exec rspec spec/
```

**Smoke** (end-to-end) tests can be executed by running
```shell
$ cd tests/integration
$ ./functionaltests.sh
```

## Style guide

Explain your code style and show how to check it.

## Api Reference

The current version supports an `api_root` like `http://pre-int-sp-ath.5gtango.eu:32002`.

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

## Database

This component does not use any database, it delegates to the remaining micro-services. 

## Licensing

For licensing issues, please check the [Licence](https://github.com/sonata-nfv/tng-api-gtw/blob/master/LICENSE) file.
