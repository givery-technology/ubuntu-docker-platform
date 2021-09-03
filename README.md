# Ubuntu Docker Platform
These are the files necessary to create a custom Elastic Beanstalk platform which runs a modern version of Docker inside of Ubuntu 16.04

This platform can be used to run any native, statically-linked binary applications. The application binaries are supervised by `systemd` and if they use `SO_REUSEPORT` when binding to a socket, they can be deployed in a zero-downtime manner.

A recent version of docker is installed on the OS as well, see [02-install-docker.sh](builder/setup-scripts/02-install-docker.sh) to view the specific version which is installed.

An environment variable, `PORT` is exposed to the binaries to use. You must bind to this port. Currently it is set to `5000`

Nginx runs on the host as well and proxies requests to `127.0.0.1:5000`

## Dependencies

All that is needed to create a new platform is the [elastic beanstalk CLI](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html)

## Build

You can follow the steps [here](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/custom-platforms.html) to create a custom platform. The CLI will automatically version new platforms, and when they're created successfully they'll be provided as an option when creating a new environment on this platform.

Be aware that the build process will leave a beanstalk environment running which is used to run Packer. You will have to kill this environment manually when the process is done.

### Build proccess samples (recommended)

```sh
$ export AWS_EB_PROFILE=orca
$ export AWS_EB_REGION=ap-northeast-1
$ ebp init

Select a default region
1) us-east-1 : US East (N. Virginia)
2) us-west-1 : US West (N. California)
3) us-west-2 : US West (Oregon)
4) eu-west-1 : EU (Ireland)
5) eu-central-1 : EU (Frankfurt)
6) ap-south-1 : Asia Pacific (Mumbai)
7) ap-southeast-1 : Asia Pacific (Singapore)
8) ap-southeast-2 : Asia Pacific (Sydney)
9) ap-northeast-1 : Asia Pacific (Tokyo)
10) ap-northeast-2 : Asia Pacific (Seoul)
11) sa-east-1 : South America (Sao Paulo)
12) cn-north-1 : China (Beijing)
13) cn-northwest-1 : China (Ningxia)
14) us-east-2 : US East (Ohio)
15) ca-central-1 : Canada (Central)
16) eu-west-2 : EU (London)
17) eu-west-3 : EU (Paris)
18) eu-north-1 : EU (Stockholm)
19) eu-south-1 : EU (Milano)
20) ap-east-1 : Asia Pacific (Hong Kong)
21) me-south-1 : Middle East (Bahrain)
22) af-south-1 : Africa (Cape Town)
(default is 3): 9


Select a platform to use
1) ubuntu-docker-platform
2) [ Create new Platform ]
(default is 1): 1

Would you like to be able to log into your platform packer environment?
(Y/n): Y

Select a keypair.
1) akihiro.miyashita
2) aws-eb
3) orca-codeprep-prod
4) orca-dev
5) orca-track-prod
6) orca-track-staging
7) [ Create new KeyPair ]
(default is 6): 4

$ # specify and execute new version.
$ ebp create 1.x.x
```

### How to test of build artifacts

An AMI will be created with the name `64bit Ubuntu xx.xx x.x.x running Docker`, and you can use it to create an EC2 instance and connect to it via SSH to check the environment. 

## Zero Downtime Deploys

This platform takes advantage of the `SO_REUSEPORT` socket option. The general strategy is as follows:

* Have two separate systemd services which point to the same binary `/var/app/current/application`. These are currently named `green` and `blue`
* On a deployment, we will copy the contents of the zip file to `/var/app/staging/`
* The application bundle should include a statically-linked native binary named `application`
* During deployment, the binary from staging will overwrite the "current" binary. The old binary continues to run.
* The new binary is started. If `green` was running, `blue` will be started. Vice-versa if `blue` was running
* The new binary binds to the same port as the old binary, and can start accepting connections
* A SIGINT signal is sent to the old binary. In order for zero downtime deployments to work, the application must catch this signal and stop listening to the socket.
* The old binary can continue servicing existing HTTP requests and WebSocket connections. Ideally it will finish up all HTTP requests, and for WebSocket connections it should tell the clients the server will be shutting down. This gives clients a chance to gracefully disconnect and reconnect to the new binary.
* Once all connections are gone (or a timeout is reached, currently 90 seconds defined [here](builder/platform-uploads/etc/systemd/system/blue.service) in `TimeoutStopSec`), the process exits (or is sent SIGKILL after the timeout)
* The new binary is running while all this is happening, and once the old binary exits the deployment is complete
