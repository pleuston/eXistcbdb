xquery version "3.0";
(: need declaration of eXist functions?declare namespace? :)

(:!!!! Throughout this document all instances of "/cbdbtest/" need to be changed to "/cbdb/" for production use !!!!!

For optimum performance the sequence of case statements should match the sequence of the orignal data table:
<tts_sysno>,<c_personid>,<c_name>,<c_name_chn>,<c_index_year>,<c_female>,<c_ethnicity_code>,<c_household_status_code>,
<c_tribe>,<c_birthyear>,<c_by_nh_code>,<c_by_nh_year>,<c_by_range>,<c_deathyear>,<c_dy_nh_code>,<c_dy_nh_year>,<c_dy_range>,
<c_death_age>,<c_death_age_approx>,<c_fl_earliest_year>,<c_fl_ey_nh_code>,<c_fl_ey_nh_year>,<c_fl_ey_notes>,<c_fl_latest_year>,
<c_fl_ly_nh_code>,<c_fl_ly_nh_year>,<c_fl_ly_notes>,<c_surname>,<c_surname_chn>,<c_mingzi>,<c_mingzi_chn>,<c_dy>,
<c_choronym_code>,<c_source>,<c_pages>,<c_notes>,<c_by_intercalary>,<c_dy_intercalary>,<c_by_month>,<c_dy_month>,<c_by_day>,
<c_dy_day>,<c_by_day_gz>,<c_dy_day_gz>,<TTSMQ_db_ID>,<MQWWLink>,<KyotoLink>,<c_surname_proper>,<c_mingzi_proper>,<c_name_proper>,
<c_surname_rm>,<c_mingzi_rm>,<c_name_rm>,<c_created_by>,<c_created_date>,<c_modified_by>,<c_modified_date>,<c_self_bio>:)

(: structure of xml file-name is ("CBDBID" , c_personid(), ".xml"). There are < 375k xml files in BIOG_MAIN:)
let $collection := '/db/apps/cbdbtest/BIOG_MAIN'
let $solve := '/db/apps/cbdbtest/accessfiles'

(: Still have to modify the IN statement to include all files in $collection? :)

