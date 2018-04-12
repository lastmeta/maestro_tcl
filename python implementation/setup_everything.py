import manage_db

db = manage_db.Database_Connection('testing')
db.create_tables()
db.insert_sdr('B',1)
