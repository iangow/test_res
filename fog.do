#delimit ;

local sql "
	SELECT context, speaker_number, speaker_name, role, fog(speaker_text) 
	FROM streetevents.speaker_data
	WHERE file_name = '999419_T'
	ORDER BY context, speaker_number";

odbc load, exec("`sql'") dsn("iangow") clear;

