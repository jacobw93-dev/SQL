--SET SCHEMA SAPHANADB;

DO
BEGIN
	DECLARE lv_fiscper NVARCHAR(7);
	DECLARE lv_fiscper3 NVARCHAR(3);
	DECLARE lv_fiscyear NVARCHAR(4);
	DECLARE lv_fiscvarnt NVARCHAR(2) = 'ZA';
	DECLARE lv_firstday NVARCHAR(8);
	DECLARE lv_keydate NVARCHAR(8);
	DECLARE lv_calweek NVARCHAR(6);
	DECLARE lv_calmonth NVARCHAR(6);
	DECLARE lv_calmonth2 NVARCHAR(2);
	DECLARE lv_calyear NVARCHAR(4);
	SELECT 
	  "PERIOD" INTO lv_fiscper 
	FROM 
	  "ZBW_IM_SNAPSHOT" 
	WHERE 
	  zactive = 'X';
                      
	lv_fiscyear := substr(: lv_fiscper, 1, 4);
	lv_fiscper3 := substr(: lv_fiscper, 5, 3);
	lv_firstday := substr(: lv_fiscper, 1, 4) || substr(: lv_fiscper, 6, 2) || '01';
	SELECT 
	  to_nvarchar(
	    LAST_DAY(
	      TO_DATE(lv_firstday, 'YYYYMMDD')
	    ), 
	    'YYYYMMDD'
	  ) INTO lv_keydate 
	FROM 
	  dummy;
	lv_calweek   := substr(isoweek(to_date(:lv_keydate,'YYYYMMDD')),1,4) ||
					substr(isoweek(to_date(:lv_keydate,'YYYYMMDD')),7,2);
	lv_calmonth  := substr( :lv_keydate,1,6);
	lv_calmonth2 := substr( :lv_keydate,5,2);
	lv_calyear   := substr( :lv_keydate,1,4);

          SELECT
            l."FISCPER"                                    , l."FISCPER3"                                , l."FISCYEAR"                                     ,
            l."FISCVARNT"                                  , l."CALDAY"                                  , l."CALWEEK"                                      ,
            l."CALMONTH"                                   , l."CALMONTH2"                               , l."CALYEAR"                                      ,
            l."/BIC/ZDAYOFMON"                             , l."G_UVVJ02"                                , l."/BIC/ZG_UWEIGH"                               ,
            l."LOC_CURRCY"                                 , l."BASE_UOM"                                , l."/BIC/ZARTNR02"                                ,
            l."MATERIAL"                                   , l."SALESORG"                                , l."COMP_CODE"                                    ,
            l."GN_R3_SSY"                                  , l."/BIC/ZMATERIAL"                          , l."G_CWWPH1"                                     ,
            l."G_CWWPH2"                                   , l."G_CWWPH3"                                , l."MATL_GROUP"                                   ,
            l."MATL_TYPE"                                  , l."G_CWWCOL"                                , l."/BIC/BORIGGLPR"                               ,
            coalesce(l."/BIC/ZORIGIN",'') as "/BIC/ZORIGIN", l."/BIC/ZARTNR02" as "MAT_PLANT"            , coalesce(mat_plant."VAL_CLASS",'') as "VAL_CLASS",
            coalesce(vc."GL_ACCOUNT",'')  as "GL_ACCOUNT"  , coalesce(vc."CHRT_ACCTS",'') as "CHRT_ACCTS", l."BATCH"                                        ,
            l."/BIC/ZPLANT"                                , l."PLANT"                                   , l."STOCKCAT"                                     ,
            l."STOCKTYPE"                                  , l."/BIC/ZSPSTKIND"                          , l."INDSPECSTK"                                   ,
            l."CUST_SALES"                                 , l."DIVISION"                                , l."DISTR_CHAN"                                   ,
            l.VTYPE                                        , l.VERSION                                   , l.CURTYPE                                        ,
            l."/BIC/ZDTYPE"                                , l."/BIC/BIMDTSRC"                           , '' as "/BIC/BFCVERS"                             ,
            l."/BIC/ZPRDACTFL"                             , l."/BIC/ZSCRAPFL"                           , l."/BIC/ZINVDVFL"                                ,
            l."/BIC/ZCUSTOMER"                             , l."RECORDMODE"                              , l."/BIC/ZPSTOCK_B"                               ,
            l."/BIC/ZPSTOCK_P"                             , l."/BIC/ZPSTOCK_E"                          , l."/BIC/ZPSTOKBLB"                               ,
            l."/BIC/ZPSTOCKBL"                             , l."/BIC/ZPSTOCQMB"                          , l."/BIC/ZPSTOCKQM"                               ,
            l."/BIC/ZPSTOB_TO"                             , l."/BIC/ZPSTOP_TO"                          , l."/BIC/ZPSTOE_TO"                               ,
            l."/BIC/ZPSTOBTOB"                             , l."/BIC/ZPSTOBLTO"                          , l."/BIC/ZPSTOBQMB"                               ,
            l."/BIC/ZPSTOBLQM"                             , l."/BIC/ZPSTOBPAL"                          , l."/BIC/ZPSTOPPAL"                               ,
            l."/BIC/ZPSTOEPAL"                             , l."/BIC/ZPSTOBPAB"                          , l."/BIC/ZPSTOBLPA"                               ,
            l."/BIC/ZPSTOQPAB"                             , l."/BIC/ZPSTOQMPA"                          , l."RECVALSTCK"                                   ,
            l."ISSVALSTCK"                                 , l."RECVS_VAL"                               , l."ISSVS_VAL"                                    ,
            l."RECBLOSTCK"                                 , l."ISSBLOSTCK"                              , l."RECQMSTCK"                                    ,
            l."ISSQMSTCK"                                  , l."/BIC/ZCURVAREC"                          , l."/BIC/ZCURVAISS"                               ,
            l."/BIC/ZPROD_ACT"                             , l."/BIC/ZPRO_TO"                            , l."/BIC/ZPRO_PAL"                                ,
            l."/BIC/ZPSTOVB"                               , l."/BIC/ZPSTOVP"                            , l."/BIC/ZPSTOVE"                                 ,
            --CURRENT VALUE
            case
              when (
                  mat_plant."/BIC/ZPRIIND" = 'V'
                )
                and (
                  mat_plant."/BIC/ZPEINH" <> 0
                )
                then l."/BIC/ZPSTOCK_B" * mat_plant."/BIC/ZMVAPRICE" / mat_plant."/BIC/ZPEINH"
              when (
                  mat_plant."/BIC/ZPRIIND" = 'S'
                )
                and (
                  mat_plant."/BIC/ZPEINH" <> 0
                )
                then l."/BIC/ZPSTOCK_B" * mat_plant."/BIC/ZSTDPRICE" / mat_plant."/BIC/ZPEINH"
                else 0
            end as "/BIC/ZPSTOCVB",
            case
              when (
                  mat_plant."/BIC/ZPRIIND" = 'V'
                )
                and (
                  mat_plant."/BIC/ZPEINH" <> 0
                )
                then l."/BIC/ZPSTOCK_P" * mat_plant."/BIC/ZMVAPRICE" / mat_plant."/BIC/ZPEINH"
              when (
                  mat_plant."/BIC/ZPRIIND" = 'S'
                )
                and (
                  mat_plant."/BIC/ZPEINH" <> 0
                )
                then l."/BIC/ZPSTOCK_P" * mat_plant."/BIC/ZSTDPRICE" / mat_plant."/BIC/ZPEINH"
                else 0
            end as "/BIC/ZPSTOCVP",
            case
              when (
                  mat_plant."/BIC/ZPRIIND" = 'V'
                )
                and (
                  mat_plant."/BIC/ZPEINH" <> 0
                )
                then l."/BIC/ZPSTOCK_E" * mat_plant."/BIC/ZMVAPRICE" / mat_plant."/BIC/ZPEINH"
              when (
                  mat_plant."/BIC/ZPRIIND" = 'S'
                )
                and (
                  mat_plant."/BIC/ZPEINH" <> 0
                )
                then l."/BIC/ZPSTOCK_E" * mat_plant."/BIC/ZSTDPRICE" / mat_plant."/BIC/ZPEINH"
                else 0
            end as "/BIC/ZPSTOCVE", l."/BIC/ZPSTOE_TO" as "/BIC/BQTYTO", l."RECORD",
            l."SQL__PROCEDURE__SOURCE__RECORD"
          FROM
            (
              SELECT
                k."FISCPER"                                , k."FISCPER3"                               , k."FISCYEAR"                               ,
                k."FISCVARNT"                              , k."CALDAY"                                 , k."CALWEEK"                                ,
                k."CALMONTH"                               , k."CALMONTH2"                              , k."CALYEAR"                                ,
                k."/BIC/ZDAYOFMON"                         , k."G_UVVJ02"                               , k."/BIC/ZG_UWEIGH"                         ,
                k."LOC_CURRCY"                             , k."BASE_UOM"                               , k."/BIC/ZARTNR02"                          ,
                k."MATERIAL"                               , k."SALESORG"                               , k."COMP_CODE"                              ,
                k."GN_R3_SSY"                              , k."/BIC/ZMATERIAL"                         , k."G_CWWPH1"                               ,
                k."G_CWWPH2"                               , k."G_CWWPH3"                               , k."MATL_GROUP"                             ,
                k."MATL_TYPE"                              , k."G_CWWCOL"                               , k."/BIC/BORIGGLPR"                         ,
                k."/BIC/ZORIGIN"                           , k."/BIC/ZPLANT"                            , k."PLANT"                                  ,
                k."STOCKCAT"                               , k."STOCKTYPE"                              , k."/BIC/ZSPSTKIND"                         ,
                k."INDSPECSTK"                             , k."CUST_SALES"                             , k."DIVISION"                               ,
                k."DISTR_CHAN"                             , k.VTYPE                                    , k.VERSION                                  ,
                k.CURTYPE                                  , k."/BIC/ZDTYPE"                            , k."/BIC/BIMDTSRC"                          ,
                k."/BIC/ZPRDACTFL"                         , k."/BIC/ZSCRAPFL"                          , k."/BIC/ZINVDVFL"                          ,
                k."/BIC/ZCUSTOMER"                         , k."BATCH"                                  , k."RECORDMODE"                             ,
                SUM(k."/BIC/ZPSTOCK_B") as "/BIC/ZPSTOCK_B", SUM(k."/BIC/ZPSTOCK_P") as "/BIC/ZPSTOCK_P", SUM(k."/BIC/ZPSTOCK_E") as "/BIC/ZPSTOCK_E",
                SUM(k."/BIC/ZPSTOKBLB") as "/BIC/ZPSTOKBLB", SUM(k."/BIC/ZPSTOCKBL") as "/BIC/ZPSTOCKBL", SUM(k."/BIC/ZPSTOCQMB") as "/BIC/ZPSTOCQMB",
                SUM(k."/BIC/ZPSTOCKQM") as "/BIC/ZPSTOCKQM", SUM(k."/BIC/ZPSTOB_TO") as "/BIC/ZPSTOB_TO", SUM(k."/BIC/ZPSTOP_TO") as "/BIC/ZPSTOP_TO",
                SUM(k."/BIC/ZPSTOE_TO") as "/BIC/ZPSTOE_TO", SUM(k."/BIC/ZPSTOBTOB") as "/BIC/ZPSTOBTOB", SUM(k."/BIC/ZPSTOBLTO") as "/BIC/ZPSTOBLTO",
                SUM(k."/BIC/ZPSTOBQMB") as "/BIC/ZPSTOBQMB", SUM(k."/BIC/ZPSTOBLQM") as "/BIC/ZPSTOBLQM", SUM(k."/BIC/ZPSTOBPAL") as "/BIC/ZPSTOBPAL",
                SUM(k."/BIC/ZPSTOPPAL") as "/BIC/ZPSTOPPAL", SUM(k."/BIC/ZPSTOEPAL") as "/BIC/ZPSTOEPAL", SUM(k."/BIC/ZPSTOBPAB") as "/BIC/ZPSTOBPAB",
                SUM(k."/BIC/ZPSTOBLPA") as "/BIC/ZPSTOBLPA", SUM(k."/BIC/ZPSTOQPAB") as "/BIC/ZPSTOQPAB", SUM(k."/BIC/ZPSTOQMPA") as "/BIC/ZPSTOQMPA",
                SUM(k."RECVALSTCK")     as "RECVALSTCK"    , SUM(k."ISSVALSTCK") as "ISSVALSTCK"        , SUM(k."RECVS_VAL") as "RECVS_VAL"          ,
                SUM(k."ISSVS_VAL")      as "ISSVS_VAL"     , SUM(k."RECBLOSTCK") as "RECBLOSTCK"        , SUM(k."ISSBLOSTCK") as "ISSBLOSTCK"        ,
                SUM(k."RECQMSTCK")      as "RECQMSTCK"     , SUM(k."ISSQMSTCK") as "ISSQMSTCK"          , SUM(k."/BIC/ZCURVAREC") as "/BIC/ZCURVAREC",
                SUM(k."/BIC/ZCURVAISS") as "/BIC/ZCURVAISS", SUM(k."/BIC/ZPROD_ACT") as "/BIC/ZPROD_ACT", SUM(k."/BIC/ZPRO_TO") as "/BIC/ZPRO_TO"    ,
                SUM(k."/BIC/ZPRO_PAL")  as "/BIC/ZPRO_PAL" , SUM(k."/BIC/ZPSTOVB") as "/BIC/ZPSTOVB"    , SUM(k."/BIC/ZPSTOVP") as "/BIC/ZPSTOVP"    ,
                SUM(k."/BIC/ZPSTOVE")   as "/BIC/ZPSTOVE"  , k."RECORD"                                 , k."SQL__PROCEDURE__SOURCE__RECORD"
              FROM
                (
                  SELECT
                    --time dimension
                    :lv_fiscper                           as "FISCPER"       , :lv_fiscper3 as "FISCPER3", :lv_fiscyear as "FISCYEAR",
                    a."FISCVARNT"                                            , :lv_keydate as "CALDAY"                             , :lv_calweek as "CALWEEK"  ,
                    :lv_calmonth                          as "CALMONTH"      , :lv_calmonth2 as "CALMONTH2"                        , :lv_calyear as "CALYEAR"  ,
                    substr(:lv_keydate,1,2)               as "/BIC/ZDAYOFMON",
                    --units
                    'ST' as "G_UVVJ02", 'TO' as "/BIC/ZG_UWEIGH", a."LOC_CURRCY",
                    'ST' as "BASE_UOM", --override a."BASE_UOM" -> effectively no unit conversion to speed up performance
                    --221003 a."BASE_UOM" as "BASE_UOM" -> ROH materials with many Base UoMs to be reported using Std Inventory Cube
                    --dimensions
                    a."/BIC/ZARTNR02", a."MATERIAL",
                    case
                      when a."SALESORG" = '9000'
                        then '300'
                        else a."SALESORG"
                    end as "SALESORG",
                    case
                      when a."COMP_CODE" = '9000'
                        then '300'
                        else a."COMP_CODE"
                    end as "COMP_CODE", a."GN_R3_SSY", a."/BIC/ZMATERIAL",
                    a."G_CWWPH1"      , a."G_CWWPH2" , a."G_CWWPH3"      ,
                    a."MATL_GROUP"    , a."MATL_TYPE", a."G_CWWCOL"      ,
                    --derive origin of production
                    case
                      when a."SALESORG"       = '210'
                        and m1."/BIC/ZORIGIN" = '200'
                        then '01'
                      when a."SALESORG"       = '630'
                        and m1."/BIC/ZORIGIN" = '600'
                        then '01'
                      when m1."/BIC/ZORIGIN" = ''
                        then '01'
                      when a."SALESORG" = m1."/BIC/ZORIGIN"
                        then '01'
                      when m1."/BIC/ZORIGIN" = '999'
                        then '03'
                      when a."SALESORG" <> m1."/BIC/ZORIGIN"
                        then '02'
                        else '00'
                    end as "/BIC/BORIGGLPR", coalesce(m1."/BIC/ZORIGIN",'') as "/BIC/ZORIGIN", a."/BIC/ZPLANT"       ,
                    a."PLANT"              , a."STOCKCAT"                                    , a."STOCKTYPE"         ,
                    a."/BIC/ZSPSTKIND"     , a."INDSPECSTK"                                  , a."CUST_SALES"        ,
                    a."DIVISION"           , a."DISTR_CHAN"                                  , a.VTYPE               ,
                    a.VERSION              , a.CURTYPE                                       , 'CUM' as "/BIC/ZDTYPE",
                    a."/BIC/BIMDTSRC"      , a."/BIC/ZPRDACTFL"                              , a."/BIC/ZSCRAPFL"     ,
                    a."/BIC/ZINVDVFL"      , a."/BIC/ZCUSTOMER"                              , a."BATCH"             ,
                    a."RECORDMODE"         ,
                    --measures
                    ---------PIECES---------
                    case
                      when a."FISCPER" < :lv_fiscper
                        then a."RECVALSTCK" - a."ISSVALSTCK"
                        else 0
                    end as "/BIC/ZPSTOCK_B",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."RECVALSTCK" - a."ISSVALSTCK"
                        else 0
                    end as "/BIC/ZPSTOCK_P", a."RECVALSTCK" - a."ISSVALSTCK" as "/BIC/ZPSTOCK_E",
                    case
                      when a."FISCPER" < :lv_fiscper
                        then a."RECBLOSTCK" - a."ISSBLOSTCK"
                        else 0
                    end as "/BIC/ZPSTOKBLB", a."RECBLOSTCK" - a."ISSBLOSTCK" as "/BIC/ZPSTOCKBL",
                    case
                      when a."FISCPER" < :lv_fiscper
                        then a."RECQMSTCK" - a."ISSQMSTCK"
                        else 0
                    end as "/BIC/ZPSTOCQMB", a."RECQMSTCK" - a."ISSQMSTCK" as "/BIC/ZPSTOCKQM",
                    ---------TONNES 5x---------
                    case
                      when a."FISCPER"      < :lv_fiscper
                        and m2."UNIT_OF_WT" = 'KG'
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT" / 1000
                      when a."FISCPER"      < :lv_fiscper
                        and m2."UNIT_OF_WT" = 'G'
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT" / 1000000
                      when a."FISCPER"      < :lv_fiscper
                        and m2."UNIT_OF_WT" = 'TO'
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT"
                        else 0
                    end as "/BIC/ZPSTOB_TO",
                    case
                      when a."FISCPER"      = :lv_fiscper
                        and m2."UNIT_OF_WT" = 'KG'
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT" / 1000
                      when a."FISCPER"      = :lv_fiscper
                        and m2."UNIT_OF_WT" = 'G'
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT" / 1000000
                      when a."FISCPER"      = :lv_fiscper
                        and m2."UNIT_OF_WT" = 'TO'
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT"
                        else 0
                    end as "/BIC/ZPSTOP_TO",
                    case
                      when m2."UNIT_OF_WT" = 'KG'
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT" / 1000
                      when m2."UNIT_OF_WT" = 'G'
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT" / 1000000
                      when m2."UNIT_OF_WT" = 'TO'
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT"
                        else 0
                    end as "/BIC/ZPSTOE_TO",
                    case
                      when a."FISCPER"      < :lv_fiscper
                        and m2."UNIT_OF_WT" = 'KG'
                        then (a."RECBLOSTCK" - a."ISSBLOSTCK") * m2."NET_WEIGHT" / 1000
                      when a."FISCPER"      < :lv_fiscper
                        and m2."UNIT_OF_WT" = 'G'
                        then (a."RECBLOSTCK" - a."ISSBLOSTCK") * m2."NET_WEIGHT" / 1000000
                      when a."FISCPER"      < :lv_fiscper
                        and m2."UNIT_OF_WT" = 'TO'
                        then (a."RECBLOSTCK" - a."ISSBLOSTCK") * m2."NET_WEIGHT"
                        else 0
                    end as "/BIC/ZPSTOBTOB",
                    case
                      when m2."UNIT_OF_WT" = 'KG'
                        then (a."RECBLOSTCK" - a."ISSBLOSTCK") * m2."NET_WEIGHT" / 1000
                      when m2."UNIT_OF_WT" = 'G'
                        then (a."RECBLOSTCK" - a."ISSBLOSTCK") * m2."NET_WEIGHT" / 1000000
                      when m2."UNIT_OF_WT" = 'TO'
                        then (a."RECBLOSTCK" - a."ISSBLOSTCK") * m2."NET_WEIGHT"
                        else 0
                    end as "/BIC/ZPSTOBLTO",
                    case
                      when a."FISCPER"      < :lv_fiscper
                        and m2."UNIT_OF_WT" = 'KG'
                        then (a."RECQMSTCK" - a."ISSQMSTCK") * m2."NET_WEIGHT" / 1000
                      when a."FISCPER"      < :lv_fiscper
                        and m2."UNIT_OF_WT" = 'G'
                        then (a."RECQMSTCK" - a."ISSQMSTCK") * m2."NET_WEIGHT" / 1000000
                      when a."FISCPER"      < :lv_fiscper
                        and m2."UNIT_OF_WT" = 'TO'
                        then (a."RECQMSTCK" - a."ISSQMSTCK") * m2."NET_WEIGHT"
                        else 0
                    end as "/BIC/ZPSTOBQMB",
                    case
                      when m2."UNIT_OF_WT" = 'KG'
                        then (a."RECQMSTCK" - a."ISSQMSTCK") * m2."NET_WEIGHT" / 1000
                      when m2."UNIT_OF_WT" = 'G'
                        then (a."RECQMSTCK" - a."ISSQMSTCK") * m2."NET_WEIGHT" / 1000000
                      when m2."UNIT_OF_WT" = 'TO'
                        then (a."RECQMSTCK" - a."ISSQMSTCK") * m2."NET_WEIGHT"
                        else 0
                    end as "/BIC/ZPSTOBLQM",
                    ---------PALLETS 5x---------
                    case
                      when a."FISCPER" < :lv_fiscper
                        then (a."RECVALSTCK" - a."ISSVALSTCK") / ifnull(pal."NUMERATOR",1)
                        else 0
                    end as "/BIC/ZPSTOBPAL",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then (a."RECVALSTCK" - a."ISSVALSTCK") / ifnull(pal."NUMERATOR",1)
                        else 0
                    end as "/BIC/ZPSTOPPAL", (a."RECVALSTCK" - a."ISSVALSTCK") / ifnull(pal."NUMERATOR",1) as "/BIC/ZPSTOEPAL",
                    case
                      when a."FISCPER" < :lv_fiscper
                        then (a."RECBLOSTCK" - a."ISSBLOSTCK") / ifnull(pal."NUMERATOR",1)
                        else 0
                    end as "/BIC/ZPSTOBPAB", (a."RECBLOSTCK" - a."ISSBLOSTCK") / ifnull(pal."NUMERATOR",1) as "/BIC/ZPSTOBLPA",
                    case
                      when a."FISCPER" < :lv_fiscper
                        then (a."RECQMSTCK" - a."ISSQMSTCK") / ifnull(pal."NUMERATOR",1)
                        else 0
                    end as "/BIC/ZPSTOQPAB", (a."RECQMSTCK" - a."ISSQMSTCK") / ifnull(pal."NUMERATOR",1) as "/BIC/ZPSTOQMPA",
                    ---------BASE MEASURES 10x---------
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."RECVALSTCK"
                        else 0
                    end as "RECVALSTCK",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."ISSVALSTCK"
                        else 0
                    end as "ISSVALSTCK",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."RECVS_VAL"
                        else 0
                    end as "RECVS_VAL",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."ISSVS_VAL"
                        else 0
                    end as "ISSVS_VAL",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."RECBLOSTCK"
                        else 0
                    end as "RECBLOSTCK",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."ISSBLOSTCK"
                        else 0
                    end as "ISSBLOSTCK",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."RECQMSTCK"
                        else 0
                    end as "RECQMSTCK",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."ISSQMSTCK"
                        else 0
                    end as "ISSQMSTCK",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."/BIC/ZCURVAREC"
                        else 0
                    end as "/BIC/ZCURVAREC",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."/BIC/ZCURVAISS"
                        else 0
                    end as "/BIC/ZCURVAISS",
                    ---------ACTUAL PRODUCTION 3x---------
                    case
                      when a."FISCPER" = :lv_fiscper
                        and (
                          a."/BIC/ZPRDACTFL"   = 'X'
                          or a."/BIC/ZSCRAPFL" = 'X'
                          or a."/BIC/ZINVDVFL" = 'X'
                        )
                        then a."RECVALSTCK" - a."ISSVALSTCK"
                        else 0
                    end as "/BIC/ZPROD_ACT",
                    case
                      when a."FISCPER"      = :lv_fiscper
                        and m2."UNIT_OF_WT" = 'KG'
                        and (
                          a."/BIC/ZPRDACTFL"   = 'X'
                          or a."/BIC/ZSCRAPFL" = 'X'
                          or a."/BIC/ZINVDVFL" = 'X'
                        )
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT" / 1000
                      when a."FISCPER"      = :lv_fiscper
                        and m2."UNIT_OF_WT" = 'G'
                        and (
                          a."/BIC/ZPRDACTFL"   = 'X'
                          or a."/BIC/ZSCRAPFL" = 'X'
                          or a."/BIC/ZINVDVFL" = 'X'
                        )
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT" / 1000000
                      when a."FISCPER"      = :lv_fiscper
                        and m2."UNIT_OF_WT" = 'TO'
                        and (
                          a."/BIC/ZPRDACTFL"   = 'X'
                          or a."/BIC/ZSCRAPFL" = 'X'
                          or a."/BIC/ZINVDVFL" = 'X'
                        )
                        then (a."RECVALSTCK" - a."ISSVALSTCK") * m2."NET_WEIGHT"
                        else 0
                    end as "/BIC/ZPRO_TO",
                    case
                      when a."FISCPER" = :lv_fiscper
                        and (
                          a."/BIC/ZPRDACTFL"   = 'X'
                          or a."/BIC/ZSCRAPFL" = 'X'
                          or a."/BIC/ZINVDVFL" = 'X'
                        )
                        then (a."RECVALSTCK" - a."ISSVALSTCK") / ifnull(pal."NUMERATOR",1)
                        else 0
                    end as "/BIC/ZPRO_PAL",
                    ---------VALUE CALCULATION 3x---------
                    case
                      when a."FISCPER" < :lv_fiscper
                        then a."RECVS_VAL" - a."ISSVS_VAL"
                        else 0
                    end as "/BIC/ZPSTOVB",
                    case
                      when a."FISCPER" = :lv_fiscper
                        then a."RECVS_VAL" - a."ISSVS_VAL"
                        else 0
                    end as "/BIC/ZPSTOVP",
                    case
                      when a."FISCPER" <= :lv_fiscper
                        then a."RECVS_VAL" - a."ISSVS_VAL"
                        else 0
                    end as "/BIC/ZPSTOVE",
                    a."RECORD", a."SQL__PROCEDURE__SOURCE__RECORD"
                  FROM
                    "/BIC/AIM_OTB062" AS a
                    --join material non-time dependent master data
                    LEFT OUTER JOIN
                      (
                        select
                          "/BIC/ZMATERIAL", "MATL_GROUP", "MATL_TYPE",
                          "G_CWWPH1"      , "G_CWWPH2"  , "G_CWWPH3" ,
                          "G_CWWCOL"      , "/BIC/ZORIGIN"
                        from
                          "/BIC/PZMATERIAL"
                        where
                          "OBJVERS" = 'A'
                      )
                      as m1
                      ON
                        m1."/BIC/ZMATERIAL" = a."/BIC/ZARTNR02"
                    --join material weight
                    LEFT OUTER JOIN
                      (
                        select
                          "/BIC/ZMATERIAL", "DATETO", "DATEFROM",
                          "NET_WEIGHT"    , "UNIT_OF_WT"
                        from
                          "/BIC/QZMATERIAL"
                        where
                          "OBJVERS"       = 'A'
                          and "DATEFROM" <= lv_keydate
                          and "DATETO"   >= :lv_keydate
                      )
                      as m2
                      ON
                        m2."/BIC/ZMATERIAL" = a."/BIC/ZARTNR02"
                    --join material unit conversion into pallets
                    LEFT OUTER JOIN
                      (
                        select
                          "MATERIAL", "GN_R3_SSY", "MAT_UNIT",
                          "NUMERATOR"
                        from
                          "/BI0/PMAT_UNIT"
                        where
                          "OBJVERS"       = 'A'
                          and "MAT_UNIT"  = 'PAL'
                          and "GN_R3_SSY" = 'B1'
                      )
                      as pal
                      ON
                        pal."MATERIAL" = a."/BIC/ZARTNR02"
                  WHERE
                    a."FISCPER" <= :lv_fiscper
                )
                as k
              GROUP BY
                k."FISCPER"       , k."FISCPER3"      , k."FISCYEAR"      ,
                k."FISCVARNT"     , k."CALDAY"        , k."CALWEEK"       ,
                k."CALMONTH"      , k."CALMONTH2"     , k."CALYEAR"       ,
                k."/BIC/ZDAYOFMON", k."G_UVVJ02"      , k."/BIC/ZG_UWEIGH",
                k."LOC_CURRCY"    , k."BASE_UOM"      , k."/BIC/ZARTNR02" ,
                k."MATERIAL"      , k."SALESORG"      , k."COMP_CODE"     ,
                k."GN_R3_SSY"     , k."/BIC/ZMATERIAL", k."G_CWWPH1"      ,
                k."G_CWWPH2"      , k."G_CWWPH3"      , k."MATL_GROUP"    ,
                k."MATL_TYPE"     , k."G_CWWCOL"      , k."/BIC/BORIGGLPR",
                k."/BIC/ZORIGIN"  , k."/BIC/ZPLANT"   , k."PLANT"         ,
                k."STOCKCAT"      , k."STOCKTYPE"     , k."/BIC/ZSPSTKIND",
                k."INDSPECSTK"    , k."CUST_SALES"    , k."DIVISION"      ,
                k."DISTR_CHAN"    , k.VTYPE           , k.VERSION         ,
                k.CURTYPE         , k."/BIC/ZDTYPE"   , k."/BIC/BIMDTSRC" ,
                k."/BIC/ZPRDACTFL", k."/BIC/ZSCRAPFL" , k."/BIC/ZINVDVFL" ,
                k."/BIC/ZCUSTOMER", k."BATCH"         , k."RECORDMODE"    ,
                k."RECORD"        , k."SQL__PROCEDURE__SOURCE__RECORD"
            )
            as l
            --join material prices
            LEFT OUTER JOIN
              (
                SELECT
                  "PLANT"    , "MAT_PLANT"   , "/BIC/ZSTDPRICE",
                  "VAL_CLASS", "/BIC/ZPRIIND", "/BIC/ZMVAPRICE",
                  "/BIC/ZPEINH"
                FROM
                  "/BI0/PMAT_PLANT"
                WHERE
                  "OBJVERS"       = 'A'
                  and "GN_R3_SSY" = 'B1'
              )
              as mat_plant
              ON
                mat_plant."PLANT"         = l."PLANT"
                AND mat_plant."MAT_PLANT" = l."/BIC/ZARTNR02"
            --valuation class / GL Account
            LEFT OUTER JOIN
              (
                SELECT
                  "VAL_CLASS", "GL_ACCOUNT", "CHRT_ACCTS"
                FROM
                  "/BI0/PVAL_CLASS"
                WHERE
                  "OBJVERS"       = 'A'
                  and "GN_R3_SSY" = 'B1'
              )
              as vc
              ON
                mat_plant."VAL_CLASS" = vc."VAL_CLASS"
          ;
END;