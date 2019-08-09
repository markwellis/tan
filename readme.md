# TAN

Social news website/forum/cms

## Running
```
pushd /vagrant
CATALYST_DEBUG=1 carton exec -- plackup -l 0.0.0.0:8081 -E development --no-default-middleware tan.psgi
```

site will be avaialbe at https://faketan.test/

## To register
get a recaptcha v2 key from http://www.google.com/recaptcha/admin

add the keys to tan_local.yml

if the registration email doesn't arrive, you can get the confirmation link by doing the following

get the message id from
```
sudo mailq
```

and replace XXXXXXX with it here
```
sudo postcat -q XXXXXXX
```

see here for more info
http://www.tech-g.com/2012/07/15/inspecting-postfixs-email-queue/
