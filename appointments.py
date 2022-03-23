from faker import Faker 
import csv
import psycopg2 as db
import pandas as pd 
import random 


conn_string="host=localhost dbname=healthag user=postgres password=Pa55w.rd"
conn = db.connect(conn_string)
cur = conn.cursor()


def DataCreatingAppointments():

    patientid_df = pd.read_sql_query('''SELECT patient_id FROM patients''', con=conn)
    patientid_lst = patientid_df['patient_id'].tolist()
    doctorid_df = pd.read_sql_query('''SELECT doctor_id FROM doctors''', con=conn)
    doctorid_lst = doctorid_df['doctor_id'].tolist()
    output = open('appointments.csv','w')
    fake = Faker()
    header = ['appointment_date','patient_id','doctor_id']
    mywriter = csv.writer(output)
    mywriter.writerow(header)
    for i in range(6000):
        mywriter.writerow([fake.date_this_decade(),random.choice(patientid_lst),random.choice(doctorid_lst)])
    output.close()


def DataLoadingAppointments():
    
    with open('appointments.csv', 'r') as emre:
        reader=csv.reader(emre)
        next(reader)
        for row in reader:
            cur.execute(
                 "INSERT INTO appointments(appointment_date,patient_id,doctor_id) VALUES (%s, %s, %s)",
                 row
    )
    conn.commit()


