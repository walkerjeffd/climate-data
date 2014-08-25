.PHONY: mon day db_mon

day:
	mkdir -p data/day
	curl -o data/day/east_daily_met.tgz http://hydro.engr.scu.edu/files/gridded_obs/daily/ascii/east_daily_met.tgz
	tar -zxvf data/day/east_daily_met.tgz -C data/day/

mon:
	mkdir -p data/mon
	curl -o data/mon/east_monthly_met.tgz http://hydro.engr.scu.edu/files/gridded_obs/monthly/ascii/east_monthly_met.tgz
	tar -zxvf data/mon/east_monthly_met.tgz -C data/mon/

db_mon:
	mkdir -p db/
	RScript --slave r/make_database.R $(realpath ./data/mon/east) $(realpath ./db) maurer_mon.db

all: mon db_mon