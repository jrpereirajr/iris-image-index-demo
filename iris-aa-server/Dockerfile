ARG IMAGE=store/intersystems/iris-aa-community:2020.3.0AA.331.0
ARG IMAGE=intersystemsdc/iris-aa-community:2020.3.0AA.331.0-zpm
ARG IMAGE=intersystemsdc/iris-ml-community:2020.3.0.302.0-zpm
ARG IMAGE=intersystemsdc/iris-ml-community
FROM $IMAGE
LABEL maintainer="Thomas Dyar <Thomas.Dyar@intersystems.com>"

USER root
RUN mkdir /data \
	&& chown irisowner /data
USER irisowner

# copy files
COPY data /data
COPY src /data/src
COPY iris.script /tmp/iris.script

# python stuffs...
RUN iris start IRIS \
	&& iris session IRIS '##class(%SYS.Python).Install("/shared/python-lib/irisnative-1.0.0-cp34-abi3-linux_x86_64.whl")' \
	&& iris session IRIS '##class(%SYS.Python).Install("scikit-learn")' \
	&& iris session IRIS '##class(%SYS.Python).Install("fast_colorthief")' \
	&& iris session IRIS '##class(%SYS.Python).Install("json")'

RUN ln -s /shared/python-lib/knn /usr/irissys/mgr/python/

# load demo stuff
RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script
