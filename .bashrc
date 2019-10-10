
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.

export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

# =============================================================================
#                                   Variables
# =============================================================================
export AWS_ACCESS_KEY_ID=AKIAJ5EA5F35HQQLFI2Q
export AWS_SECRET_ACCESS_KEY=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
export AWS_REGION=us-east-1

# rails development
export DATABASE_URL=postgres://vetsprevail:password@localhost:5432/phs_development
export FIREBASE_SERVER_TOKEN=AAAAY-w1XV8:APA91bFELluML-RN_ctMv2aqpfZ9VjzvsE7mSSNvLZCRk8_-S0P5rUnRBbT_ds5X12MT2vn92bvl_S0UQrOrZX6Mz2wLA4YmkLRPWFyzns_CbMoJMmBURRAtQdvvFlIRiwly7_vQJW1RKUWF-6LNl2mDcXWenH7nEw
export FIREBASE_BASE_URL=prevailhs-kibble-5c36e
export FIREBASE_API_KEY=AIzaSyCzVjl6GQu9smvaUOmRXsbOlpna908PXY4
export GOOGLE_APPLICATION_CREDENTIALS=application_default_credentials.json

# =============================================================================
#                                   Aliases
# =============================================================================
alias l='colorls --group-directories-first --almost-all'
alias ll='colorls --group-directories-first --almost-all --long'
alias cdw="cd /Volumes/Workshop"
alias cdr="cd /Volumes/Workshop/repos"
alias phsp="cd /Volumes/Workshop/repos/phs-platform"
alias phsc="cd /Volumes/Workshop/repos/phs-client"
alias phsk="cd /Volumes/Workshop/repos/phs-kube"
alias phsg="cd /Volumes/Workshop/repos/phs-garden"
alias phscorp="cd /Volumes/Workshop/repos/phs-corporate"
alias deployer="ssh deployer"
alias cmsk="ssh -i /Volumes/Workshop/certs/bniu.pem ubuntu@ec2-34-227-80-111.compute-1.amazonaws.com"
alias cmsp="ssh batend@ec2-54-166-63-73.compute-1.amazonaws.com"
alias sshgl="ssh -i /Volumes/Workshop/certs/bniu.pem ubuntu@ec2-54-147-231-215.compute-1.amazonaws.com"
alias sshaa1="ssh benniu@40.67.176.20"

## Kubernetes
alias hm="helm"
alias mk="minikube"
alias kdump="kubectl get all --all-namespaces"

kphs() {
  kubectl --namespace phs-k8s "$@";
}
kphsb() {
  kubectl --namespace phs-k8s-bniu "$@";
}
# base64 encryption
enc64() {
  echo -n $1 | base64;
}
# helm with tls flag
hmt() {
  helm $1 --tls 
}

## Azure
# postgresql db service
# - kibble
alias psqlkadmin="psql 'host=phs-platform-kibble.postgres.database.azure.com port=5432 dbname=postgres user=phsdbadmin@phs-platform-kibble sslmode=verify-full sslrootcert=/Volumes/Workshop/certs/Azure/root.crt'"
alias psqlk="psql 'host=phs-platform-kibble.postgres.database.azure.com port=5432 dbname=phs_db_main user=phs_platform@phs-platform-kibble sslmode=verify-full sslrootcert=/Volumes/Workshop/certs/Azure/root.crt'"
# - production
alias psqlpadmin="psql 'host=phs-prd-db01.postgres.database.azure.com port=5432 dbname=postgres user=phsdbadmin@phs-prd-db01 sslmode=verify-full sslrootcert=/Volumes/Workshop/certs/Azure/root.crt'"
alias psqlp="psql 'host=phs-prd-db01.postgres.database.azure.com port=5432 dbname=phs_db_main user=phs_platform@phs-prd-db01 sslmode=verify-full sslrootcert=/Volumes/Workshop/certs/Azure/root.crt'"
# private container registry
acrb-kphsp() {
  az acr build --image phs-platform-image:$1 --registry prevailhs --build-arg RAILS_ENV=$2 --file /Volumes/Workshop/repos/phs-platform/Dockerfile /Volumes/Workshop/repos/phs-platform/
}
acrb-kphsc() {
  az acr build --image phs-client-image:$1 --registry prevailhs --file /Volumes/Workshop/repos/phs-client/Dockerfile /Volumes/Workshop/repos/phs-client/
}

free-port() { kill "$(lsof -t -i :$1)"; }
kill-port() { kill -kill "$(lsof -t -i :$1)"; }

sendcmsk() {
  scp -i /Volumes/Workshop/certs/bniu.pem $1 ubuntu@ec2-34-227-80-111.compute-1.amazonaws.com:~;
}
sendgl() {
  scp -i /Volumes/Workshop/certs/bniu.pem $1 ubuntu@ec2-54-226-88-197.compute-1.amazonaws.com:~;
}

