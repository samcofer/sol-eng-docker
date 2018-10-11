# Connect


## Troubleshooting

The `rstudio-connect` user, when created, does not have a default shell.  Practically, this means you cannot sign in as this user.  The solution?  Execute the following when you want to `su` to this user:

```
su -s /bin/bash rstudio-connect
```

This sets the shell so that you can `su rstudio-connect` if you would like.  You can also persist this setting with:

```
chsh -s /bin/bash rstudio-connect
```
