import csv, sqlite3 as sqlite

data = csv.reader(open("airline_delay_causes.csv", "rU"), delimiter=",")
major_airports = ["ATL", "BWI", "BOS", "CLT", "MDW", "ORD", "DFW", "DEN", "DTW", "FLL", "IAH", "LAS", "LAX", "MIA", "MSP", "JFK", "LGA", "EWR", "MCO", "PHL", "PHX", "PDX", "SLC", "SAN", "SFO", "SEA", "TPA", "DCA", "IAD"]

with sqlite.connect(r"airline_delay_causes_major_airports.db") as con:
	cur = con.cursor()
	cur.execute("DROP TABLE IF EXISTS delays")
	cur.execute("CREATE TABLE delays(year int, month int, carrier text, carrier_name text, airport text, airport_name text, arr_flights int, arr_del15 int, carrier_ct double, weather_ct double, nas_ct double, security_ct double, late_aircraft_ct double, arr_cancelled int, arr_diverted int, arr_delay int, carrier_delay int, weather_delay int, nas_delay int, security_delay int, late_aircraft_delay int)")
	for line in data:
		del line[21]
		if line[4] in major_airports and line[0] != "2003" and line[0] != "2013":
			cur.execute("INSERT INTO delays VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", line)
	con.commit()

con.close()