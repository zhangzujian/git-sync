# git-sync

Shell script to keep remote git repository synchronized with upstream.

Usage:

First, create a configuration file ***/etc/git-sync.conf***:

```txt
[github.com/githubtraining/hellogitworld]
    repository = git@192.168.1.1:github.com/githubtraining/hellogitworld.git
    upstream = https://github.com/githubtraining/hellogitworld.git
```

The upstream project on **[https://github.com/githubtraining/hellogitworld.git](https://github.com/githubtraining/hellogitworld.git)** will be cloned in local directory **$LOCAL_DIR/github.com/githubtraining/hellogitworld** and then pushed to remote repository on `git@192.168.1.1:github.com/githubtraining/hellogitworld.git`.

Second and optionally, define some environment variables:

```shell
# directory to store local repositories
export LOCAL_DIR="/var/lib/git-sync"

# git config: user.name
export GIT_USER_NAME="username"

# git config: user.email
export GIT_USER_EMAIL="username@example.com"
```

You can also create an environment file and then source it before running the command.

```shell
# directory to store local repositories
LOCAL_DIR="/var/lib/git-sync"

# git config: user.name
GIT_USER_NAME="username"

# git config: user.email
GIT_USER_EMAIL="username@example.com"
```

Default values of the environment variables are as follow:

| Environment  Variable | Default Value |
| --------------------- | ------------- |
| LOCAL_DIR             | /tmp/git-sync |
| GIT_USER_NAME         | -             |
| GIT_USER_EMAIL        | -             |

Finally, run the command below:

```shell
sh git-sync.sh
```
