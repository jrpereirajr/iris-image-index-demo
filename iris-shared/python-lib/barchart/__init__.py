import pandas as pd
import matplotlib.pyplot as plt

# ln -s /shared/python-lib/barchart /usr/irissys/mgr/python/

def buildGraph(filename, df, xSeriesName, ySeriesName):
	df.plot(x=xSeriesName, y=ySeriesName, kind = 'bar')
	plt.savefig(filename, format="svg")

def exampleDF():
	Data = {
			'Country': ['US', 'Canada' , 'Germany', 'UK' , 'France'],
			'GPD_Per_Capita': [45000, 42000, 52000, 49000, 47000]
		}
	return pd.DataFrame(Data, columns=['Country', 'GPD_Per_Capita'])
