/*************************************************************************
 
        Script Name:    1co_mpage_template.prg
 
        Description:    Clinical Office - mPage Edition
                        Custom CCL Pre/Post Blank Template
 
        Date Written:   May 7, 2018
        Written by:     John Simpson
                        Precision Healthcare Solutions
 
 *************************************************************************
            Copyright (c) 2018 Precision Healthcare Solutions
 
 NO PART OF THIS CODE MAY BE COPIED, MODIFIED OR DISTRIBUTED WITHOUT
 PRIOR WRITTEN CONSENT OF PRECISION HEALTHCARE SOLUTIONS EXECUTIVE
 LEADERSHIP TEAM.
 
 FOR LICENSING TERMS PLEASE VISIT www.clinicaloffice.com/mpage/license
 
 *************************************************************************
                            Special Instructions
 *************************************************************************
 Called from 1co_mpage_entry. Do not attempt to run stand alone. If you
 wish to test the development of your custom script from the CCL back-end,
 please run with 1co_mpage_test.
 
 Possible Payload values:
 
    "customScript": {
        "script": [
            "name": "your custom script name:GROUP1",
            "id": "identifier for your output, omit if you won't be returning data",
            "run": "pre or post",
            "parameters": {
                "your custom parameters for your job"
            }
        ],
        "clearPatientSource": true
    }
 
 *************************************************************************
                            Revision Information
 *************************************************************************
 Rev    Date     By             Comments
 ------ -------- -------------- ------------------------------------------
 001    05/07/18 J. Simpson     Initial Development
 *************************************************************************/
drop program 1co_mpage_template:group1 go
create program 1co_mpage_template:group1
 
/*
	The parameters for your script are stored in the PAYLOAD record structure. This
	structure contains the entire payload for the current CCL execution so parameters
	for other Clinical Office jobs may be present (e.g. person, encounter, etc.).
 
	Your payload parameters are stored in payload->customscript->script[script number].parameters.
 
	The script number for your script has been assigned to a variable called nSCRIPT.
 
	For example, if you had a parameter called fromDate in your custom parameters for your script
	you would access it as follows:
 
	set dFromDate = payload->customscript->script[nscript]->parameters.fromdate
 
	**** NOTE ****
	If you plan on running multiple pre/post scripts in the same payload, please ensure that
	you do not have the same parameter with different data types between jobs. For example, if
	you ran two pre/post jobs at the same time with a parameter called fromDate and in one job
	you passed a valid JavaScript date such as  "fromDate": "2018-05-07T14:44:51.000+00:00" and
	in the other job you passed "fromDate": "05-07-2018" the second instance of the parameter
	would cause an error.
*/
 
; Check to see if we have cleared the patient source and if not, do we have data in the patient source
; to run our custom CCL against.
if (validate(payload->customscript->clearpatientsource, 0) = 0)
	if (size(patient_source->patients, 5) = 0)
		go to end_program
	endif
endif
 
; This is the point where you would add your custom CCL code to collect data. If you did not
; choose to clear the patient source, you will have the encounter/person data passed from the
; mpage available for use in the PATIENT_SOURCE record structure.
;
; There are two branches you can use, either VISITS or PATIENTS. The format of the
; record structure is:
;
; 1 patient_source
;	2 visits[*]
;		3 person_id			= f8
;		3 encntr_id			= f8
;	2 patients[*]
;		3 person_id			= f8
;
; Additionally, you can alter the contents of the PATIENT_SOURCE structure to allow encounter
; or person records to be available for standard Clinical Office scripts. For example, your custom
; script may collect a list of visits you wish to have populated in your mPage. Instead of
; manually collecting your demographic information, simply add your person_id/encntr_id combinations
; to the PATIENT_SOURCE record structure and ensure that the standard Clinical Office components
; are being called within your payload. (If this is a little unclear, please see the full
; documentation on http://www.clinicaloffice.com).
 
; ------------------------------------------------------------------------------------------------
;								BEGIN YOUR CUSTOM CODE HERE
; ------------------------------------------------------------------------------------------------
 
; Define the custom record structure you wish to have sent back in the JSON to the mPage. The name
; of the record structure can be anything you want but you must make sure it matches the structure
; name used in the add_custom_output subroutine at the bottom of this script.
free record rCustom
record rCustom (
	1 your_custom_field				= vc
	1 another_custom[*]
		2 custom					= vc
)
 
 
; Do something (e.g. collect orders, appointments, etc.)
 
 
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
