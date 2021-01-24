# iris-image-index-demo

A notebook approach to use IRIS analytics capabilities.

## Project description

This project implements a demo on how to extend base classes of InterSystem IRIS in order to create a custom SQL index in a column that points to images. Thus, you can perform SQL queries using images content in the query predicates.

For instance, you can search for images which are similar to an example one, using a custom color similarity operator:

```
SELECT %DLIST(ImageFile) AS similarImagesList 
FROM dc_multimodel_ImageIndex.Test 
WHERE ID %FIND search_index(idxImageFile, '{"color_similarity":{"image":"/data/img/test/161074693598711.jpg","first":5}}')
```

As an example of application for this custom index, a simple query interface UI was created. In such application, you can dynamically select an example image and see the custom SQL index in action:

<img src="https://github.com/jrpereirajr/iris-image-index-demo/blob/master/img/2HWgQqAOUM.gif?raw=true"></img>

## Technologies used:

In order to create a custom SQL index, the 

## Installation

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/jrpereirajr/iris-image-index-demo.git
```

Open a Docker terminal in this directory and run:

```
$ cd iris-image-index-demo
$ docker-compose build
```

3. Run the IRIS container, and Jupyter notebook server images:

```
$ docker-compose up
```

4. Wait for backend e frontend containers to up and then access the [application](http://localhost:4200). Username: superuser; password: SYS.

## Installation (ZPM)

Open Terminal and call:

USER> zpm "install iris-image-index-demo"

## Credits

This project used the project [iris-sample-rest-angular](https://github.com/intersystems-ib/iris-sample-rest-angular) as angular and REST template.
For IntegratedML features, this project uses [integratedml-demo-template](https://github.com/intersystems-community/integratedml-demo-template) project.