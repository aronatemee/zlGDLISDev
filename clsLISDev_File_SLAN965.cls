VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsLISDev_File_SLAN965"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
'����:SLANӫ�ⶨ��PCR���ϵͳ
'����:�Ϻ���ʯҽ�ƿƼ����޹�˾

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
    
    Dim aResults() As String, objFile As New Scripting.FileSystemObject

    Dim str�걾 As String, str����Ա As String, str���� As String, strDate As String

    Dim strFilePath As String, strNewFile As String, str�걾�� As String, str_No As String
    
    Dim xlApp As Object            'EXCEL�ļ�

    Dim xlBook As Object

    Dim xlSheet As Object
    
    Dim strLIne As String, varItem As Variant, varTmp As Variant

    Dim strSample As String, strResult As String, blnReturn As Boolean

    Dim lngRow As Long, varline As Variant

    Dim strFileImage As String, j As Long
    
    Dim intlastcolnum As Long
    
    Dim T As Integer
    
    Dim strPreSample As String
    
    
    '��������±����
    '����̬�������·������ݿռ�
    ReDim aResults(0)
    aResults(0) = ""
    ResultFromFile = aResults
    
    strFilePath = objFile.GetParentFolderName(strFile)

    If Len(strFilePath) = 0 Then strFilePath = App.Path
    
    Set xlApp = CreateObject("Excel.Application")

    '2012-03-11 ZHQ �豸�ṩ�ļ�ΪXLS�ļ���ʽ
    strNewFile = strFilePath & "*.xls"
    
    'Dir()���ط���Ҫ��ĵ�һ���ļ���
    If Dir(strNewFile) = "" Then
        Set xlBook = xlApp.Workbooks.Open(strFile)
    Else
        Set xlBook = xlApp.Workbooks.Open(strNewFile)
    End If

    Set xlSheet = xlBook.Worksheets(1)
    intlastcolnum = xlSheet.UsedRange.Columns.Count
    j = xlSheet.UsedRange.rows.Count '��ȡ������������
 
    strSample = ""
    strResult = ""
    lngRow = 15
    
    '�����걾��ʼ����ʱ�䡣
    strDate = xlSheet.cells(2, 2)
    
    '���ļ������ĸ���������
    strPreSample = Right(xlSheet.cells(j, 2), 2) & "-"
    
    For lngRow = 15 To j Step 3

        'UBound()���ص���ָ�������ָ��ά�ȵ��������±꣡
        '���������±�ָ���ĵ�����Ԫ�ز�Ϊ�գ���������н��ֵ����Ҫ��չ������顣
        If aResults(UBound(aResults)) <> "" Then
            'ʹ����Preserve �ؼ��֣�������������󣬲��ܼ�С��
            ReDim Preserve aResults(UBound(aResults) + 1)
        End If
        
        'ʹ�ñ����еġ�Ψһ��ʶ���ֶ���Ϊ�걾��
        strSample = UCase(xlSheet.cells(lngRow, 25))
        T = 2
        
        '��13����CTֵ����8���Ǽ��Ŀ�꣬Ҳ����N����O�����CY5
        Do While T >= 0
            
            If xlSheet.cells(lngRow + T, 13) <> "" Then
                strResult = strResult & "|" & UCase(xlSheet.cells(lngRow + T, 8)) & "|" & UCase(xlSheet.cells(lngRow + T, 13))
            Else
                strResult = strResult & "|" & UCase(xlSheet.cells(lngRow + T, 8)) & "|" & "0"
            End If
            
            T = T - 1
            
        Loop
            
        If strSample <> "" And strResult <> "" Then
            aResults(UBound(aResults)) = strDate & "|" & strPreSample & strSample & "| |������|0" & strResult
            strResult = ""
        End If

        'DoEvents
    Next

    xlBook.Close
    Set xlApp = Nothing
    Set xlBook = Nothing
    Set xlSheet = Nothing
    ResultFromFile = aResults
End Function


Public Function GetENum(ByVal nNumber As Long) As String
'���ܣ����ݴ���Ĵ����ַ��ش���ӦС����10��n����
'������nNumber���磺15120000,Ҫ�󷵻أ�1.512E+07
'���أ���ֵ������
    
    Dim dbl10 As Double
    Dim i As Integer, j As Integer
    
    If nNumber >= 1 Then
        i = Len(CStr(nNumber))
        
        If i > 1 Then
            dbl10 = Round(nNumber / (10 ^ (i - 1)), 3)
            
            GetENum = dbl10 & "E+" & Right("0" & CStr(i - 1), 3)
        Else
            GetENum = nNumber
        End If
    Else
        'С���������
        j = 1
        Do While True
            dbl10 = nNumber * 10 ^ j
            If dbl10 >= 1 Then
                dbl10 = Round(dbl10, 2)
                GetENum = dbl10 & "E-" & Right("00" & CStr(j), 2)
            End If
            j = j + 1
        Loop
    End If
End Function

