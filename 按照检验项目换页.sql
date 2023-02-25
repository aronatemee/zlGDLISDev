
--某标本包含的医嘱及其对应的指标;
select *, ROW_NUMBER() OVER(partition by 合管医嘱) as 序号
from (WITH TEMP_1 AS (SELECT d.id AS 报告id
					, d."json" #>> '{specimen, 0, reference1Specimen}' AS 标本ID
					, d."json" #>> '{specimen, 0, display}' AS 标本采集容器
					, json_array_length(d."json" #> '{basedOn}') AS 合管医嘱数
					, json_array_elements(d."json" #> '{basedOn}') #>> '{display}' AS 合管医嘱
					, d."json" #>> '{issued}' AS 报告时间
					, d."json" #>> '{ex_performer_Practitioner_display}' AS 报告人
					, d."json" #>> '{ex_resultsInterpreter_Practitioner_display}' AS 结果解释人
					, d."json" #>> '{effectiveDateTime}' AS 审核时间
					, d."json" #>> '{subject_display}' AS 病人姓名
					, d."json" #>> '{ex_gender_display}' AS 性别
					, d."json" #>> '{ex_resultsToHisPractitioner_display}' AS 报告发布人
                                        , d."json" #>> '{specimen, 0, display}' AS 标本
				FROM diagnosticreport d 
				WHERE CAST(d.id AS TEXT) = (select ('' || {:CONDITION_IN} || '') :: json ->> 'id') ),--正式发布时替换为入参，入参在这儿，报告id
TEMP_2 AS (SELECT li."name" AS 项目, o."name" AS 指标
			FROM labitem_observationdefinition lo 
			JOIN lab_item li ON lo.lab_item_id = li.id 
			JOIN observationdefinition o ON lo.observationdefinition_id = o.id 
			ORDER BY li."name"), 
TEMP_3 AS (SELECT CAST(id AS TEXT) AS 标本ID
			, "json" #>> '{processing, 0, ex_performer_name}' AS 采集人
			, "json" #>> '{collection_collectedDateTime}' AS 采集时间
			, "json" #>> '{processing, 0, ex_exe_organizetion_name}' AS 采集科室
			, "json" ->> 'bodySite_coding_display' AS 标本类型
			, "json" ->> 'method_coding_display' AS 采集方式
			, "json" #>> '{container, 0, type_coding_display}' AS 标本容器
			, "json" #>> '{container, 0, ex_cap_coding_display}' AS 容器颜色
			, "json" #>> '{request, 0, apply_dept}' AS 开单科室
			, "json" #>> '{request, 0, apply_staff}' AS 开单人
			, "json" #>> '{request, 0, apply_time}' AS 开单时间
			, "json" ->> 'condition_coding_display' AS 当前标本状态
			, "json" ->> 'subject_display' AS 患者名称
			, "json" ->> 'ex_age' AS 患者年龄
			, "json" ->> 'ex_gender_display' AS 患者性别
			, "json" ->> 'ex_birthDate' AS 患者出生日期
			, "json" ->> 'ex_encounter_display' AS 就诊类型
			, CASE "json" ->> 'ex_priority'  WHEN 'routine' THEN '' ELSE '急' END AS 紧急标识
			, "json" ->> 'accessionIdentifier_value' AS 标本号
			, "json" ->> 'ex_encounter_reference1encounter' AS 就诊号
			, "json" ->> 'ex_bed_no' AS 床号
			, "json" #>> '{container, 0, identifier_value1bc}' AS 标本条码
			, "json" ->> 'note_text' AS 备注
		FROM specimen s 
		WHERE status = 'available'), 
--TEMP_4必须要筛选，保证没有重复的标本名称，才能和TEMP_2进行连接
TEMP_4 AS (SELECT  "json" ->> 'code_coding_code' AS 指标编码
			, "json" ->> 'code_coding_display' AS 指标名称
			, "json" ->> 'valueQuantity_value' AS 指标结果
			, "json" ->> 'valueQuantity_unit' AS 单位
			, "json" ->> 'partOf_display' AS 标本状态
			, "json" #>> '{performer, 0, display}' AS 检验技师
			, "json" ->> 'device_display' AS 仪器
			, "json" ->> 'specimen_reference1Specimen' AS 标本ID
			, "json" ->> 'subject_display' AS 患者姓名
			, "json" #>> '{referenceRange, 0, reference_display}' AS 参考范围
			, "json" #>> '{ex_observationdefinition_id}' AS 指标ID
			, "json" #>> '{device_reference1Device}' AS 设备ID
			, CAST("json" #>> '{ex_sno}' AS INTEGER) AS 指标序号--(?)
			, CAST("json" #>> '{referenceRange, 0, ex_sno}' as INTEGER) as 指标序号1
			, CASE "json" #>> '{interpretation, 0, coding_display}' WHEN 'N' THEN '' ELSE 
"json" #>> '{interpretation, 0, coding_display}'  END AS 结果解释
			, "json" #>> '{preferredReportName}' AS 英文名称
		FROM observation o 
		WHERE "json" ->> 'specimen_reference1Specimen' = (SELECT "json" #>> '{specimen, 0, reference1Specimen}' FROM diagnosticreport WHERE CAST(id AS TEXT) = (select ('' || {:CONDITION_IN} || '') :: json ->> 'id'))--通过报告id查找标本id
		AND o.status <> 'cancelled'
		ORDER BY "json" ->> 'specimen_reference1Specimen'),
TEMP_5 AS (SELECT CAST("specimen_reference1Specimen" AS TEXT) AS 标本ID
			, issued_datetime AS 检验时间 FROM observation_rec or2 
		WHERE status <> 'cancelled'
		AND CAST("specimen_reference1Specimen" AS TEXT) = (SELECT "json" #>> '{specimen, 0, reference1Specimen}' FROM diagnosticreport WHERE CAST(id AS TEXT) = (select ('' || {:CONDITION_IN} || '') :: json ->> 'id'))--通过报告id查找标本id
		LIMIT 1),
TEMP_6 AS (SELECT do2.sno AS do2序号, do2.observationdefinition_id AS do2指标ID, do2.devicedefinition_id AS do2仪器ID FROM devicedefinition_observationdefinition do2)
SELECT DISTINCT TEMP_1.合管医嘱, TEMP_1.标本, TEMP_2.指标, TEMP_3.*, TEMP_4.*, TEMP_5.*, TEMP_6.*
--, ROW_NUMBER() OVER(partition by TEMP_1.合管医嘱) as 序号
FROM TEMP_1 
JOIN TEMP_2 ON TEMP_1.合管医嘱 = TEMP_2.项目
JOIN TEMP_4 ON TEMP_4.指标名称 = TEMP_2.指标
JOIN TEMP_3 ON TEMP_4.标本ID = TEMP_3.标本ID
JOIN TEMP_5 ON TEMP_4.标本ID = TEMP_5.标本ID
JOIN TEMP_6 ON TEMP_4.指标ID = TEMP_6.do2指标ID
WHERE TEMP_4.设备ID = TEMP_6.do2仪器ID
ORDER BY TEMP_1.合管医嘱, TEMP_6.do2序号) Z;
