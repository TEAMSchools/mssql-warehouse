CREATE OR ALTER VIEW powerschool.cohort_identifiers AS

SELECT co.studentid
      ,co.student_number
      ,co.academic_year
      ,co.yearid
      ,co.region
      ,co.schoolid
      ,co.grade_level
      ,co.entrydate
      ,co.exitdate
      ,co.entrycode
      ,co.exitcode
      ,co.exit_code_kf
      ,co.exit_code_ts
      ,co.exitcomment
      ,co.fteid
      ,co.cohort
      ,co.is_retained_year
      ,co.year_in_network
      ,co.year_in_school
      ,co.rn_year
      ,co.rn_school
      ,co.rn_undergrad
      ,co.rn_all  
      ,co.entry_schoolid
      ,co.entry_grade_level
      ,co.is_retained_ever
      ,co.boy_status
      ,co.eoy_status
      ,co.track
      ,co.studentsdcid AS students_dcid

      ,s.lastfirst
      ,s.first_name
      ,s.middle_name
      ,s.last_name
      ,s.state_studentnumber
      ,s.enroll_status
      ,s.dob
      ,s.street
      ,s.city
      ,s.[state]
      ,s.zip
      ,s.home_phone
      ,s.grade_level AS highest_achieved
      ,CAST(UPPER(s.gender) AS NVARCHAR(1)) AS gender
      ,CAST(UPPER(s.ethnicity) AS NVARCHAR(1)) AS ethnicity

      ,sch.[name] AS school_name
      ,sch.abbreviation AS school_abbreviation

      ,t.team

      ,adv.advisor_name
      ,adv.advisor_phone COLLATE Latin1_General_BIN AS advisor_phone
      ,adv.advisor_email COLLATE Latin1_General_BIN AS advisor_email

      ,suf.newark_enrollment_number
      ,suf.c_504_status

      ,saa.student_web_id
      ,saa.student_web_password

      ,tp.total_balance AS lunch_balance

      ,ISNULL(enr.is_enrolled_y1, 0) AS is_enrolled_y1
      ,ISNULL(enr.is_enrolled_oct01, 0) AS is_enrolled_oct01
      ,ISNULL(enr.is_enrolled_oct15, 0) AS is_enrolled_oct15
      ,ISNULL(enr.is_enrolled_recent, 0) AS is_enrolled_recent
      ,ISNULL(enr.is_enrolled_oct15_week, 0) AS is_enrolled_oct15_week
      ,ISNULL(enr.is_enrolled_jan15_week, 0) AS is_enrolled_jan15_week

      ,CASE WHEN sp.specprog_name IN ('Self-Contained Special Education', 'Pathways ES', 'Pathways MS') THEN 1 ELSE 0 END AS is_pathways

      ,COALESCE(scw.contact_1_email_current, scw.contact_2_email_current) AS guardianemail
      ,scw.contact_1_name AS mother
      ,scw.contact_2_name AS father
      ,scw.contact_1_phone_home AS mother_home_phone
      ,scw.contact_2_phone_home AS father_home_phone
      ,scw.contact_1_phone_mobile AS mother_cell
      ,scw.contact_1_phone_daytime AS parent_motherdayphone
      ,scw.contact_2_phone_mobile AS father_cell
      ,scw.contact_2_phone_daytime AS parent_fatherdayphone

      ,CASE
        WHEN sp.specprog_name = 'Out of District' THEN sp.programid
        ELSE co.schoolid
       END AS reporting_schoolid
      ,CASE
        WHEN sp.specprog_name = 'Out of District' THEN sp.specprog_name
        ELSE sch.[name]
       END AS reporting_school_name
      ,CASE
        WHEN sp.specprog_name = 'Out of District' THEN 'OD'
        WHEN sch.high_grade = 12 THEN 'HS'
        WHEN sch.high_grade = 8 THEN 'MS'
        WHEN sch.high_grade = 4 THEN 'ES'
       END AS school_level

      ,ISNULL(
         CASE
          WHEN DB_NAME() = 'kippmiami' THEN scf.spedlep
          WHEN DB_NAME() IN ('kippnewark', 'kippcamden') THEN sped.spedlep
         END
        ,'No IEP'
       ) AS iep_status
      ,CASE
        WHEN DB_NAME() = 'kippmiami' THEN scf.spedlep
        WHEN DB_NAME() IN ('kippnewark', 'kippcamden') THEN sped.special_education_code
       END AS specialed_classification
      ,CASE
        WHEN DB_NAME() = 'kippmiami' AND scf.lep_status = 'Y' THEN 1
        WHEN nj.lepbegindate IS NULL THEN 0
        WHEN nj.lependdate < co.entrydate THEN 0
        WHEN nj.lepbegindate <= co.exitdate THEN 1
        ELSE 0
       END AS lep_status

      ,UPPER(
         CASE
          WHEN co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
           AND co.rn_year = 1 
               THEN CASE
                     WHEN DB_NAME() = 'kippmiami' THEN (CASE WHEN s.lunchstatus = 'NoD' THEN NULL ELSE s.lunchstatus END)
                     WHEN tp.is_directly_certified = 1 THEN 'F'
                     ELSE ifc.lunch_status COLLATE Latin1_General_BIN
                    END
          WHEN co.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
           AND co.entrydate = s.entrydate 
               THEN (CASE WHEN s.lunchstatus = 'NoD' THEN NULL ELSE s.lunchstatus END)
          ELSE co.lunchstatus
         END
       ) AS lunchstatus
      ,CASE
        WHEN co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
         AND co.rn_year = 1
             THEN CASE
                   WHEN DB_NAME() = 'kippmiami' THEN s.lunchstatus
                   WHEN tp.is_directly_certified = 1 THEN 'Direct Certification'
                   WHEN ifc.lunch_app_status IS NULL THEN 'No Application'
                   ELSE ifc.lunch_app_status COLLATE Latin1_General_BIN
                  END
        WHEN co.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() 
         AND co.entrydate = s.entrydate 
             THEN s.lunchstatus
        ELSE co.lunchstatus
       END AS lunch_app_status
