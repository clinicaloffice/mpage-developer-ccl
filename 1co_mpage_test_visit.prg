/*************************************************************************
 
        Script Name:    1CO_MPAGE_TEST_VISIT.PRG
 
        Description:    Clinical Office - mPage Edition
        				Set the visit context for MPage developer testing
 
        Date Written:   November 10, 2021
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
		   Copyright (c) 2021 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Used for back-end testing of Clinical Office mPage scripts. You can
 test your own payload JSON by modifying the payload code below.
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    11/10/21 J. Simpson     Initial Development
 *************************************************************************/
 
drop program 1co_mpage_test_visit:group1 go
create program 1co_mpage_test_visit:group1
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Encounter ID" = 0
	;<<hidden>>"Search" = ""
 
with outdev, encntrId
 
; Define report structure
record rReport (
    1 encntr_id         = f8
    1 fin               = vc
    1 patient_name      = vc
)
 
; Code values
declare cv48_Active = f8 with noconstant(uar_get_code_by("MEANING", 48, "ACTIVE"))
declare cv319_FinNbr = f8 with noconstant(uar_get_code_by("MEANING", 319, "FIN NBR"))
 
; Test the encounter id to ensure it is valid
select into "nl:"
from    encounter       e,
        person          p,
        encntr_alias    ea
plan e
    where e.encntr_id = $encntrId
join p
    where p.person_id = e.person_id
join ea
    where ea.encntr_id = e.encntr_id
    and ea.encntr_alias_type_cd = cv319_FinNbr
    and ea.active_ind = 1
    and ea.active_status_cd = cv48_Active
    and ea.end_effective_dt_tm > sysdate
detail
    rReport->encntr_id = e.encntr_id
    rReport->patient_name = p.name_full_formatted
    rReport->fin = ea.alias
with counter
 
; Update the record
if (rReport->encntr_id > 0)
 
    ; Delete old values first
    delete from dm_info d
        where d.info_domain = "CLINICAL OFFICE"
        and d.info_name = "DEVELOPER TEST VISIT"
        and d.info_domain_id = reqinfo->updt_id
 
    ; Insert the new record
    insert into dm_info d
        set d.info_domain = "CLINICAL OFFICE",
            d.info_name = "DEVELOPER TEST VISIT",
            d.info_domain_id = reqinfo->updt_id,
            d.info_number = rReport->encntr_id
 
    commit
endif
 
; Output a report to the user
select into value($outdev)
from    dummyt
detail
    if (rReport->encntr_id = 0)
        col 0, "*** ERRROR *** Invalid ENCNTR_ID value", row + 1
    else
        col 0, "Congratulations, your test visit for MPage development is now set to:", row + 2
        col 0, "encntr_id: ", rReport->encntr_id, row + 1
        col 0, "FIN: ", rReport->fin, row + 1
        col 0, "Patient Name: ", rReport->patient_name, row + 1
    endif
with counter
 
end go
