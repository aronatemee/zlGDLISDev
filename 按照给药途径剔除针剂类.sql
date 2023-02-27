
--直接将入参转换为JSON
select * from (
select json_array_elements(json_string)->>'Drug_Common_Name' Drug_Common_Name
, json_array_elements(json_string)->>'Grdrug_Detail_Id' Grdrug_Detail_Id
, json_array_elements(json_string)->>'Grdrug_Id' Grdrug_Id
, json_array_elements(json_string)->>'Take_No' Take_No
, json_array_elements(json_string)->>'Order_Id' Order_Id
, json_array_elements(json_string)->>'Order_Related_Id' Order_Related_Id
, json_array_elements(json_string)->>'Cost_Id' Cost_Id
, json_array_elements(json_string)->>'Rcp_No' Rcp_No
, json_array_elements(json_string)->>'Pati_Id' Pati_Id
, json_array_elements(json_string)->>'Pati_Page_Id' Pati_Page_Id
, json_array_elements(json_string)->>'Pati_Name' Pati_Name
, json_array_elements(json_string)->>'Pati_Sex' Pati_Sex
, json_array_elements(json_string)->>'Pati_Age' Pati_Age
, json_array_elements(json_string)->>'Inpatient_Num' Inpatient_Num
, json_array_elements(json_string)->>'Pati_Bed' Pati_Bed
, json_array_elements(json_string)->>'Min_Unit_Quantity' Min_Unit_Quantity
, json_array_elements(json_string)->>'Min_Unit' Min_Unit
, json_array_elements(json_string)->>'Single' Single
, json_array_elements(json_string)->>'Once_Dosa_Unit' Once_Dosa_Unit
, json_array_elements(json_string)->>'Rcpdtl_Excs_Desc' Rcpdtl_Excs_Desc
, json_array_elements(json_string)->>'Rcpdtl_Drask' Rcpdtl_Drask
, json_array_elements(json_string)->>'Medication_Frequency' Medication_Frequency
, json_array_elements(json_string)->>'Usage' Usage
, json_array_elements(json_string)->>'Time_Plan' Time_Plan
, json_array_elements(json_string)->>'First_Time' First_Time
, json_array_elements(json_string)->>'Last_Time' Last_Time
, json_array_elements(json_string)->>'Effective_Time' Effective_Time
, json_array_elements(json_string)->>'Recipe_Plcdept_Id' Recipe_Plcdept_Id
, json_array_elements(json_string)->>'Recipe_Plcdept' Recipe_Plcdept
, json_array_elements(json_string)->>'Recipe_Placer_Id' Recipe_Placer_Id
, json_array_elements(json_string)->>'Recipe_Placer' Recipe_Placer
, json_array_elements(json_string)->>'Apply_Time' Apply_Time
, json_array_elements(json_string)->>'Storehouse_Unit_Quantity' Storehouse_Unit_Quantity
, json_array_elements(json_string)->>'Storehouse_Unit' Storehouse_Unit
, json_array_elements(json_string)->>'Storehouse_Id' Storehouse_Id
, json_array_elements(json_string)->>'Storehouse' Storehouse
, json_array_elements(json_string)->>'Takedept_Id' Takedept_Id
, json_array_elements(json_string)->>'Takedept_Name' Takedept_Name
, json_array_elements(json_string)->>'Drug_Id' Drug_Id
, json_array_elements(json_string)->>'Drug_Code' Drug_Code
, json_array_elements(json_string)->>'Drug_Name' Drug_Name
, json_array_elements(json_string)->>'Drug_Strength' Drug_Strength
, json_array_elements(json_string)->>'Drug_Manufacturer_Abbr' Drug_Manufacturer_Abbr
, json_array_elements(json_string)->>'Lot_No' Lot_No
, json_array_elements(json_string)->>'Exp_Date' Exp_Date
, json_array_elements(json_string)->>'Allocation_No' Allocation_No
, json_array_elements(json_string)->>'Grdrug_Dispsr' Grdrug_Dispsr
, json_array_elements(json_string)->>'Grdrug_Drugvr_Id' Grdrug_Drugvr_Id
, json_array_elements(json_string)->>'Grdrug_Drugvr' Grdrug_Drugvr
, json_array_elements(json_string)->>'Grdrug_Time' Grdrug_Time
, json_array_elements(json_string)->>'Grdrug_No' Grdrug_No
, json_array_elements(json_string)->>'Packing_Status' Packing_Status
, json_array_elements(json_string)->>'Batch_No' Batch_No
, json_array_elements(json_string)->>'Retail_Price' Retail_Price
, json_array_elements(json_string)->>'Retail_Chrg' Retail_Chrg
, json_array_elements(json_string)->>'Manual_Dispensing' Manual_Dispensing
, json_array_elements(json_string)->>'Printer' Printer
, json_array_elements(json_string)->>'Printing_Time' Printing_Time
, json_array_elements(json_string)->>'Unreturned_Min_Unit_Quantity' Unreturned_Min_Unit_Quantity
, json_array_elements(json_string)->>'Unreturned_Quantity' Unreturned_Quantity
, json_array_elements(json_string)->>'Storagehouse_Unit_Content' Storagehouse_Unit_Content
, json_array_elements(json_string)->>'Storagehouse_Unit' Storagehouse_Unit
from 
(
	select (''|| {:CS} ||'') ::json json_string
) as table_1
) as table_2
--针剂类不打印摆药单
where table_2.usage not in ('肌肉注射','胰岛素泵持续皮下注射-首日','胰岛素泵持续皮下注射-继日','IV(5ml注射费)','儿)IV(注射费)','IV(20ml注射费)','IV(30ml注射费)','IV(50ml注射费)','皮内注射','穴位注射','局部注射','冲管(不加药治疗费)','冲管','皮下注射','头皮输液(注射费)','术中用','宫颈注射(注射费)','IM','IV','静滴(注射费）','玻璃体内注射','结膜下注射','球后注射','静滴接瓶(注）','局麻（治疗费）','局麻','治疗用','静脉推注(免费)','造影用(CTA)','造影用(CT增强)','静滴','静滴接瓶','造影用(磁共振)	') 
order by table_2.Pati_Name;