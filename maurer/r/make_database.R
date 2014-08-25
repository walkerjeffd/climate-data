# RScript load_climate_data.R <data_input_directory> <db_directory> <db_filename>

hr <- paste(rep('-', 79), collapse='')

# get command line arguments
argv <- commandArgs(TRUE)

if (length(argv) < 3) {
  stop('Missing directory arguments, expecting:\n$ RScript make_database.R <data_input_directory> <db_directory> <db_filename>')
}

DATA_DIR <- argv[1]
DB_DIR <- argv[2]
DB_FILE <- argv[3]

if (!file.exists(DATA_DIR)) {
  stop(paste0("Input data directory does not exist: ", DATA_DIR))
}
if (!file.exists(DB_DIR)) {
  stop(paste0("Output database directory does not exist: ", DB_DIR))
}

DB_PATH <- file.path(DB_DIR, DB_FILE)

cat(hr, '\n')
cat('DATA INPUT DIR: ', DATA_DIR, '\n')
cat('DB OUTPUT PATH: ', DB_PATH, '\n')

cat(hr, '\n')
cat('LOADING LIBRARIES\n')
library(stringr)
library(lubridate)
library(tidyr)
library(dplyr)
library(ggmap)
library(RSQLite)
library(ggplot2)
theme_set(theme_bw())

# get filenames in data directory
cat(hr, '\n')
cat('READ DATA FILENAMES', '\n')
files <- list.files(DATA_DIR) %>%
  str_split('_') %>%
  do.call(rbind, .) %>%
  as.data.frame(stringsAsFactors=FALSE) %>%
  mutate(FILE=paste(V1, V2, V3, sep="_")) %>%
  select(FILE, LAT=V2, LON=V3) %>%
  mutate(LAT=as.numeric(LAT),
         LON=as.numeric(LON),
         REGION=ifelse(LAT>41, 'Northeast',
                       ifelse(LAT>36, 'Mideast',
                                      'Southeast')))
cat('Found ', nrow(files), ' files\n')

# # create map of locations colored by region
# # map <- get_map(location=c(lon=mean(range(files$LON)), lat=mean(range(files$LAT))),
# #                zoom=4, maptype="satellite", color='bw')
# # ggmap(map, darken=c(0.25, "white"), extent="device") +
# #   geom_point(aes(x=LON, y=LAT, color=REGION), data=files, size=1) +
# #   scale_color_manual('', values=c('Northeast'='orangered',
# #                                   'Mideast'='chartreuse3',
# #                                   'Southeast'='steelblue'))
#
# helper function
read.climate.file <- function(dir, file) {
  x <- read.table(file.path(dir, file))
  names(x) <- c("YEAR", "MONTH", "PRCP", "TMAX", "TMIN", "WIND")
  return(x)
}

# open db connection
cat(hr, '\n')
cat('OPEN DATABSE CONNECTION', '\n')
sqlite <- dbDriver("SQLite")
conn <- dbConnect(sqlite, DB_PATH)

# drop existing tables
if(dbExistsTable(conn, "data")){
  cat('DROPPING data TABLE\n')
  dbRemoveTable(conn, "data")
}
if(dbExistsTable(conn, "grid")){
  cat('DROPPING grid TABLE\n')
  dbRemoveTable(conn, "grid")
}

# create grid table
cat(hr, '\n')
cat('WRITING grid TABLE\n')
dbWriteTable(conn, "grid", files, row.names=FALSE)

# create data table
cat(hr, '\n')
cat('READING FILES AND WRITING data TABLE\n')
apply(files, 1, function(file) {
  x <- read.climate.file(dir=DATA_DIR, file=file['FILE'])
  x <- mutate(x,
              LAT=as.numeric(file['LAT']),
              LON=as.numeric(file['LON']),
              REGION=file['REGION'])
  if(dbExistsTable(conn, "data")) {
    dbWriteTable(conn, "data", x, append = TRUE, row.names = FALSE)
  } else {
    dbWriteTable(conn, "data", x, row.names = FALSE)
  }
  invisible()
})

cat(paste0('LOADED: ', nrow(files), ' files\n'))

# create spatial index
cat(hr, '\n')
cat('CREATE INDEXES\n')
dbSendQuery(conn, "CREATE INDEX latlonInd ON data(LAT,LON)")
dbSendQuery(conn, "CREATE INDEX regionInd ON data(REGION)")

# get info and close conn
# dbGetInfo(conn)
cat(hr, '\n')
cat('CLOSE DATABSE CONNECTION\n')
dbDisconnect(conn)

# # summarize data using dplyr
# db <- src_sqlite("climate.db", create = FALSE)
#
# df.1 <- tbl(db, "data") %>%
#   filter(LAT==files$LAT[1], LON==files$LON[1]) %>%
#   collect
#
# df <- tbl(db, "data") %>%
#   group_by(REGION, YEAR, MONTH) %>%
#   summarise(PRCP.MEAN=mean(PRCP),
#             TMAX.MEAN=mean(TMAX),
#             TMIN.MEAN=mean(TMIN),
#             WIND.MEAN=mean(WIND),
#             PRCP.SD=sd(PRCP),
#             TMAX.SD=sd(TMAX),
#             TMIN.SD=sd(TMIN),
#             WIND.SD=sd(WIND)) %>%
#   collect %>%
#   gather(VAR.STAT, VALUE, PRCP.MEAN:WIND.SD) %>%
#   separate(VAR.STAT, c("VAR", "STAT")) %>%
#   spread(STAT, VALUE) %>%
#   mutate(VAR=factor(VAR))
#
# df %>%
#   mutate(DATE=ymd(paste(YEAR, MONTH, 1, sep='-'))) %>%
#   ggplot() +
#   geom_ribbon(aes(x=DATE, ymin=MEAN-SD, ymax=MEAN+SD), fill='grey50') +
#   geom_line(aes(x=DATE, y=MEAN), color='blue') +
#   facet_grid(VAR~REGION, scales='free_y') +
#   labs(x="Month/Year", y="Mean")
#
