import sqlite3 as lite
import sys

class Database_Connection(object):
    def __init__(self, name):
        self.name = name
        self.con = None
        self.cur = None
        try:
            self.con = lite.connect(name + '.db')
            self.cur = self.con.cursor()
            self.cur.execute('SELECT SQLITE_VERSION()')
            data = self.cur.fetchone()
            print("SQLite version: %s" % data)
        except lite.Error(e):
            print("Error %s:" % e.args[0])
            sys.exit(1)
        #finally:
        #    if con:
        #        con.close()

    #def get_con(self):

    def get_name(self):
        return self.name

    def get_con(self):
        return self.con

    def get_cur(self):
        return self.cur

    def create_tables(self):
        self.cur.execute("CREATE TABLE sdr(node INTEGER PRIMARY KEY AUTOINCREMENT, input CHAR, ix INTEGER)")
        #return self.cur.lastrowid

    def insert_sdr(self, input, ix):
        con = lite.connect(self.name + '.db')
        with con:
            cur = con.cursor()
            cur.execute("INSERT INTO sdr (input,ix) VALUES('{input}',{ix})".format(input=input, ix=ix))
        return cur.lastrowid

    def select_sdr_node(self, input, ix):
        self.cur.execute("SELECT node FROM sdr WHERE input='{input}' AND ix={ix}".format(input=input, ix=ix))
        return self.cur.fetchall()

    def select_sdr_input(self, node):
        self.cur.execute("SELECT input FROM sdr WHERE node={node}".format(node=node))
        return self.cur.fetchall()

    def select_sdr_input_ix(self, node):
        self.cur.execute("SELECT input,ix FROM sdr WHERE node={node}".format(node=node))
        return self.cur.fetchall()

    def get_lastrowid(self):
        return self.cur.lastrowid
