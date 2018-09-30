#!/bin/bash
source profile
random-string()
{
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}


#Create credentials if they don't exist
cb credential list | grep Name | grep -q $client || cb credential create aws key-based --name $client --access-key "${AccessKey}" --secret-key "${SecretKey}"

#Password Management

if [ ! -f ./$client ]; then
  #random-string 16 > ./$client
  echo adminadminlana123 > ./$client
fi

password=`cat $client`

#Upload recipes
cp cloudbreak/recipes/postinstall .
cp cloudbreak/recipes/preinstall .
sed -i "s/PASSWORD/$password/g" postinstall
sed -i "s/PASSWORD/$password/g" preinstall

cb recipe create from-file --name preinstall${client} --execution-type pre-ambari-start --file preinstall
cb recipe create from-file --name postinstall${client} --execution-type post-cluster-install --file postinstall

#setup template
cp cloudbreak/creation/simple.template .
sed -i "s/PASSWORD/$password/g" simple.template
sed -i "s/IP/$(echo $iprange |sed 's/\//\\\//g')/g" simple.template
sed -i "s/CLIENT/$client/g" simple.template
sed -i "s/REGION/$region/g" simple.template
sed -i "s/ACCESSKEY/${AccessKey}/g" simple.template
sed -i "s/ACCESSSECRET/$(echo $SecretKey |sed 's/\//\\\//g')/g" simple.template
sed -i "s/PUBLICKEY/$(echo $PublicKey | sed 's/\//\\\//g')/g" simple.template


#issue build command and wait until complete
cb cluster create --cli-input-json simple.template --name $client --wait &
PID=$!
sleep 15
status=`cb cluster describe --name $client | python -c "import json,sys;obj=json.load(sys.stdin);print(obj['status'] + ' ' + obj['statusReason'])"`
echo $status
while kill -0 $PID; do
  sleep 10
  newstatus=`cb cluster describe --name $client | python -c "import json,sys;obj=json.load(sys.stdin);print(obj['status'] + ' ' + obj['statusReason'])"`
  if [ "$status" != "$newstatus" ]; then
    echo $newstatus
  fi
  status="$newstatus"
done
