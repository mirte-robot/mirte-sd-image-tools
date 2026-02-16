# mirte-sd-image-tools

This repository uses Packer to create new MIRTE OS sd card images,
and modify exisiting images. Please read the [MIRTE documentation](https://docs.mirte.org/)
on how to use the sd images.

## Install requirements (for local build)

In order to build new sd images one needs an installation of Packer:

```sh
sudo ./packerInstall.sh
```

## Build locally

### Default repositories

To build the MIRTE OS sd images (you can grab a coffee), you can just run:

```sh
sudo ./packerBuild.sh
```

### Custom repositories

To build the MIRTE OS sd images based on custom repositories, you can modify
the repos.yaml file to point the repositories to the sources you want to have
build in the sd image (eg. your own forks).

You can also create the image based on local repositories (eg. with code not 
pushed to github yet). Place the repositories in the folder called 'git_local'.

### Custom settings

You can also specify which features you want included in the image. In that
way you can for example create an image with just ROS, but not the 
web interface and/or python. This can be done by changing the settings
in `settings.sh`.

### Using github actions 

To run github actions locally, can install [act](https://github.com/nektos/act)
and run: 

```
./actBuild.sh
```
It will run the workflows and copy the artifacts to `./artifacts/`. This will
not use any changes in git_local or repos.yaml.

## Build on github

You can also build an image using github actions. The same customization
is possible as with the locally built builds. Please note that teh nightly
(development) builds are disabled by default.

## Edit existing images

In case you want to modify an existing image (eg. a release from MIRTE OS),
you can also modify this. You will get a shell to make modifications
to the image:

```
./shell.sh <mirte_os_image>.img

```

By removing the `/stopshell` file, and it will finalize (eg. shrink) the image
and place it in `./shell_workdir/`.

## License

This work is licensed under a Apache-2.0 OSS license.
