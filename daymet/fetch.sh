vars='prcp srad'
# tiles='11754 11755 11756 11934 11935 11936 12114 12115 12116 12117 12295 12296 12297'
tiles='11934'
years='1990 1991'
dir=daymet

mkdir -p $dir

for var in $vars; do
  for year in $years; do
    for tile in $tiles; do
      echo Fetching $tile - $year - $var
      filepath="$dir"/"$tile"_"$year"_"$var".nc
      if [ ! -e $filepath ]; then
        wget -O $filepath http://thredds.daac.ornl.gov/thredds/fileServer/ornldaac/1219/tiles/"$year"/"$tile"_"$year"/"$var".nc
      fi
    done
  done
done

# http://www.khufkens.com/2014/04/19/daymet-ancillary-data-conversion/
# http://daymet.ornl.gov/files/UserGuides/GDAL_and_DaymetnetCDF_Files.doc

# # find corner coordinates
# $ gdalinfo NETCDF:"11934_1990_srad.nc":lat
# Corner Coordinates:
# Upper Left  ( 1957000.000,  515000.000)
# Lower Left  ( 1957000.000,  265000.000)
# Upper Right ( 2171000.000,  515000.000)
# Lower Right ( 2171000.000,  265000.000)
# Center      ( 2064000.000,  390000.000)

# # convert to GeoTIFF
# gdal_translate -of GTiff -a_ullr 1957000 515000 2171000 265000 -a_srs "+proj=lcc +datum=WGS84 +lat_1=25 n +lat_2=60n +lat_0=42.5n +lon_0=100w" NETCDF:11934_1991_srad.nc:srad 11934_1991_srad.tif

# # convert to WGS84
# gdalwarp -of GTiff -overwrite -t_srs "EPSG:4326" 11934_1991_srad.tif 11934_1991_srad_wgs84.tif

# # convert to sql for psql

# # to create a table
# raster2pgsql -s 4326 -F -c 11934_1991_srad_wgs84.tif srad > 11934_1991_srad_wgs84.sql

# # to append to table
# raster2pgsql -s 4326 -F -a 11934_1991_srad_wgs84.tif srad > 11934_1991_srad_wgs84.sql

# # import postgresql
# psql -d daymet -f 11934_1991_srad_wgs84.sql

# # get value
# select ST_Value(rast, 1, ST_SetSRID(ST_Point(-73, 43), 4326)) from srad;


# # function to get the value for a given lat/lon
# CREATE OR REPLACE FUNCTION get_srad(day integer, lon numeric, lat numeric) RETURNS TABLE(srad double precision, day integer) AS $$
# select ST_Value(rast, day, ST_SetSRID(ST_Point(lon, lat), 4326)) as srad, day as day from srad;
# $$ LANGUAGE SQL;

# SELECT * FROM get_srad(1, -73.0, 43.0);
