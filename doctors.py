from faker import Faker 
import csv
import psycopg2 as db
import pandas as pd 
import random 


conn_string="host=localhost dbname=healthag user=postgres password=Pa55w.rd"
conn = db.connect(conn_string)
cur = conn.cursor()


def DataCreatingDoctors():

    hospitalid_df = pd.read_sql_query('''SELECT hospital_id FROM hospitals''', con=conn)
    hospitalid_lst = hospitalid_df['hospital_id'].tolist()
    doctor_specialty= ['Eye diseases','Chest Diseases','Internal diseases','Cardiac surgery','orthopedics']
    output = open('doctors.csv','w')
    fake = Faker()
    header = ['doctor_name','doctor_surname','doctor_specialty','hospital_id']
    mywriter = csv.writer(output)
    mywriter.writerow(header)
    for i in range(30):
        mywriter.writerow([fake.first_name(),fake.last_name(),random.choice(doctor_specialty),random.choice(hospitalid_lst)])
    output.close()



def DataLoadingDoctors():
    
    with open('doctors.csv', 'r') as emre:
        reader=csv.reader(emre)
        next(reader)
        for row in reader:
            cur.execute(
                 "INSERT INTO doctors(doctor_name,doctor_surname,doctor_specialty,hospital_id) VALUES (%s, %s, %s, %s)",
                 row
    )
    conn.commit()


