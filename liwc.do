#delimit ;

local sql "
    SELECT speaker_name, role, context,
        file_name, last_update, speaker_number, 
        liwc_counts(speaker_text)
    FROM streetevents.speaker_data
    WHERE file_name='999419_T'
    ORDER BY context, speaker_number";

odbc load, exec("`sql'") dsn("iangow") clear;
