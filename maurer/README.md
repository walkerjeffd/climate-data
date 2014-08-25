Gridded Meteorological Data: 1949-2010 by Ed Maurer, et al.
===========================================================

- **Folder**: `/maurer`
- **URL**: `http://www.engr.scu.edu/~emaurer/gridded_obs/index_gridded_obs.html`
- **Description**: Daily and Monthly 1/8-degree gridded meteorological data [1 Jan 1949 - 31 Dec 2010]
- **Variables**: Precipitation (mm), Max/Min Temperature (C), and Wind Speed (m/s).

**Citation**
> Maurer, E.P., A.W. Wood, J.C. Adam, D.P. Lettenmaier, and B. Nijssen, 2002, A Long-Term Hydrologically-Based Data Set of Land Surface Fluxes and States for the Conterminous United States, J. Climate 15, 3237-3251.

**NOTE:** This is currently set up for the east region only, but could be expanded to other regions

## Fetch Data

To get the daily dataset saved to `maurer/data/day`:

```
make day 
```

To fetch the monthly dataset saved to `maurer/data/mon`:

```
make mon
```

## Create Monthly Database

To convert the raw **monthly** data files to an SQLite database saved to `maurer/db/maurer_mon.db`:

```
make db_mon
```

This database contains two tables:

- `grid`: `[FILE, LAT, LON, REGION]`, each record corresponds to one input file and provides the lat/lon
- `data`: `[YEAR, MONTH, PRCP, TMAX, TMIN, WIND, LAT, LON, REGION]`, each record provides the values of each climate variable at a single location
