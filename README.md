This project  uses some extremely convoluted logic to use terraform in mutiple layers.  It uses .envrc to load enviroment variables.

Copy .env-sample to .env and change appropriately.


Run the ./workstation to be popped into a docker container  with the aws cli, terraform and a 
terribly hacky thing called formterra.


Through Makefiles and some generation, we are able to more easily piecemeal environment with terraform layers


to preview building a layer

run

`make build-$ENV_NAME/<layername>.plan`

to actually create it run


`make build-$ENV_NAME/<layername>.apply`
