# webmethods-devsecops-recipes - config

These "*.template" files should be updated with required info, and the ".template" extension should be removed.

Finally, I generally keep outside the code repository, which I follow in all the demo stacks.
In all these demos, I simply put the configs in the following directory structure on my local workstation following the pattern:

$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/$env/stacks/$stackname

And this directory gets uploaded to versionned S3 to make sure I don't lose the configs.

Feel free to follow this convention, or modify as you wish.