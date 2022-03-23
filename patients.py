from faker import Faker 
import csv
import psycopg2 as db

def DataCreatingPatients():
    
    output = open('patients.csv','w')
    fake = Faker()
    header = ['first_name','last_name']
    mywriter = csv.writer(output)
    mywriter.writerow(header)
    for i in range(4000):
        mywriter.writerow([fake.first_name(),fake.last_name()])
    output.close()



def DataLoadingPatients():

    conn_string="host=localhost dbname=healthag user=postgres password=Pa55w.rd"
    conn = db.connect(conn_string)
    cur = conn.cursor()
    
    with open('patients.csv', 'r') as emre:
        reader=csv.reader(emre)
        next(reader)
        for row in reader:
            #print(cur.mogrify("INSERT INTO patients (first_name,last_name) values(%s,%s)",row))
            cur.execute(
                 "INSERT INTO patients(first_name,last_name) VALUES (%s, %s)",
                 row
    )
    conn.commit()



