from faker import Faker 
import csv
import psycopg2 as db

def DataCreatingHospital():
    
    output = open('hospitals.csv','w')
    fake = Faker()
    header = ['hospital_name','hospital_province','hospital_district','bed_capacity']
    mywriter = csv.writer(output)
    mywriter.writerow(header)
    for i in range(20):
        mywriter.writerow([fake.first_name() + ' Hospital',fake.city(),fake.state(),fake.random_int(min=1000,max=4500,step=1)])
    output.close()


def DataLoadingHospital():

    conn_string="host=localhost dbname=healthag user=postgres password=Pa55w.rd"
    conn = db.connect(conn_string)
    cur = conn.cursor()
    
    with open('hospitals.csv', 'r') as emre:
        reader=csv.reader(emre)
        next(reader)
        for row in reader:
            #print(cur.mogrify(INSERT INTO hospitals(hospital_name,hospital_province,hospital_district,bed_capacity) VALUES (%s, %s , %s , %s)",row))
            cur.execute(
                 "INSERT INTO hospitals(hospital_name,hospital_province,hospital_district,bed_capacity) VALUES (%s, %s , %s , %s)",
                 row
    )
    conn.commit()