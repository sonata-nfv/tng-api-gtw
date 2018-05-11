[![Build Status](https://jenkins.sonata-nfv.eu/buildStatus/icon?job=tng-api-gtw/master)](https://jenkins.sonata-nfv.eu/job/tng-api-gtw/master)
[![Join the chat at https://gitter.im/5gtango/tango-schema](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/5gtango/tango-schema)

<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>


# 5GTANGO API Gateway
This is the 5GTANGO API Gateway for the Verification&amp;Validation and Service Platforms (built on top of [SONATA](https://github.com/sonata-nfv)) repository.

## Installing / Getting started

A quick introduction of the minimal setup you need to get a hello world up &
running.

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
git clone https://github.com/sonata-nfv/tng-gtk-common.git
cd tng-gtk-common/
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

1. `CATALOGUE_URL`, which defines the `URL` to reach the [Catalogue](http://github.com/sonata-nfv/tng-cat), e.g., `http://tng-cat:4011/catalogues/api/v2`;
1. `UNPACKAGER_URL`, which defines the `URL` to reach the [Packager](https://github.com/sonata-nfv/tng-sdk-package), e.g.,`http://tng-sdk-package:5099/api/v1/packages`

Optionally, you can also define the following `ENV` variables:

1. `INTERNAL_CALLBACK_URL`, which defines the `URL` for the [Packager](https://github.com/sonata-nfv/tng-sdk-package) component to notify this component about the finishing of the upload process, defaults to `http://tng-gtk-common:5000/packages/on-change`;
1. `EXTERNAL_CALLBACK_URL`, which defines the `URL` that this component should call, when  it is notified (by the [Packager](https://github.com/sonata-nfv/tng-sdk-package) component) that the package has been on-boarded, e.g.,`http://tng-vnv-lcm:6100/api/v1/packages/on-change`. See details on this component's [Design documentation wiki page](https://github.com/sonata-nfv/tng-gtk-common/wiki/design-documentation);
1. `DEFAULT_PAGE_SIZE`: defines the default number of 'records' that are returned on a single query, for pagination purposes. If absent, a value of `100` is assumed;
1. `DEFAULT_PAGE_NUMBER`: defines the default page to start showing the selected records (beginning at `0`), for pagination purposes. If absent, a value of `0` is assumed;

## Tests

Describe and show how to run the tests with code examples.
Explain what these tests test and why.

```shell
Give an example
```

### Unit tests



## Style guide

Explain your code style and show how to check it.

## Api Reference

This component's API is documented in a [Swagger 2.0 file](https://github.com/sonata-nfv/tng-gtk-common/blob/master/doc/swagger.json). The current version does not support any form of authentication, since it is supposed to work with the [API Gateway](https://github.com/sonata-nfv/tng-api-gtw/) component in fron of it.

The current version supports an `api_root` like `http://pre-int-ath.5gtango.eu:32003`.

### Packages
Packages constitute the unit for uploading information into the [Catalogue](http://github.com/sonata-nfv/tng-cat).

You can get examples of packages [here (the good one)](https://github.com/sonata-nfv/tng-sdk-package/blob/master/misc/5gtango-ns-package-example.tgo) and [here (the malformed one)](https://github.com/sonata-nfv/tng-sdk-package/blob/master/misc/5gtango-ns-package-example-malformed.tgo).

#### On-boarding
On-boarding (i.e., uploading) a package is an **asynchronous** process that involves several components until the package is stored in the [Catalogue](http://github.com/sonata-nfv/tng-cat):

1. the [API Gateway](https://github.com/sonata-nfv/tng-api-gtw/) component;
1. this component, the [Gatekeeper Common](https://github.com/sonata-nfv/tng-gtk-common/);
1. the [Packager](https://github.com/sonata-nfv/tng-sdk-package) component;
1. and the already mentioned [Catalogue](http://github.com/sonata-nfv/tng-cat).

On-boarding a package can be done by the following command:

```shell
$ curl -X POST {api_root}/api/v3/packages -F "package=@./5gtango-ns-package-example.tgo"
```

 The `package` field is the only one that is mandatory, but there are a number of optional ones that you can check [here](https://github.com/sonata-nfv/tng-sdk-package).
  
#### Querying

We may query the on-boarding process by issuing

```shell
$ curl {api_root}/api/v3/packages/status/:processing_uuid
```

Querying all existing packages can be done using the following command (default values for `DEFAULT_PAGE_SIZE` and `DEFAULT_PAGE_NUMBER` mentioned above are used):

```shell
$ curl {api_root}/api/v3/packages
```

If different default values for the starting page number and the number of records per page are needed, these can be used as query parameters:

```shell
$ curl "{api_root}/api/v3/packages?page_size=20&page_number=2"
```

A specific package's metadata can be fetched using the following command:

```shell
$ curl "{api_root}/api/v3/packages/:package_uuid"
```

In case we want to download the package's file, we can use the following command:

```shell
$ curl "{api_root}/api/v3/packages/:package_uuid/package-file"
```

## Database

Explaining what database (and version) has been used. Provide download links.
Documents your database design and schemas, relations etc... 

## Licensing

State what the license is and how to find the text version of the license.
