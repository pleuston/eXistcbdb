 for $cec in  .{local:transform($n/node())},
        $ec in $solve/doc("ETHNICITY_TRIBE_CODES.xml")/dataroot/ETHNICITY_TRIBE_CODES/c_ethnicity_code()
    where $cec = $ec
    return $solve/doc("ETHNICITY_TRIBE_CODES.xml")/dataroot/ETHNICITY_TRIBE_CODES/@c_ethnicity_code  