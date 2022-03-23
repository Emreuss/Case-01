
/****************************** Create Scipt ***********************************************************************/
create table if not exists patients 
(
patient_id int primary key GENERATED ALWAYS AS IDENTITY,
first_name char(50) not null,
last_name char(50) not null
)

 
create table if not exists hospitals 
(
hospital_id int primary key generated always as identity,
hospital_name  char(50) not null,
hospital_province char(50) not null,
hospital_district char(50) not null,
bed_capacity int not null
)


create table if not exists doctors 
(
doctor_id int primary key generated always as identity,
doctor_name char(50) not null,
doctor_surname char(50) not null,
doctor_specialty char(50) not null,
hospital_id int not null,
constraint fk_hospital
foreign key(hospital_id)
references hospitals(hospital_id)
)


create table appointments 
(
appointment_id int primary key generated always as identity,
appointment_date date not null,
patient_id int not null,
doctor_id int  not null,
constraint fk_patient
foreign key(patient_id)
references patients(patient_id),
constraint fk_doctor
foreign key(doctor_id)
references doctors(doctor_id)
)


/*************************************************  Query-1 **************************************************************/

select sum(case when orthopedics_exm_count>=1 then 1 else 0 end )::float /count(1) *100 as rate_
from 
(select 
       pa.patient_id
      ,sum(case when doc.doctor_specialty ='Eye diseases' then 1 else 0 end ) as eyes_exm_count
      ,sum(case when doc.doctor_specialty='orthopedics' then 1 else 0 end ) as orthopedics_exm_count
from appointments app
inner join patients pa on app.patient_id = pa.patient_id 
inner join doctors doc on app.doctor_id  = doc.doctor_id 
inner join hospitals hos on doc.hospital_id = hos.hospital_id 
where  app.appointment_date between (current_date - INTERVAL '1 year')::date and current_date 
group by pa.patient_id 
order by pa.patient_id 
) patient_report_tbl where  eyes_exm_count >=1


/*************************************************  Query-2 **************************************************************/

create view vw_lastyeareyespatient as 
select patient_id ,patient_name ,patient_last_name,appointment_date ,hospital_name ,doctor_name ,doctor_surname ,doctor_specialty 
from(
select 
       pa.patient_id
      ,pa.first_name as patient_name
      ,pa.last_name  as patient_last_name
      ,app.appointment_date 
      ,hos.hospital_name
      ,doc.doctor_name 
      ,doc.doctor_surname 
      ,doc.doctor_specialty
      ,row_number() over(partition by pa.patient_id order by app.appointment_date) as row_
from appointments app
inner join patients pa on app.patient_id = pa.patient_id 
inner join doctors doc on app.doctor_id  = doc.doctor_id 
inner join hospitals hos on doc.hospital_id = hos.hospital_id 
where doc.doctor_specialty = 'Eye diseases' and 
app.appointment_date between (current_date - INTERVAL '1 year')::date and current_date) as pt_eyes
where row_=1



create view vw_lastyearorthopedicspatient as 
select patient_id ,patient_name ,patient_last_name,appointment_date ,hospital_name ,doctor_name ,doctor_surname ,doctor_specialty 
from(
select 
       pa.patient_id
      ,pa.first_name as patient_name
      ,pa.last_name  as patient_last_name
      ,app.appointment_date 
      ,hos.hospital_name
      ,doc.doctor_name 
      ,doc.doctor_surname 
      ,doc.doctor_specialty
      ,row_number() over(partition by pa.patient_id order by app.appointment_date) as row_
from appointments app
inner join patients pa on app.patient_id = pa.patient_id 
inner join doctors doc on app.doctor_id  = doc.doctor_id 
inner join hospitals hos on doc.hospital_id = hos.hospital_id 
where doc.doctor_specialty = 'orthopedics' and 
app.appointment_date between (current_date - INTERVAL '1 year')::date and current_date) as pt_orthopedics
where row_=1



select sum(case when eyes.appointment_date is not null then 1 else 0 end  ) as total_eyept,
       sum(case when eyes.appointment_date is not null and orth.appointment_date is not null then 1 else 0 end) total_bothpt,
       round((sum(case when eyes.appointment_date is not null and orth.appointment_date is not null then 1 else 0 end)  / 
             sum(case when eyes.appointment_date is not null then 1 else 0 end  ) :: float)::numeric * 100  ,2)  as rate
from vw_lastyeareyespatient eyes 
left join vw_lastyearorthopedicspatient orth
on eyes.patient_id = orth .patient_id 


/*************************************************  Query-3 **************************************************************/

create or replace
function fn_lastyear_eyes_orth_pt()
  returns table (total_eyept int ,
total_bothpt int,
rate numeric) 
as
$pt$
 select
	sum(case when eyes.appointment_date is not null then 1 else 0 end )::int  as total_eyept,
	sum(case when eyes.appointment_date is not null and orth.appointment_date is not null then 1 else 0 end)::int total_bothpt,
	round((sum(case when eyes.appointment_date is not null and orth.appointment_date is not null then 1 else 0 end) / 
             sum(case when eyes.appointment_date is not null then 1 else 0 end ) :: float)::numeric * 100 , 2) as rate
from
	vw_lastyeareyespatient eyes
left join vw_lastyearorthopedicspatient orth
on
	eyes.patient_id = orth .patient_id 

$pt$ 
language sql;

select fn_lastyear_eyes_orth_pt.rate  from fn_lastyear_eyes_orth_pt();
