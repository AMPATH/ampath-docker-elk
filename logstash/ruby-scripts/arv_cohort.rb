 require "date"
 
 def register(params)
     # no scripting params needed for this filter
 end


 def filter(event)
       status = event.get("status") ? event.get("status") : nil
       arv_first_regimen_month =  event.get("arv_first_regimen_start_date_timestamp") ? Date.parse(event.get("arv_first_regimen_start_date_timestamp")).strftime("%m") : nil
       end_date_month =  event.get("enddate_timestamp") ? Date.parse(event.get("enddate_timestamp")).strftime("%m") : nil
       end_date_year = event.get("enddate_timestamp") ? Integer(Date.parse(event.get("enddate_timestamp")).strftime("%Y")) : nil
       arv_first_regimen_year = event.get("arv_first_regimen_start_date_timestamp") ? Integer(Date.parse(event.get("arv_first_regimen_start_date_timestamp")).strftime("%Y")) : nil

       if status != "transfer_out" and arv_first_regimen_month == end_date_month and status and arv_first_regimen_month and end_date_month and end_date_year and arv_first_regimen_year
        event.set("art_cohort_year", end_date_year)

        diff = end_date_year - arv_first_regimen_year
        event.set("art_cohort_num", diff)
        return [event]

       else
        event.set("art_cohort_year", nil)
        event.set("art_cohort_num", nil)
        return [event]
       end

 end

