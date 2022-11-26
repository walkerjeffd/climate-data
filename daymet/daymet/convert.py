import netCDF4
import datetime as dt
import pandas as pd

tile = '11934'
year = '1990'
variable = 'prcp'

nc = netCDF4.Dataset('%s_%s_%s.nc' % (tile, year, variable))

times = nc.variables['time'][:]
xs = nc.variables['x'][:]
ys = nc.variables['y'][:]

rows = []

for it, t in enumerate(times):
  df = pd.DataFrame(nc.variables[variable][it, :, :])
  df.columns = nc.variables['x'][:]
  df.index = nc.variables['y'][:]
  df.columns.name = 'x'
  df.index.name = 'y'
  df = df.stack()
  df.name = variable
  df = df.to_frame()
  df['datetime'] = dt.datetime(1980,1,1) + dt.timedelta(days=t)
  
  filename = 'csv/%s_%s_%s_%03d.csv' % (tile, year, variable, it)
  print 'Saving: %s' % filename
  df.to_csv(filename, header=True)