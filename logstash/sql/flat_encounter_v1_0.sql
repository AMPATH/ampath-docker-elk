select
	t1.date_created as enc_date_created,
	t1.patient_id,
    gender,
    birthdate,
    timestampdiff(year,birthdate,encounter_datetime) as age,
	case
		when t11.name is not null then t11.name 
        when encounter_type in (1,2,3,4,10,14,15,17,19,22,23,26,32,33,43,47,21,105,106,110,111,112,113,114,116,117,120,127,128,129,138,153,154,158, 161,162,163)
			then "HIV"
		when encounter_type in (54,55,75,76,77,78,79,83,96,99,100,104,107,108,109,131,171,172)
			then "CDM"
		when encounter_type in (38,	39,	40,	41,	42,	45,	49,	69,	70,	86,	87,	88,	89,	90,	91,	92,	93,	94,	130,	141,	142,	143,	145,	146,	147,	148,	149,	150,	151,	160,	169,	170)
			then "Oncology"
		when encounter_type in (118,152,164,165,166)
			then "Dermatology"
	end as department,
    t2.visit_id,
    t2.visit_type_id,
	case
		when t4.name is not null then t4.name 
        when encounter_type in (1,2,3,4,10,14,15,17,19,22,23,26,32,33,43,47,21,105,106,110,111,112,113,114,116,117,120,127,128,129,138,153,154,158, 161,162,163)
			then "Generic HIV Visit"
		when encounter_type in (54,55,75,76,77,78,79,83,96,99,100,104,107,108,109,131,171,172)
			then "Generic CDM Visit"
		when encounter_type in (38,39,	40,41,42,	45,	49,	69,	70,	86,	87,	88,	89,	90,	91,	92,	93,	94,	130,	141,	142,	143,	145,	146,	147,	148,	149,	150,	151,	160,	169,	170)
			then "Generic Oncology Visit"
		when encounter_type in (118,152,164,165,166)
			then "Generic Dermatology Visit"
	end as visit_type,

	case
		when t9.name is not null then t9.name 
        when encounter_type in (1,2,3,4,10,14,15,17,19,22,23,26,32,33,43,47,21,105,106,110,111,112,113,114,116,117,120,127,128,129,138,153,154,158, 161,162,163)
			then "Generic HIV Program"
		when encounter_type in (54,55,75,76,77,78,79,83,96,99,100,104,107,108,109,131,171,172)
			then "Generic CDM Program"
		when encounter_type in (38,39,	40,41,42,	45,	49,	69,	70,	86,	87,	88,	89,	90,	91,	92,	93,	94,	130,	141,	142,	143,	145,	146,	147,	148,	149,	150,	151,	160,	169,	170)
			then "Generic Oncology Program"
		when encounter_type in (118,152,164,165,166)
			then "Generic Dermatology Program"
	end as program_name,
    t1.location_id,
    t5.name as clinic,
    t5.latitude as clinic_latitude,
    t5.longitude as clinic_longitude,
    t2.date_started,
    t2.date_stopped,
    t1.encounter_id,
    t1.encounter_type,
    t3.name as encounter_type_name,
    t1.encounter_datetime,
    time(t1.encounter_datetime) as encounter_time,
    t1.creator as creator_id,
    concat(t7.given_name," ", t7.family_name) as creator_name,
    case
	when t13.value_reference="true" then null
        else timestampdiff(minute,t2.date_started,t1.encounter_datetime)
    end as time_btwn_visit_start_and_encounter_start,
    if(t1.visit_id,timestampdiff(minute,t1.encounter_datetime, t1.date_created),null) as time_to_complete_form,
    if(t13.value_reference="true",1,0) as is_retrospective
	from amrs.encounter t1
		left outer join amrs.visit t2 using (visit_id)
		join amrs.encounter_type t3 on t1.encounter_type = t3.encounter_type_id
		left outer join amrs.visit_type t4 using(visit_type_id)
		join amrs.location t5 on t1.location_id=t5.location_id
		join amrs.users t6 on t1.creator=t6.user_id
		join amrs.person_name t7 on t6.person_id = t7.person_id
		left outer join etl.program_visit_map t8 using (visit_type_id)
		left outer join amrs.program t9 on t8.program_type_id = t9.program_id
		left outer join etl.program_department_map t10 using (program_id)
		left outer join etl.departments t11 using (department_id)
        left outer join amrs.person t12 on t1.patient_id = t12.person_id
        left outer join amrs.visit_attribute t13 on t1.visit_id=t13.visit_id and t13.attribute_type_id=1

    where t1.date_created > :sql_last_value

