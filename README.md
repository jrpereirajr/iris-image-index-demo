# iris-image-index-demo

A demo on how to build a custom SQL index for images data type.

## Project description

This project implements a demo on how to extend base classes of InterSystem IRIS in order to create a custom SQL index for a column that points to images. Thus, you can perform SQL queries using images content in the query predicates.

For instance, you can search for images which are similar to an example one, using a custom color similarity operator:

```
SELECT %DLIST(ImageFile) AS similarImagesList 
FROM dc_multimodel_ImageIndex.Test 
WHERE ID %FIND search_index(idxImageFile, '{"color_similarity":{"image":"/data/img/test/161074693598711.jpg","first":5}}')
```

As an example of application for this custom index, a simple query interface UI was created. In such application, you can dynamically select an example image and see the custom SQL index in action:

<img src="https://github.com/jrpereirajr/iris-image-index-demo/blob/master/img/R3fvmT6pmh.gif?raw=true"></img>

You can also execute SQL statements normally in portal:

<img src="https://github.com/jrpereirajr/iris-image-index-demo/blob/master/img/chrome_eM5Mgjuu7I.png?raw=true"></img>

## Technologies used:

In order to create a custom SQL index, the %Library.FunctionalIndex and %SQL.AbstractFind [interfaces](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GSQLOPT_indices) was implemented.

For image feature extraction, the new [IRIS Embedded Python](https://learning.intersystems.com/course/view.php?id=1572&ssoPass=1) technology was used. Such technology allows you to execute Python code directly from a COS context.

Internally, image features are stored in key-value model (globals). When a SQL query using the image index is performed, the features of the input image is extracted and compared to fetures stored in the index global.

This way, you can boost IRIS infrasctructures - acessed througth COS, using Python's advanced libs to delivere exciting features.

As an example of such IRIS infrastructure, this project combines IRIS custom index framework and multi model capabilities with Python image analysis libs.

## Installation

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/jrpereirajr/iris-image-index-demo.git
```

Open a Docker terminal in this directory and run:

```
$ cd iris-image-index-demo
$ docker-compose up
```

4. Wait for backend container to up and then build the frontend (in a new terminal instance):

```
cd iris-image-index-demo
cd frontend
npm i
npx ng serve
```

5. Access the [application](http://localhost:4200). Username: superuser; password: SYS.

## Installation (ZPM)

Open Terminal and call:

USER> zpm "install iris-image-index-demo"

## Credits

This project was inspired in the work presented by [Alexander Koblov](https://community.intersystems.com/post/creating-custom-index-type-cach%C3%A9) about how to implement a custom SQL index for geospatial coordinates.
The projects [iris-sample-rest-angular](https://github.com/intersystems-ib/iris-sample-rest-angular) and [Cache-FileServer](https://github.com/intersystems-ru/Cache-FileServer) are used for angular and REST template.
For IntegratedML and Python features, this project uses [integratedml-demo-template](https://github.com/intersystems-community/integratedml-demo-template) project.