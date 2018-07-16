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

For further details on those components, please check their README files [here](https://github.com/sonata-nfv/tng-api-gtw/tree/master/tng-sec-gtw/README.md) and [here](https://github.com/sonata-nfv/tng-api-gtw/tree/master/tng-router/README.md).

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

## Database

This component does not use any database, it delegates to the remaining micro-services. 

## Licensing

For licensing issues, please check the [Licence](https://github.com/sonata-nfv/tng-api-gtw/blob/master/LICENSE) file.
