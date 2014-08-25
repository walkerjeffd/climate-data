Historical Climate Datasets
===========================

Jeffrey D. Walker, PhD

## Maurer - Gridded Meteorological Data: 1949-2010

- **Folder**: `/maurer`
- **URL**: `http://www.engr.scu.edu/~emaurer/gridded_obs/index_gridded_obs.html`
- **Description**: Daily 1/8-degree gridded meteorological data [1 Jan 1949 - 31 Dec 2010]
- **Variabels**: Precipitation (mm), max/min temperature (C), and wind speed (m/s).

### Fetch Data

To get the daily dataset saved to `maurer/data/day`:

```
make day 
```

To fetch the monthly dataset saved to `maurer/data/mon`:

```
make mon
```

### Create Database

To convert the raw data files to an SQLite database saved to `maurer/db/maurer_mon.db`:

```
make db_mon
```
