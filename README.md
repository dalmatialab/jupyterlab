![example workflow](https://github.com/dalmatialab/jupyterlab/actions/workflows/main.yml/badge.svg)

# Supported tags and respective Dockerfile links

 - [1.0-rc-1](https://github.com/dalmatialab/jupyterlab/blob/1321f8bf4a5faa01bfd7bbb244117396fdf2d865/Dockerfile)
 - [1.0-rc-2](https://github.com/dalmatialab/jupyterlab/blob/66d2b5e1a9d870fd93bfeaadfcb0a2a65df78a4b/Dockerfile)

# What is JupyterLab ? 

[JupyterLab](https://jupyter.org/) is a web-based interactive development environment for Jupyter notebooks, code, and data. JupyterLab is flexible: configure and arrange the user interface to support a wide range of workflows in data science, scientific computing, and machine learning. JupyterLab is extensible and modular: write plugins that add new components and integrate with existing ones.

<img src="https://github.com/dalmatialab/jupyterlab/blob/62d92afcce60ea7a3eee51eb0d51031018032dfb/logo.png?raw=true" width="350" height="150">

# How to use this image

## Start JupyterLab instance

    $ docker run -d --name=some-jupyter-name -p 8888:8888 image:tag

Where:

 - `some-jupyter-name` is name you want to assign to your container
 - `tag` is docker image version

## Environment variables

**TZ**

This is *optional* variable. It specifes timezone. Default value is `Europe/Zagreb`.

## Ports

JupyterLab exposes user interface at port 8888.

## NOTE

To login into JupyterLab find token with command 

    $ docker logs some-jupyter-name 2>&1 | grep "token="

Where:

- `some-jupyter-name` is name of created JupyterLab container

This image includes `3.5.9` and `3.9.2` python kernels as well as jupyter-leaflet plugin for visualization.  

Kernel 3.5.9 includes following packages: gdal, pyspark, pytz, pandas, numpy, geojson, requests, datetime, flask, shapely, paramiko, findspark, geopadas, matplotlib, decartes, pykml, paho-mqtt, tdqm, scipy and cdsapi.  

Kernel 3.9.2 includes netcdf python package.

# License

