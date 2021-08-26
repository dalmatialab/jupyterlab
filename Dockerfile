FROM python:3.5.9-stretch
LABEL maintainer="dalmatialab"

# Install java
RUN apt-get update && apt-get install -y openjdk-8-jre 

# Install tools
RUN apt-get update && apt-get install -y wget sshpass ssh-client curl net-tools 

# Environment home variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV SPARK_HOME=/storage/sparkconf/spark

# Environment version variables
ENV SCALA_GEOMESA_VERSION=2.11-3.1.0
ENV GEOMESA_VERSION=3.1.0
ENV ACCUMULO_MAJOR=2
ENV SPARK_VERSION=2.4.8
ENV HADOOP_SPARK_VERSION=2.7

# Install Tini https://github.com/krallin/tini and jupyter
RUN wget https://github.com/krallin/tini/releases/download/v0.19.0/tini_0.19.0-amd64.deb
RUN dpkg -i tini_0.19.0-amd64.deb
RUN pip install jupyter-core==4.6.3 ipython==7.9.0 ipykernel==5.3.4 jupyter-client==6.1.7 traitlets==4.3.3 nbformat==5.0.8 ipywidgets==7.5.1 nbconvert==5.6.1
RUN pip install notebook==6.1.5 jupyterhub==1.2.2 jupyterlab==2.2.9 && jupyter notebook --generate-config

# Install node and npm for ipyleaflet
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh && bash nodesource_setup.sh && apt install nodejs

# Geomesa runtime 
RUN mkdir -p /storage/sparkconf/spark
RUN cd /storage/sparkconf && wget https://github.com/locationtech/geomesa/releases/download/geomesa_$SCALA_GEOMESA_VERSION/geomesa-accumulo_$SCALA_GEOMESA_VERSION-bin.tar.gz \
                          && tar -xvzf geomesa-accumulo_$SCALA_GEOMESA_VERSION-bin.tar.gz 
             
RUN cd /storage/sparkconf && wget https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_SPARK_VERSION}.tgz\
                          && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_SPARK_VERSION}.tgz --strip-components 1 -C spark/. \
                          && cp geomesa-accumulo_${SCALA_GEOMESA_VERSION}/dist/spark/geomesa-accumulo-spark-runtime-accumulo${ACCUMULO_MAJOR}_${SCALA_GEOMESA_VERSION}.jar ${SPARK_HOME}/jars \
                          && pip install geomesa-accumulo_${SCALA_GEOMESA_VERSION}/dist/spark/geomesa_pyspark-${GEOMESA_VERSION}.tar.gz \
                          && rm -rf geomesa-accumulo_${SCALA_GEOMESA_VERSION} && rm geomesa-accumulo_${SCALA_GEOMESA_VERSION}-bin.tar.gz \
                          && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_SPARK_VERSION}.tgz
                          

# Copy local files as late as possible to avoid cache busting
COPY lib/jupyter_notebook_config.py /etc/jupyter/

# Install visualization tools
RUN pip install ipyleaflet && jupyter nbextension enable --py --sys-prefix ipyleaflet

RUN jupyter labextension install jupyter-leaflet && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
                                                 && jupyter labextension install jupyter

# Change kernel name to right version
RUN python -m ipykernel install --name python3 --display-name="Python 3.5.9"

# Install netcdf4 requirements
RUN apt-get install -y libhdf5-serial-dev netcdf-bin libnetcdf-dev && ln -s /usr/include/hdf5/serial /usr/include/hdf5/include && export HDF5_DIR=/usr/include/hdf5

# Install 3.9.2 jupyter kernel
RUN curl https://pyenv.run | bash && exec $SHELL && export PATH="/root/.pyenv/bin:$PATH" && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)"  && pyenv install -v 3.9.2 && /root/.pyenv/versions/3.9.2/bin/python -m pip install ipykernel netcdf4

ADD kernels/  /usr/local/share/jupyter/kernels/

# Install GDAL=2.1.3
RUN  apt-get update && apt-get install -y python3.5-dev gdal-bin libgdal-dev -y
RUN export CPLUS_INCLUDE_PATH=/usr/include/gdal && export C_INCLUDE_PATH=/usr/include/gdal && pip install GDAL==2.1.3 

# Installing commong packages for python
RUN pip install pyspark pytz pandas numpy geojson requests datetime flask shapely paramiko
RUN pip install findspark geopandas matplotlib descartes pykml paho-mqtt tqdm scipy cdsapi

EXPOSE 8888

ENTRYPOINT ["tini", "-g", "--"]
CMD ["jupyter","lab","--allow-root","--no-browser","--LabApp.quit_button=True"]
