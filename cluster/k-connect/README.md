# Connect


## Troubleshooting

The `rstudio-connect` user, when created, does not have a default shell.  Practically, this means you cannot sign in as this user.  The solution?  Execute the following as `root`

```
chsh -s /bin/bash rstudio-connect
```

This sets the default shell so that you can `su rstudio-connect` if you would like.

