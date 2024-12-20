/*************************************************************************
 
        Script Name:    1co_enc_search_data.prg
 
        Description:    Clinical Office - mPage Edition
                        Person/Encounter Search Component Data CCL Support Script
 
        Date Written:   March 3, 2022
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
            Copyright (c) 2022 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from Patient/Encounter search component and used to display the
 output for collected person/encounter records.
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    03/03/22 J. Simpson     Initial Development
 *************************************************************************/
drop program 1co_enc_search_data:group1 go
create program 1co_enc_search_data:group1
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif
 
; Clear and define rCustom structure
free record rCustom
record rCustom (
    1 person[*]
        2 person_id             = f8
        2 name                  = vc
        2 mrn                   = vc
        2 sex                   = vc
        2 birth_date            = dq8
        2 age                   = vc
        2 ethnic_group          = vc
    1 encounter[*]
        2 encntr_id             = f8
        2 person_id             = f8
        2 fin_number            = vc
        2 facility              = vc
        2 nurse_unit            = vc
        2 room_bed              = vc
        2 reg_dt_tm             = dq8
        2 disch_dt_tm           = dq8
        2 medical_service       = vc
        2 encounter_type        = vc
        2 attending_physician   = vc
)
 
; Declare variables and subroutines
declare nNum = i4
 
; Collect code values
declare cv48_Active = f8 with noconstant(uar_get_code_by("MEANING", 48, "ACTIVE"))
declare cv4_MRN = f8 with noconstant(uar_get_code_by("MEANING", 4, "MRN"))
declare cv319_FinNbr = f8 with noconstant(uar_get_code_by("MEANING", 319, "FIN NBR"))
declare cv333_AttendDoc = f8 with noconstant(uar_get_code_by("MEANING", 333, "ATTENDDOC"))

; Collect the person level data
if (size(patient_source->patients, 5) > 0)

    select into "nl:"
        name            = p.name_full_formatted
    from    person              p,
            person_alias        pa
    plan p
        where expand(nNum, 1, size(patient_source->patients, 5), p.person_id, patient_source->patients[nNum].person_id)
        and p.active_status_cd = cv48_Active
    join pa
        where pa.person_id = outerjoin(p.person_id)
        and pa.person_alias_type_cd = outerjoin(cv4_MRN)
        and pa.active_status_cd = outerjoin(cv48_Active)
        and pa.active_ind = outerjoin(1)
        and pa.end_effective_dt_tm > outerjoin(sysdate)
    order name, p.person_id
    head report
        nCount = 0
    head name
        x = 0
    head p.person_id
        nCount = nCount + 1
        stat = alterlist(rCustom->person, nCount)
        
        rCustom->person[nCount].person_id = p.person_id
        rCustom->person[nCount].name = p.name_full_formatted
        rCustom->person[nCount].mrn = cnvtalias(pa.alias, pa.alias_pool_cd)
        rCustom->person[nCount].sex = uar_get_code_display(p.sex_cd)
        rCustom->person[nCount].birth_date = p.birth_dt_tm
        rCustom->person[nCount].age = trim(cnvtage(p.birth_dt_tm),3)
        rCustom->person[nCount].ethnic_group = uar_get_code_display(p.ethnic_grp_cd)
    with expand=1
endif

; Collect the encounter level data
if (size(patient_source->visits, 5) > 0)

    select into "nl:"
        person_id             = e.person_id,
        encntr_id             = e.encntr_id,
        sort_key_1            = format(e.disch_dt_tm, "yyyymmddhhmm;;d"),
        sort_key_2            = format(e.reg_dt_tm, "yyyymmddhhmm;;d")
    from    encounter           e,
            encntr_alias        ea
    plan e
        where expand(nNum, 1, size(patient_source->visits, 5), e.encntr_id, patient_source->visits[nNum].encntr_id)
        and e.active_status_cd = cv48_Active
    join ea
        where ea.encntr_id = outerjoin(e.encntr_id)
        and ea.encntr_alias_type_cd = outerjoin(cv319_FinNbr)
        and ea.active_status_cd = outerjoin(cv48_Active)
        and ea.active_ind = outerjoin(1)
        and ea.end_effective_dt_tm > outerjoin(sysdate)
    order person_id, sort_key_1, sort_key_2 desc, encntr_id
    head report
        nCount = 0
    head person_id
        x = 0
    head sort_key_1
        x = 0
    head sort_key_2
        x = 0                
    head encntr_id
        nCount = nCount + 1
        stat = alterlist(rCustom->encounter, nCount)
        
        rCustom->encounter[nCount].encntr_id = e.encntr_id
        rCustom->encounter[nCount].person_id = e.person_id
        rCustom->encounter[nCount].medical_service = uar_get_code_display(e.med_service_cd)
        rCustom->encounter[nCount].facility = uar_get_code_display(e.loc_facility_cd)
        rCustom->encounter[nCount].nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
        if (e.loc_bed_cd > 0.0)
            rCustom->encounter[nCount].room_bed = concat(trim(uar_get_code_display(e.loc_room_cd)), "-",
                                    trim(uar_get_code_display(e.loc_bed_cd)))
        else                                    
            rCustom->encounter[nCount].room_bed = uar_get_code_display(e.loc_room_cd)
        endif
        rCustom->encounter[nCount].reg_dt_tm = e.reg_dt_tm
        rCustom->encounter[nCount].disch_dt_tm = e.disch_dt_tm
        rCustom->encounter[nCount].fin_number = cnvtalias(ea.alias, ea.alias_pool_cd)
        rCustom->encounter[nCount].encounter_type = uar_get_code_display(e.encntr_type_cd)
    with expand=1
    
    ; Collect the attending physician
    select into "nl:"
    from    encntr_prsnl_reltn          epr,
            prsnl                       p
    plan epr
        where expand(nNum, 1, size(rCustom->encounter, 5), epr.encntr_id, rCustom->encounter[nNum].encntr_id)
        and epr.encntr_prsnl_r_cd = cv333_AttendDoc
        and epr.active_ind = 1
        and epr.active_status_cd = cv48_Active
        and epr.end_effective_dt_tm > sysdate
    join p
        where p.person_id = epr.prsnl_person_id
    detail
        nPos = locateval(nNum, 1, size(rCustom->encounter, 5), epr.encntr_id, rCustom->encounter[nNum].encntr_id)
        rCustom->encounter[nPos].attending_physician = p.name_full_formatted
    with expand=1        
     
endif
 
 
; ------------------------------------------------------------------------------------------------
;								END OF YOUR CUSTOM CODE
; ------------------------------------------------------------------------------------------------
 
; If you wish to return output back to the mPage, you need to run the ADD_CUSTOM_OUTPUT function.
; Any valid JSON format is acceptable including the CNVTRECTOJSON function. If using
; CNVTRECTOJSON be sure to use parameters 4 and 1 as shown below.
; If you plan on creating your own JSON string rather than converting a record structure, be
; sure to have it in the format of {"name":{your custom json data}} as the ADD_CUSTOM_OUTPUT
; subroutine will extract the first sub-object from the JSON. (e.g. {"name":{"personId":123}} will
; be sent to the output stream as {"personId": 123}.
call add_custom_output(cnvtrectojson(rCustom, 4, 1))
 
#end_program
 
end go