FROM powerschool.cohort_static co
INNER JOIN powerschool.students s
  ON co.studentid = s.id
INNER JOIN powerschool.schools sch
  ON co.schoolid = sch.school_number
LEFT JOIN powerschool.team_roster_static t
  ON co.student_number = t.student_number
 AND co.academic_year = t.academic_year
 AND co.schoolid = t.schoolid
LEFT JOIN powerschool.advisory_static adv
  ON co.student_number = adv.student_number
 AND co.academic_year = adv.academic_year
 AND co.schoolid = adv.schoolid
LEFT JOIN powerschool.u_studentsuserfields suf
  ON co.studentsdcid = suf.studentsdcid
LEFT JOIN gabby.powerschool.student_access_accounts_static saa
  ON co.student_number = saa.student_number
LEFT JOIN titan.person_data_clean tp
  ON co.student_number = tp.person_identifier
 AND co.academic_year = tp.application_academic_school_year_clean
LEFT JOIN powerschool.enrollment_identifiers_static enr
  ON co.student_number = enr.student_number
 AND co.yearid = enr.yearid
LEFT JOIN powerschool.spenrollments_gen_static sp
  ON co.studentid = sp.studentid
 AND co.exitdate BETWEEN sp.enter_date AND sp.exit_date
 AND sp.specprog_name IN ('Out of District', 'Self-Contained Special Education', 'Pathways ES', 'Pathways MS', 'Whittier ES')
LEFT JOIN powerschool.student_contacts_wide_static scw
  ON co.student_number = scw.student_number
LEFT JOIN powerschool.studentcorefields scf
  ON co.studentsdcid = scf.studentsdcid
LEFT JOIN powerschool.s_nj_stu_x nj
  ON co.studentsdcid = nj.studentsdcid
LEFT JOIN easyiep.njsmart_powerschool_clean_static sped
  ON co.student_number = sped.student_number
 AND co.academic_year  = sped.academic_year
 AND sped.rn_stu_yr = 1
LEFT JOIN gabby.ops.income_form_data_clean ifc
  ON co.student_number = ifc.student_number
 AND co.academic_year = ifc.academic_year
 AND ifc.[db_name] = DB_NAME()
 AND ifc.rn =1
