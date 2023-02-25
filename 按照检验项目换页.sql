
--ĳ�걾������ҽ�������Ӧ��ָ��;
select *, ROW_NUMBER() OVER(partition by �Ϲ�ҽ��) as ���
from (WITH TEMP_1 AS (SELECT d.id AS ����id
					, d."json" #>> '{specimen, 0, reference1Specimen}' AS �걾ID
					, d."json" #>> '{specimen, 0, display}' AS �걾�ɼ�����
					, json_array_length(d."json" #> '{basedOn}') AS �Ϲ�ҽ����
					, json_array_elements(d."json" #> '{basedOn}') #>> '{display}' AS �Ϲ�ҽ��
					, d."json" #>> '{issued}' AS ����ʱ��
					, d."json" #>> '{ex_performer_Practitioner_display}' AS ������
					, d."json" #>> '{ex_resultsInterpreter_Practitioner_display}' AS ���������
					, d."json" #>> '{effectiveDateTime}' AS ���ʱ��
					, d."json" #>> '{subject_display}' AS ��������
					, d."json" #>> '{ex_gender_display}' AS �Ա�
					, d."json" #>> '{ex_resultsToHisPractitioner_display}' AS ���淢����
                                        , d."json" #>> '{specimen, 0, display}' AS �걾
				FROM diagnosticreport d 
				WHERE CAST(d.id AS TEXT) = (select ('' || {:CONDITION_IN} || '') :: json ->> 'id') ),--��ʽ����ʱ�滻Ϊ��Σ���������������id
TEMP_2 AS (SELECT li."name" AS ��Ŀ, o."name" AS ָ��
			FROM labitem_observationdefinition lo 
			JOIN lab_item li ON lo.lab_item_id = li.id 
			JOIN observationdefinition o ON lo.observationdefinition_id = o.id 
			ORDER BY li."name"), 
TEMP_3 AS (SELECT CAST(id AS TEXT) AS �걾ID
			, "json" #>> '{processing, 0, ex_performer_name}' AS �ɼ���
			, "json" #>> '{collection_collectedDateTime}' AS �ɼ�ʱ��
			, "json" #>> '{processing, 0, ex_exe_organizetion_name}' AS �ɼ�����
			, "json" ->> 'bodySite_coding_display' AS �걾����
			, "json" ->> 'method_coding_display' AS �ɼ���ʽ
			, "json" #>> '{container, 0, type_coding_display}' AS �걾����
			, "json" #>> '{container, 0, ex_cap_coding_display}' AS ������ɫ
			, "json" #>> '{request, 0, apply_dept}' AS ��������
			, "json" #>> '{request, 0, apply_staff}' AS ������
			, "json" #>> '{request, 0, apply_time}' AS ����ʱ��
			, "json" ->> 'condition_coding_display' AS ��ǰ�걾״̬
			, "json" ->> 'subject_display' AS ��������
			, "json" ->> 'ex_age' AS ��������
			, "json" ->> 'ex_gender_display' AS �����Ա�
			, "json" ->> 'ex_birthDate' AS ���߳�������
			, "json" ->> 'ex_encounter_display' AS ��������
			, CASE "json" ->> 'ex_priority'  WHEN 'routine' THEN '' ELSE '��' END AS ������ʶ
			, "json" ->> 'accessionIdentifier_value' AS �걾��
			, "json" ->> 'ex_encounter_reference1encounter' AS �����
			, "json" ->> 'ex_bed_no' AS ����
			, "json" #>> '{container, 0, identifier_value1bc}' AS �걾����
			, "json" ->> 'note_text' AS ��ע
		FROM specimen s 
		WHERE status = 'available'), 
--TEMP_4����Ҫɸѡ����֤û���ظ��ı걾���ƣ����ܺ�TEMP_2��������
TEMP_4 AS (SELECT  "json" ->> 'code_coding_code' AS ָ�����
			, "json" ->> 'code_coding_display' AS ָ������
			, "json" ->> 'valueQuantity_value' AS ָ����
			, "json" ->> 'valueQuantity_unit' AS ��λ
			, "json" ->> 'partOf_display' AS �걾״̬
			, "json" #>> '{performer, 0, display}' AS ���鼼ʦ
			, "json" ->> 'device_display' AS ����
			, "json" ->> 'specimen_reference1Specimen' AS �걾ID
			, "json" ->> 'subject_display' AS ��������
			, "json" #>> '{referenceRange, 0, reference_display}' AS �ο���Χ
			, "json" #>> '{ex_observationdefinition_id}' AS ָ��ID
			, "json" #>> '{device_reference1Device}' AS �豸ID
			, CAST("json" #>> '{ex_sno}' AS INTEGER) AS ָ�����--(?)
			, CAST("json" #>> '{referenceRange, 0, ex_sno}' as INTEGER) as ָ�����1
			, CASE "json" #>> '{interpretation, 0, coding_display}' WHEN 'N' THEN '' ELSE 
"json" #>> '{interpretation, 0, coding_display}'  END AS �������
			, "json" #>> '{preferredReportName}' AS Ӣ������
		FROM observation o 
		WHERE "json" ->> 'specimen_reference1Specimen' = (SELECT "json" #>> '{specimen, 0, reference1Specimen}' FROM diagnosticreport WHERE CAST(id AS TEXT) = (select ('' || {:CONDITION_IN} || '') :: json ->> 'id'))--ͨ������id���ұ걾id
		AND o.status <> 'cancelled'
		ORDER BY "json" ->> 'specimen_reference1Specimen'),
TEMP_5 AS (SELECT CAST("specimen_reference1Specimen" AS TEXT) AS �걾ID
			, issued_datetime AS ����ʱ�� FROM observation_rec or2 
		WHERE status <> 'cancelled'
		AND CAST("specimen_reference1Specimen" AS TEXT) = (SELECT "json" #>> '{specimen, 0, reference1Specimen}' FROM diagnosticreport WHERE CAST(id AS TEXT) = (select ('' || {:CONDITION_IN} || '') :: json ->> 'id'))--ͨ������id���ұ걾id
		LIMIT 1),
TEMP_6 AS (SELECT do2.sno AS do2���, do2.observationdefinition_id AS do2ָ��ID, do2.devicedefinition_id AS do2����ID FROM devicedefinition_observationdefinition do2)
SELECT DISTINCT TEMP_1.�Ϲ�ҽ��, TEMP_1.�걾, TEMP_2.ָ��, TEMP_3.*, TEMP_4.*, TEMP_5.*, TEMP_6.*
--, ROW_NUMBER() OVER(partition by TEMP_1.�Ϲ�ҽ��) as ���
FROM TEMP_1 
JOIN TEMP_2 ON TEMP_1.�Ϲ�ҽ�� = TEMP_2.��Ŀ
JOIN TEMP_4 ON TEMP_4.ָ������ = TEMP_2.ָ��
JOIN TEMP_3 ON TEMP_4.�걾ID = TEMP_3.�걾ID
JOIN TEMP_5 ON TEMP_4.�걾ID = TEMP_5.�걾ID
JOIN TEMP_6 ON TEMP_4.ָ��ID = TEMP_6.do2ָ��ID
WHERE TEMP_4.�豸ID = TEMP_6.do2����ID
ORDER BY TEMP_1.�Ϲ�ҽ��, TEMP_6.do2���) Z;
