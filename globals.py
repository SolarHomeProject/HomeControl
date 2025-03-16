import os.path

disp_timeout_block = False

APP_ROOT=os.path.dirname(__file__)
DATA=os.path.join(APP_ROOT, "data")
DB_FILE=os.path.join(DATA, "db", "db.csv")
FTP_PATH=os.path.join(DATA, "ftp")

def update_data(path):
  global DATA
  global DB_FILE
  global FTP_PATH
  DATA=os.path.join(path, "data")
  DB_FILE=os.path.join(DATA, "db", "db.csv")
  FTP_PATH=os.path.join(DATA, "ftp")