(: This is the recursive typeswitch function see: https://en.wikibooks.org/wiki/XQuery/Typeswitch_Transformations:)
declare function local:transform($nodes as node()*) as node()*
{
for $n in $nodes return
typeswitch ($n)
  case text() return $n
  case element (BIOG_MAIN) return local:transform($n/node())
  
  (: western dates from BIOG_MAIN table come here :)
  (: I'm thinking my google docs suggestion works better then the WSC way of doing birthdates can we lump together year-month-day into a single statement?) :)
  case element (c_birthyear) return <birth><date>{local:transform($n/node())}</date></birth>
  case element (c_by_month) return <birth when="yyy-{local:transform($n/node())}-dd" />
  case element (c_by_day) return <birth when="yyy-mm-{local:transform($n/node())}" />
  case element (c_deathyear) return <death><date>{local:transform($n/node())}</date></death>
  case element (c_dy_month) return <death when="yyy-{local:transform($n/node())}-dd" />
  case element (c_dy_day) return <death when="yyy-mm-{local:transform($n/node())}" />
  case element (c_fl_earliest_year) return <floruit notBefore="{local:transform($n/node())}" />
  case element (c_fl_latest_year) return <floruit notAfter="{local:transform($n/node())}" />
  (: check tei on index year type thingy :)
  case element (c_index_year) return <date>{local:transform($n/node())}</date>
  
  
  (: nianhao funk starts here go go david!! :)
  (:"by" = birthyear; moved below : case element (c_by_nh_code):)
  case element (c_by_nh_year) return 
  case element (c_by_day_gz) return 
  case element (c_by_range) return 
  (:"dy" = deathyear; moved below : case element (c_dy_nh_code):)
  case element (c_dy_nh_year) return 
  case element (c_dy_day_gz) return 
  case element (c_dy_range) return 
  
  
  (: combining the different transcriptions from BIOG_MAiN here!!!!:)
  case element (c_name) return <persName xml:lang="zh-alalc97"> {local:transform($n/node())} </persName>
  case element (c_surname) return <persName><surname xml:lang="zh-alalc97">{local:transform($n/node())}</surname>,</persName>
  case element (c_mingzi) return <persName><forename xml:lang="zh-alalc97">{local:transform($n/node())}</forename></persName>
  
  (: combining the different sections of original name (hz) from Biog_Main here:)
  case element (c_name_chn) return <persName type="Original name" xml:lang="zh-Hant">{local:transform($n/node())}</persName>
  case element (c_surname_chn) return <persName><surname xml:lang="zh-Hant">{local:transform($n/node())}</surname></persName>
  case element (c_mingzi_chn) return <persName><forename xml:lang="zh-Hant">{local:transform($n/node())}</forename></persName>
  
  (: notes :)
  case element (c_notes) return <note>{local:transform($n/node())}</note>
  case element (c_fl_ey_notes) return <note>{local:transform($n/node())}</note>
  case element (c_fl_ly_notes) return <note>{local:transform($n/node())}</note>
  
  (:So far so good! Now on to mapping the BIOG_MAIN foreign keys to their "xyz_CODES tables". All xyz_CODES tables are in the /accessfiles/ collection. I put these separate since i hope to reuse the code snippets :)
  
  case element (c_ethnicity_code) 
    for $cec in  .{local:transform($n/node())},
        $ec in $solve/doc("ETHNICITY_TRIBE_CODES.xml")/dataroot/ETHNICITY_TRIBE_CODES/c_ethnicity_code()
    where $cec = $ec
    return $solve/doc("ETHNICITY_TRIBE_CODES.xml")/dataroot/ETHNICITY_TRIBE_CODES/@c_ethnicity_code                                  
     
  case element (c_household_status_code) return 
  case element (c_tribe) return
  case element (c_dy) return 
  case element (c_choronym_code) return 
  case element (c_by_nh_code) return 
  case element (c_dy_nh_code) return
  
  (: more transliterated names yet to be figured out how and what to do with them :)
  case element (c_name_proper) return <persName type="">{local:transform($n/node())}</persName>
  case element (c_surname_proper) return <persName type="">{local:transform($n/node())}</persName>
  case element (c_mingzi_proper) return <persName type="">{local:transform($n/node())}</persName>
  case element (c_surname_rm) return <persName type="">{local:transform($n/node())}</persName>
  case element (c_mingzi_rm) return <persName type="">{local:transform($n/node())}</persName>
  case element (c_name_rm) return <persName type="">{local:transform($n/node())}</persName>
  
  (:no clue if this is accurate with regards to WSC??? "case" 
  if ( some $node in $excluded satisfies $n )
    then ( )
    else ( typeswitch ($n) ..... ):)
  case element (c_female) return <sex>{local:transform($n/node())}</sex>
  
  
   
    (: Some elements should remain unchanged thanks to the following: check wiki link on top to make sure
  <c_personid>, <TTSMQ_db_ID>, <MQWWLink>, <KyotoLink>, :)
  default return <tempnode>{local:transform($n/node())}</tempnode>
};
  
  (: These  elements can meet their maker once the extraction from cdbd is concluded. In the meantime lets keep them to be on the safe side 

    case element (tts_sysno) delete 
    case element (c_death_age) delete 
    case element (c_death_age_approx) delete 
    case element (c_source) delete 
    case element (c_pages) delete 
    case element (c_by_intercalary) delete 
    case element (c_dy_intercalary) delete 
    case element (c_pages) delete 
    case element (c_created_by) delete
    case element (c_created_date) delete
    case element (c_modified_by) delete
    case element (c_modified_date) delete
    case element (c_self_bio) delete :)

(: Finally! ADD these elements to each record: CBDBLINK is still pseudocode 
  <CBDBLink>'http://cbdb.fas.harvard.edu/cbdbapi/person.php?id=', c_personid()</CBDBLink>  
  <datasource>20131008CBDBaq</datasource>
  <created>timestamp</created>
  <creator>'Not the HRA'</creator> 
  <lastmodified>timestamp</lastmodified>
  <modifiedby>username</modifiedby>:)



(: see also marklogic example: http://docs.marklogic.com/guide/app-dev/typeswitch:)