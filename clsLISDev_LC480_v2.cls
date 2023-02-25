VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsLISDev_LC480_v2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
'����:
'����:

Public Function GetStartCmd() As String
    '�豸��׼�ӿ�
    '���ܣ���ȡ�豸��ʼ��������
    GetStartCmd = ""
End Function

Public Function GetEndCmd() As String
    '�豸��׼�ӿ�
    '���ܣ���ȡ�豸ֹͣ��������
    GetEndCmd = ""
End Function

Public Function ResultFromFile(ByVal strFile As String, _
                               ByVal lngSampleNo As Long, _
                               ByVal dtStart As Date, _
                               Optional ByVal dtEnd As Date = CDate("3000-12-31")) As String()
    '��׼���������ļ���ȡ������
    '   strFile������·�����ļ���
    '   lngSampleNO���걾�š�Ϊ-1��ʾѡȡ����ʱ�䷶Χ�ڵı걾
    '   dtStart����ʼʱ�䡣���ָ���˱걾�ţ���ֻ��ȡ�ò������������걾��dtEnd��Ч��
    '   dtEnd������ʱ�䡣ֻ�е�ѡȡ����걾��lngSampleNO=-1��ʱ���ò�����Ч�������ָ���ò���ֵ����ʱ�䷶ΧΪ>=dtStart��
    '   ���صļ���������(������������밴���±�׼��֯���)
    '   Ԫ��֮����|�ָ�
    '   ��0��Ԫ�أ�����ʱ��
    '   ��1��Ԫ�أ��������
    '   ��2��Ԫ�أ�������
    '   ��3��Ԫ�أ��걾
    '   ��4��Ԫ�أ��Ƿ��ʿ�Ʒ
    '   �ӵ�5��Ԫ�ؿ�ʼΪ��������ÿ2��Ԫ�ر�ʾһ��������Ŀ��
    '       �磺��5i��Ԫ��Ϊ������Ŀ����5i+1��Ԫ��Ϊ������("^" & ODֵ & "^" & COֵ & "^" & S/Co)
    
    Dim aResults() As String

    Dim str�걾 As String, str����Ա As String, str���� As String, strDate As String

    Dim strFilePath As String, strNewFile As String, str�걾�� As String, str_No As String
    
    '�ļ�����
    Dim objFile    As New Scripting.FileSystemObject

    '�ļ�������
    Dim objStream  As TextStream
    
    Dim strLine As String, varItem As Variant, varTmp As Variant

    Dim strSample As String, strResult As String, blnReturn As Boolean

    Dim lngRow As Long, varline As Variant

    Dim strFileImage As String, j As Long
    
    Dim intlastcolnum As Long
    
    Dim T As Integer
    
    Dim strPreSample1, strPreSample2, strNewOpenFile, strPreNewOpenFile, strObservation, strItem As String
    
    '��������±����
    '����̬�������·������ݿռ�
    ReDim aResults(0)
    aResults(0) = ""
    ResultFromFile = aResults
    
    'strFile���ʼָ�����ļ������ǲ�һ�����ڣ�����������Ҫ��ͬĿ¼�µı���ļ���������Ҫ��ø�Ŀ¼
    strFilePath = objFile.GetParentFolderName(strFile)

    If Len(strFilePath) = 0 Then strFilePath = App.Path

    '*��ͨ���������ģ��ƥ��
    strNewFile = strFilePath & "\*.txt"
    'Dir()��ȡ����Ҫ��ĵ�һ���ļ���
    
    strPreNewOpenFile = Dir(strNewFile)
    strNewOpenFile = strFilePath & "\" & strPreNewOpenFile
    
    Do While Right(strNewOpenFile, 1) <> "\"
        
        Set objStream = objFile.OpenTextFile(strNewOpenFile)

        'ѭ����ȡ�ļ�����ֱ��ĩβ
        Do Until objStream.AtEndOfStream
            '���������ֶζ�ȡ
            strLine = objStream.ReadLine
                
            '��һ�л�ȡ���ļ���ָ��ͨ����ͱ걾��ǰ׺������ȷ�����ĸ��ļ������ݣ�
            If InStr(strLine, "Selected Filter") Then

                Do While InStr(strLine, "  ")
                    
                    strLine = Replace$(strLine, "  ", " ")
                    
                Loop
                strDate = Mid$(Split(strLine, " ")(1), 1, 4) & "-" & Mid$(Split(strLine, " ")(1), 5, 2) & "-" & Mid$(Split(strLine, " ")(1), 7, 2) & " " & Mid$(Split(strLine, " ")(1), 9, 2) & ":00:00"
                strObservation = Split(strLine, " ")(4)
                '�����Sample�У���ȡcp�ֶ�ֵ��
            ElseIf InStr(Split(strLine, Chr(&H9))(3), "Sample") <> 0 Then
                strSample = Split(strLine, Chr(&H9))(3)
                strItem = strObservation & "|" & IIf(Split(strLine, Chr(&H9))(4) = "", "0", Split(strLine, Chr(&H9))(4))
            End If
                
            If strSample <> "" And strItem <> "" Then
                If aResults(UBound(aResults)) <> "" Then
                    ReDim Preserve aResults(UBound(aResults) + 1)
                End If

                aResults(UBound(aResults)) = strDate & "|" & Replace$(strPreNewOpenFile, ".txt", "-") & strSample & "| |������|0|" & strItem
            End If
                
            strSample = "": strItem = ""
        Loop
            
        'Dir���û���ҵ���һ������Ҫ����ļ����ͷ��ؿ��ַ�����
        strPreNewOpenFile = Dir
        strNewOpenFile = strFilePath & "\" & strPreNewOpenFile
    Loop
    
    objStream.Close
    ResultFromFile = aResults
End Function


