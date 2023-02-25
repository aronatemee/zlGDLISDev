VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsLISDev_AGS_v2"
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
    
    Dim strPreSample1, strPreSample2, strNewOpenFile, strPreNewOpenFile As String
    
    '��������±����
    '����̬�������·������ݿռ�
    ReDim aResults(0)
    aResults(0) = ""
    ResultFromFile = aResults
    
    'strFile���ʼָ�����ļ������ǲ�һ�����ڣ�����������Ҫ��ͬĿ¼�µı���ļ���������Ҫ��ø�Ŀ¼
    strFilePath = objFile.GetParentFolderName(strFile)

    If Len(strFilePath) = 0 Then strFilePath = App.Path
    
    Set xlApp = CreateObject("Excel.Application")

    '*��ͨ���������ģ��ƥ��
    strNewFile = strFilePath & "\*.xls"
    'Dir()��ȡ����Ҫ��ĵ�һ���ļ���
    
    strPreNewOpenFile = Dir(strNewFile)
    strNewOpenFile = strFilePath & "\" & strPreNewOpenFile
    
    Do While Right(strNewOpenFile, 1) <> "\"
        
        Set xlBook = xlApp.Workbooks.open(strNewOpenFile)
        Set xlSheet = xlBook.Worksheets("�������")
        intlastcolnum = xlSheet.UsedRange.Columns.Count
        j = xlSheet.UsedRange.rows.Count '��ȡ������������
 
        strSample = ""
        strResult = ""
        lngRow = 15
    
        '�����걾��ʼ����ʱ�䡣
        'ʱ���п��ܲ��ԣ���Ϊ����ԭ���Ǳ걾��ˮ��
        strDate = Mid$(xlSheet.cells(3, 2), 1, 4) & "-" & Mid$(xlSheet.cells(3, 2), 5, 2) & "-" & Mid$(xlSheet.cells(3, 2), 7, 2) & " " & Mid$(xlSheet.cells(3, 2), 9, 2) & ":" & Mid$(xlSheet.cells(3, 2), 11, 2) & ":" & Mid$(xlSheet.cells(3, 2), 13, 2)
    
        '���ļ������ĸ���������
        strPreSample2 = Right(xlSheet.cells(j, 2), 2) & "-"
    
        For lngRow = 15 To j Step 3

            'UBound()���ص���ָ�������ָ��ά�ȵ��������±꣡
            '���������±�ָ���ĵ�����Ԫ�ز�Ϊ�գ���������н��ֵ����Ҫ��չ������顣
            If aResults(UBound(aResults)) <> "" Then
                'ʹ����Preserve �ؼ��֣�������������󣬲��ܼ�С��
                ReDim Preserve aResults(UBound(aResults) + 1)
            End If
        
            'ʹ�ñ����еġ�Ψһ��ʶ���ֶ���Ϊ�걾��
            strSample = UCase(xlSheet.cells(lngRow, 4))
            '��9��14��19�зֱ���FAM��VIC��Cy5��CTֵ
        
            If Trim(UCase(xlSheet.cells(lngRow, 9))) = "" Then
                strResult = strResult & "|FAM|0"
            Else
                strResult = strResult & "|FAM|" & Trim(UCase(xlSheet.cells(lngRow, 9)))
            End If
        
            If Trim(UCase(xlSheet.cells(lngRow, 14))) = "" Then
                strResult = strResult & "|VIC|0"
            Else
                strResult = strResult & "|VIC|" & Trim(UCase(xlSheet.cells(lngRow, 14)))
            End If
        
            If Trim(UCase(xlSheet.cells(lngRow, 19))) = "" Then
                strResult = strResult & "|Cy5|0"
            Else
                strResult = strResult & "|Cy5|" & Trim(UCase(xlSheet.cells(lngRow, 19)))
            End If
            
            If strSample <> "" And strResult <> "" Then
                'Ϊ��ֹ��ʦ�ֶ��༭�ġ�Ψһ��ʶ�����ظ������ǽ����ļ�����ȥ����׺����Ҳƴ���ϣ��ټ���������ǰ׺
                aResults(UBound(aResults)) = strDate & "|" & Replace(strPreNewOpenFile, ".xls", "") & strPreSample2 & strSample & "| |������|0" & strResult
                strResult = ""
            End If

        Next
        
        'ͨ���ٴε����޲�����Dir������ȡ��һ������Ҫ����ļ���
        strPreNewOpenFile = Dir
        strNewOpenFile = strFilePath & "\" & strPreNewOpenFile
    Loop

    xlBook.Close
    Set xlApp = Nothing
    Set xlBook = Nothing
    Set xlSheet = Nothing
    ResultFromFile = aResults
End Function
