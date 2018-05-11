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
git clone https://github.com/sonata-nfv/tng-api-gtw.git
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

The current version supports an `api_root` like `http://pre-int-ath.5gtango.eu:32002`.

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
$ curl -X POST {api_root}/api/v3/packages -F "package=@./5gtango-ns-package-example.tgo"
```

 The `package` field is the only one that is mandatory, but there are a number of optional ones that you can check [here](https://github.com/sonata-nfv/tng-sdk-package).

$ http -f POST http://pre-int-sp-ath.5gtango.eu:32002/api/v3/packages package@../tng-api-gtw/tests/integration/fixtures/5gtango-ns-package-example.tgo
HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked
X-Timing: 0.057629

{
    "package_process_uuid": "b295e010-1fbc-4ff7-922a-a1703295f63f"
}

MacBook-Pro-2:tng-gtk-common jbonnet$ http pre-int-sp-ath.5gtango.eu:32002/api/v3/packages/status/b295e010-1fbc-4ff7-922a-a1703295f63f
HTTP/1.1 200 OK
Content-Length: 3592
X-Timing: 0.065799991
connection: close
content-type: application/json
x-content-type-options: nosniff

{
    "event_name": "onPackageChangeEvent", 
    "package_id": "d367ed3b-e401-48be-af96-fc03487b12b5", 
    "package_location": "http://tng-cat:4011/catalogues/api/v2/packages/d367ed3b-e401-48be-af96-fc03487b12b5", 
    "package_metadata": {
        "description": "This is an example 5GTANGO network service package.", 
        "descriptor_schema": "https://raw.githubusercontent.com/sonata-nfv/tng-schema/master/package-specification/napd-schema.yml", 
        "error": null, 
        "logo": "Icons/upb_logo.png", 
        "maintainer": "Manuel Peuster, Paderborn University", 
        "metadata": {
            "_napd_path": "/tmp/tmptouikyym/5gtango-ns-package-example/TOSCA-Metadata/NAPD.yaml", 
            "_storage_generic_files": {
                "LICENSE": "a1fd38b5-e61b-483e-9b6b-2edaa2166066", 
                "cloud.init": "8339a0a3-cb78-4583-af92-2d625802da89", 
                "upb_logo.png": "d017a079-16c3-4def-96db-b48ccf67ac15"
            }, 
            "_storage_location": "http://tng-cat:4011/catalogues/api/v2/packages/d367ed3b-e401-48be-af96-fc03487b12b5", 
            "_storage_pkg_file": "b3ece755-a799-4414-b33f-e39141faa63b", 
            "_storage_uuid": "d367ed3b-e401-48be-af96-fc03487b12b5", 
            "etsi": [
                {
                    "ns_package_version": "0.1", 
                    "ns_product_name": "ns-package-example", 
                    "ns_provider_id": "eu.5gtango", 
                    "ns_release_date_time": "2009-01-01T10:01:02Z"
                }, 
                {
                    "Algorithm": "SHA-256", 
                    "Hash": "a3734cb3eeaa18dee2daf7f2538c4c3be185bead6fc5a28729f44bf78f2b8af8", 
                    "Source": "Definitions/mynsd.yaml"
                }, 
                {
                    "Algorithm": "SHA-256", 
                    "Hash": "44fc832e0be9c78d8a59d8b57abd8d8f47e6b2e5e7ed264f111e51d3413f911b", 
                    "Source": "Definitions/myvnfd.yaml"
                }, 
                {
                    "Algorithm": "SHA-256", 
                    "Hash": "dd83757e632740f9f390af15eeb8bc25480a0c412c7ea9ac9abbb0e5e025e508", 
                    "Source": "Icons/upb_logo.png"
                }, 
                {
                    "Algorithm": "SHA-256", 
                    "Hash": "e26ff11f2cd2efc1eed3a47a94fccbf6fc8d0c844ff15b65aeb02576c1d02640", 
                    "Source": "Images/mycloudimage.ref"
                }, 
                {
                    "Algorithm": "SHA-256", 
                    "Hash": "179f180ea1630016d585ff32321037b18972d389be0518c0192021286c4898ca", 
                    "Source": "Licenses/LICENSE"
                }, 
                {
                    "Algorithm": "SHA-256", 
                    "Hash": "e16360cc3518bde752ac2d506e6bdb6bcb6638a0f94df9ea06975ae910204277", 
                    "Source": "Scripts/cloud.init"
                }
            ], 
            "tosca": [
                {
                    "CSAR-Version": "1.0", 
                    "Created-By": "Manuel Peuster (Paderborn University)", 
                    "Entry-Change-Log": "ChangeLog.txt", 
                    "Entry-Definitions": "Definitions/mynsd.yaml", 
                    "Entry-Licenses": "Licenses", 
                    "Entry-Manifest": "mynsd.mf", 
                    "TOSCA-Meta-Version": "1.0"
                }, 
                {
                    "Content-Type": "application/vnd.5gtango.napd", 
                    "Name": "TOSCA-Metadata/NAPD.yaml"
                }
            ]
        }, 
        "name": "ns-package-example", 
        "package_content": [
            {
                "algorithm": "SHA-256", 
                "content-type": "application/vnd.5gtango.nsd", 
                "hash": "a3734cb3eeaa18dee2daf7f2538c4c3be185bead6fc5a28729f44bf78f2b8af8", 
                "source": "Definitions/mynsd.yaml", 
                "tags": [
                    "eu.5gtango"
                ]
            }, 
            {
                "algorithm": "SHA-256", 
                "content-type": "application/vnd.5gtango.vnfd", 
                "hash": "44fc832e0be9c78d8a59d8b57abd8d8f47e6b2e5e7ed264f111e51d3413f911b", 
                "source": "Definitions/myvnfd.yaml", 
                "tags": [
                    "eu.5gtango"
                ]
            }, 
            {
                "algorithm": "SHA-256", 
                "content-type": "image/png", 
                "hash": "dd83757e632740f9f390af15eeb8bc25480a0c412c7ea9ac9abbb0e5e025e508", 
                "source": "Icons/upb_logo.png"
            }, 
            {
                "algorithm": "SHA-256", 
                "content-type": "application/vnd.5gtango.ref", 
                "hash": "e26ff11f2cd2efc1eed3a47a94fccbf6fc8d0c844ff15b65aeb02576c1d02640", 
                "source": "Images/mycloudimage.ref"
            }, 
            {
                "algorithm": "SHA-256", 
                "content-type": "text/plain", 
                "hash": "179f180ea1630016d585ff32321037b18972d389be0518c0192021286c4898ca", 
                "source": "Licenses/LICENSE"
            }, 
            {
                "algorithm": "SHA-256", 
                "content-type": "text/x-shellscript", 
                "hash": "e16360cc3518bde752ac2d506e6bdb6bcb6638a0f94df9ea06975ae910204277", 
                "source": "Scripts/cloud.init"
            }
        ], 
        "package_type": "application/vnd.5gtango.package.nsp", 
        "release_date_time": "2009-01-01T10:01:02Z", 
        "vendor": "eu.5gtango", 
        "version": "0.1"
    }, 
    "package_process_status": "success", 
    "package_process_uuid": "b295e010-1fbc-4ff7-922a-a1703295f63f"
}

##### Querying a package

A package meta-data can be queried like the following.

```shell
$ curl <api_root>/api/v3/packages/d367ed3b-e401-48be-af96-fc03487b12b5
```
Check [this gist](https://gist.github.com/jbonnet/af2ba6c78bada133fcca9c67c5bc84bd) for an example of the answer.

Besides the package meta-data, it's file can also be fetched:

```shell
$ curl <api_root>/api/v3/packages/d367ed3b-e401-48be-af96-fc03487b12b5/package-file
```

##### Querying multiple packages

```shell
$ curl -H 'Content-type:application/json' <api_root>/api/v3/packages
```

Check [this gist](https://gist.github.com/jbonnet/b8c4546e4fa2be4c3942c07357bc8d74) for an example of the answer.
  
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
