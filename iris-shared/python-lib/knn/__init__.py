from sklearn.neighbors import BallTree
import numpy as np
import pickle
import base64
import irisnative

# ln -s /shared/python-lib/knn /usr/irissys/mgr/python/

def get_iris():
  ip = "127.0.0.1"
  port = 1972 # 51773
  namespace = "USER"
  username = "superuser"
  password = "SYS"
  
  connection = irisnative.createConnection(ip,port,namespace,username,password)
  dbnative = irisnative.createIris(connection)

  return (connection, dbnative)

def release_iris(connection):
  connection.close()

def normalize_filename(filename):
  filename = filename.encode('UTF-8')
  return base64.urlsafe_b64encode(filename).decode('UTF-8')

def create_index(index_global, cardinality):
  connection, dbnative = get_iris()
  X = get_data(dbnative, index_global, cardinality)
  tree = BallTree(X, metric = "chebyshev")
  filename = f"/tmp/${normalize_filename(index_global)}.p"
  pickle.dump(tree, open(filename, "wb"))
  release_iris(connection)
  return tree

def get_data(dbnative, index_global, cardinality):
  X = []
  iter_ = dbnative.iterator(index_global, "model")
  for subscript, value in iter_.items():
    id_ = subscript
    v = []
    for i in range(cardinality):
      v.append(
        dbnative.get(index_global, "model", id_, "rgb", i) / 255
      )
    X.append(v)
  return X

def query(x, k, index_global):
  # tree = create_index("^dc.multimodel.ImageIndex.TestI(\"idxImageFile\")", cardinality)
  filename = f"/tmp/${normalize_filename(index_global)}.p"
  tree = pickle.load(open(filename, "rb"))
  x = eval(x)
  x_ = [xi / 255 for xi in x[0]]
  dist, ind = tree.query([x_], k)
  return ind

def get():
  rng = np.random.RandomState(0)
  X = rng.random_sample((10, 3))  # 10 points in 3 dimensions
  tree = BallTree(X)              
  dist, ind = tree.query(X[:1], k=3)                
  # print(ind)  # indices of 3 closest neighbors

  # print(dist)  # distances to 3 closest neighbors
  # testnative()
  # create_index("^dc.multimodel.ImageIndex.TestI(\"idxImageFile\")")
  # x = [[235, 198, 96]]
  # x = np.array([[235, 198, 96]])
  x = eval("[[235, 198, 96]]")
  ind = query(x, 5, 3)
  print(ind)

def testnative():
  # ip = "127.0.0.1"
  # port = 1972 # 51773
  # namespace = "USER"
  # username = "superuser"
  # password = "SYS"
  
  # connection = irisnative.createConnection(ip,port,namespace,username,password)
  # dbnative = irisnative.createIris(connection)
  connection, dbnative = get_iris()

  # print("[1. Setting and getting a global]")
  # setting and getting a global
  # ObjectScript equivalent: set ^testglobal("1") = 8888
  dbnative.set(7777, "testglobal", "1")

  # ObjectScript equivalent: set globalValue = $get(^testglobal("1"))
  globalValue = dbnative.get("testglobal","1")

  print("The value of testglobal is ", globalValue)
  # print()

  #connection.close()
  release_iris(connection)