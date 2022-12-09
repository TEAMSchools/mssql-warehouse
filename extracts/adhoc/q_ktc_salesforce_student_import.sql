select
    case
        when co.schoolid = 133570965
        then 'TEAM Academy, a KIPP school'
        when co.schoolid = 73252
        then 'Rise Academy, a KIPP school'
        when co.schoolid = 73253
        then 'Newark Collegiate Academy, a KIPP school'
        when co.schoolid = 179902
        then 'KIPP Lanning Square Middle School'
    end as [kipp school of enrollment],
    co.last_name as [last name],
    co.first_name as [first name],
    left(co.middle_name, 1) as [middle initial],
    co.cohort as [hs class cohort],
    'PowerSchool ID' as [student id type],  # ]
    co.student_number as [
        student id,
        u.name as [contact owner name],
        u.id as [contact owner salesforce id],
        co.entrydate as [school enrollment date],
        co.grade_level as [school enrollment grade],
        case
            when co.enroll_status = 0
            then 'Attending'
            when co.enroll_status = 2
            then 'Transferred out'
            when co.enroll_status = 3
            then 'Graduated'
        end as [enrollment status],
        co.grade_level as [school ending grade],
        co.exitdate as [school exit date],
        co.dob as [date of birth],
        case
            when co.gender = 'M' then 'Male' when co.gender = 'F' then 'Female'
        end as [gender],
        case
            when co.ethnicity = 'I'
            then 'American Indian/Alaska Native'
            when co.ethnicity = 'A'
            then 'Asian'
            when co.ethnicity = 'B'
            then 'Black/African American'
            when co.ethnicity = 'H'
            then 'Hispanic/Latino'
            when co.ethnicity = 'P'
            then 'Native Hawaiian/Pacific Islander'
            when co.ethnicity = 'W'
            then 'White'
            when co.ethnicity = 'T'
            then 'Two or More Races'
        end as [ethnicity],
        co.street as [street address],
        co.city as [city],
        co.state as [state],
        co.zip as [zip],
        co.student_web_id + '@teamstudents.org' as [student e - mail],
        null as [student mobile],
        co.home_phone as [student home phone],
        ltrim(
            rtrim(
                case
                    when charindex(',', co.mother) = 0 and charindex(' ', co.mother) = 0
                    then co.mother
                    when (charindex(',', co.mother) - 1) < 0
                    then left(co.mother, (charindex(' ', co.mother) - 1))
                    else
                        substring(
                            co.mother, (charindex(',', co.mother) + 2), len(co.mother)
                        )
                end
            )
        ) as [parent 1 first name],
        ltrim(
            rtrim(
                case
                    when charindex(',', co.mother) = 0 and charindex(' ', co.mother) = 0
                    then co.mother
                    when (charindex(',', co.mother) - 1) < 0
                    then
                        substring(
                            co.mother, (charindex(' ', co.mother) + 1), len(co.mother)
                        )
                    else left(co.mother, (charindex(',', co.mother) - 1))
                end
            )
        ) as [parent 1 last name],
        co.parent_motherdayphone as [parent 1 work phone],
        co.mother_home_phone as [parent 1 home phone],
        replace(
            replace(cast(co.guardianemail as varchar(max)), char(10), ''), char(13), ''
        ) as [parent 1 e - mail],
        ltrim(
            rtrim(
                case
                    when charindex(',', co.father) = 0 and charindex(' ', co.father) = 0
                    then co.father
                    when (charindex(',', co.father) - 1) < 0
                    then left(co.father, (charindex(' ', co.father) - 1))
                    else
                        substring(
                            co.father, (charindex(',', co.father) + 2), len(co.father)
                        )
                end
            )
        ) as [parent 2 first name],
        ltrim(
            rtrim(
                case
                    when charindex(',', co.father) = 0 and charindex(' ', co.father) = 0
                    then co.father
                    when (charindex(',', co.father) - 1) < 0
                    then
                        substring(
                            co.father, (charindex(' ', co.father) + 1), len(co.father)
                        )
                    else left(co.father, (charindex(',', co.father) - 1))
                end
            )
        ) as [parent 2 last name],
        co.parent_fatherdayphone as [parent 2 work phone],
        co.father_home_phone as [parent 2 home phone],
        replace(replace(co.guardianemail, char(10), ''), char(13), '') as [
            parent 2 e - mail
        ]
        from gabby.powerschool.cohort_identifiers_static co
        left join gabby.alumni.contact s on co.student_number = s.school_specific_id_c
        left join gabby.alumni. [user] u on s.owner_id = u.id
        where
            co.schoolid in (73252, 73253, 133570965, 179902)
            and co.rn_undergrad = 1
            and co.grade_level <> 99