# For webpack
alias packsver="./node_modules/.bin/webpack-dev-server --config webpack.hot.config.js --host 0.0.0.0"
pack(){
  ./node_modules/.bin/webpack --display-reasons --display-chunks --progress --config webpack.config.js;
}
gitpp(){
  ./node_modules/.bin/webpack  --display-reasons --display-chunks --progress --config webpack.config.js
  git add .;
  git commit -m 'webpacked';
}
gitf(){
  git branch --contains $1;
}

# Rails Bundle
# show info on a dependency
bi() {
    bundle info $1
}
bs() {
  rg "$1" $(bundle show --paths)
}
bo() {
  BUNDLER_EDITOR=atom bundle open $1
}

# Datica
dp() {
  datica -E Prevail-prod "$@"
}
dpc() {
  dp console Web 'bundle exec rails console'
}
dk() {
  datica -E Prevail-kibble "$@"
}
dkc() {
  dk console Web 'bundle exec rails console'
}
ds() {
  datica -E Prevail-staging "$@"
}
dsc() {
  ds console Web 'bundle exec rails console'
}
dd() {
  datica -E Prevail-demo "$@"
}
ddc() {
	dd console Web 'bundle exec rails console'
}
deployk() {
  autoload colors
  if [[ "$terminfo[colors]" -gt 8 ]]; then
      colors
  fi
  for COLOR in RED GREEN YELLOW; do
      eval $COLOR='$fg_no_bold[${(L)COLOR}]'
      eval BOLD_$COLOR='$fg_bold[${(L)COLOR}]'
  done
  eval RESET='$reset_color'

  PROGNAME=$(basename $0)

  if [[ $# != "1" ]]; then
    echo "${RED}${PROGNAME}: you must specify a branch name to deploy."
    return
  fi

  if [[ `git branch | grep $1` ]]; then
    echo "${YELLOW} About to deploy branch ($1) to Kibble in 5!"
    sleep 5
    git push kibble $1:master
    echo "${GREEN}✔ YEAH! Deploy to Kibble Finished!"
  else
    echo "${RED}${PROGNAME}: Git branch ($1) does not exist"
  fi
}
deploys() {
  autoload colors
  if [[ "$terminfo[colors]" -gt 8 ]]; then
      colors
  fi
  for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
      eval $COLOR='$fg_no_bold[${(L)COLOR}]'
      eval BOLD_$COLOR='$fg_bold[${(L)COLOR}]'
  done
  eval RESET='$reset_color'

  PROGNAME=$(basename $0)

  if [[ $# != "1" ]]; then
    echo "${RED}${PROGNAME}: you must specify a branch name to deploy."
    return
  fi

  if [[ `git branch | grep $1` ]]; then
    echo "${YELLOW} About to deploy branch ($1) to Staging in 5!"
    sleep 5
    git push staging $1:master
    echo "${GREEN}✔ YEAH! Deploy to Staging Finished!"
  else
    echo "${RED}${PROGNAME}: Git branch ($1) does not exist"
  fi
}
deployd() {
  autoload colors
  if [[ "$terminfo[colors]" -gt 8 ]]; then
      colors
  fi
  for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
      eval $COLOR='$fg_no_bold[${(L)COLOR}]'
      eval BOLD_$COLOR='$fg_bold[${(L)COLOR}]'
  done
  eval RESET='$reset_color'

  PROGNAME=$(basename $0)

  if [[ $# != "1" ]]; then
    echo "${RED}${PROGNAME}: you must specify a branch name to deploy."
    return
  fi

  if [[ `git branch | grep $1` ]]; then
    echo "${YELLOW} About to deploy branch ($1) to Demo in 5!"
    sleep 5
    git push demo $1:master
    echo "${GREEN}✔ YEAH! Deploy to Demo Finished!"
  else
    echo "${RED}${PROGNAME}: Git branch ($1) does not exist"
  fi
}
deployp() {
  autoload colors
  if [[ "$terminfo[colors]" -gt 8 ]]; then
      colors
  fi
  for COLOR in RED GREEN YELLOW; do
      eval $COLOR='$fg_no_bold[${(L)COLOR}]'
      eval BOLD_$COLOR='$fg_bold[${(L)COLOR}]'
  done
  eval RESET='$reset_color'

  PROGNAME=$(basename $0)

  if [[ $# != "1" ]]; then
    echo "${RED}${PROGNAME}: you must specify a branch name to deploy."
    return
  fi

  if [[ `git branch | grep $1` ]]; then
    echo "${YELLOW} About to deploy branch ($1) to Production in 5!"
    sleep 5
    git push production $1:master
    echo "${GREEN}✔ YEAH! Deploy to Production Finished!"
  else
    echo "${RED}${PROGNAME}: Git branch ($1) does not exist"
  fi
}

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
