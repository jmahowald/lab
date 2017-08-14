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


IF deleting, go down to the individual layers (layers-${ENV_NAME}/<layername>)
and run make clean


for the vpc/elb layer it will first have to have the s3 bucket for elb logs emptied


`aws s3 rm --recursive s3://elb.logs.$TF_VAR_zone_name`