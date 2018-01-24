Run as specified uid,gid(username=duser) on Ubuntu:16.04

Run as root(start bash if args leaved empty):

```shell
docker run --rm -it -e USER_ID=0 -e GROUP_ID=0 ubuntu-runas
```

Run as (uid=1000,gid=1000):

```shell
docker run --rm -it -e USER_ID=1000 -e GROUP_ID=1000 ubuntu-runas bash -c id
```


Execute a script before changing to duser:

```shell
cat << 'EOF' > start_private.sh
[ "$(id -u)" == 0 ] && echo 'executing as root'
EOF
chmod +x start_private.sh

docker run --rm -it -v $(pwd)/start_private.sh:/scripts/start_private.sh -e USER_ID=1000 -e GROUP_ID=1000 ubuntu-runas
```

Execute a script after changing to duser:

```shell
cat << 'EOF' > start-user_private.sh
[ "$(id -u)" == 1000 ] && echo 'executing as 1000'
EOF
chmod +x start-user_private.sh

docker run --rm -it -v $(pwd)/start-user_private.sh:/scripts/start-user_private.sh -e USER_ID=1000 -e GROUP_ID=1000 ubuntu-runas
```
