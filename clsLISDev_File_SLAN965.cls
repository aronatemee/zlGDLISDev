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
'仪器:SLAN荧光定量PCR检测系统
'厂商:上海宏石医疗科技有限公司

Public Function GetStartCmd() As String
    '设备标准接口
    '功能：获取设备开始发送命令
    GetStartCmd = ""
End Function

Public Function GetEndCmd() As String
    '设备标准接口
    '功能：获取设备停止发送命令
    GetEndCmd = ""
End Function

Public Function ResultFromFile(ByVal strFile As String, _
                               ByVal lngSampleNo As Long, _
                               ByVal dtStart As Date, _
                               Optional ByVal dtEnd As Date = CDate("3000-12-31")) As String()
    '标准函数：从文件获取检验结果
    '   strFile：包含路径的文件名
    '   lngSampleNO：标本号。为-1表示选取所有时间范围内的标本
    '   dtStart：开始时间。如果指定了标本号，则只提取该参数当天的这个标本（dtEnd无效）
    '   dtEnd：结束时间。只有当选取多个标本（lngSampleNO=-1）时，该参数有效。如果不指定该参数值，则时间范围为>=dtStart。
    '   返回的检验结果数组(各解析程序必须按以下标准组织结果)
    '   元素之间以|分隔
    '   第0个元素：检验时间
    '   第1个元素：样本序号
    '   第2个元素：检验人
    '   第3个元素：标本
    '   第4个元素：是否质控品
    '   从第5个元素开始为检验结果，每2个元素表示一个检验项目。
    '       如：第5i个元素为检验项目，第5i+1个元素为检验结果("^" & OD值 & "^" & CO值 & "^" & S/Co)
    
    Dim aResults() As String, objFile As New Scripting.FileSystemObject

    Dim str标本 As String, str操作员 As String, str日期 As String, strDate As String

    Dim strFilePath As String, strNewFile As String, str标本号 As String, str_No As String
    
    Dim xlApp As Object            'EXCEL文件

    Dim xlBook As Object

    Dim xlSheet As Object
    
    Dim strLIne As String, varItem As Variant, varTmp As Variant

    Dim strSample As String, strResult As String, blnReturn As Boolean

    Dim lngRow As Long, varline As Variant

    Dim strFileImage As String, j As Long
    
    Dim intlastcolnum As Long
    
    Dim T As Integer
    
    Dim strPreSample As String
    
    
    '避免出现下标错误
    '给动态数组重新分配数据空间
    ReDim aResults(0)
    aResults(0) = ""
    ResultFromFile = aResults
    
    strFilePath = objFile.GetParentFolderName(strFile)

    If Len(strFilePath) = 0 Then strFilePath = App.Path
    
    Set xlApp = CreateObject("Excel.Application")

    '2012-03-11 ZHQ 设备提供文件为XLS文件格式
    strNewFile = strFilePath & "*.xls"
    
    'Dir()返回符合要求的第一个文件名
    If Dir(strNewFile) = "" Then
        Set xlBook = xlApp.Workbooks.Open(strFile)
    Else
        Set xlBook = xlApp.Workbooks.Open(strNewFile)
    End If

    Set xlSheet = xlBook.Worksheets(1)
    intlastcolnum = xlSheet.UsedRange.Columns.Count
    j = xlSheet.UsedRange.rows.Count '获取该数据行总数
 
    strSample = ""
    strResult = ""
    lngRow = 15
    
    '本批标本开始检测的时间。
    strDate = xlSheet.cells(2, 2)
    
    '本文件属于哪个子仪器？
    strPreSample = Right(xlSheet.cells(j, 2), 2) & "-"
    
    For lngRow = 15 To j Step 3

        'UBound()返回的是指定数组的指定维度的最大可用下标！
        '当最大可用下标指定的的数组元素不为空，则代表已有结果值，需要扩展结果数组。
        If aResults(UBound(aResults)) <> "" Then
            '使用了Preserve 关键字，数组必须是增大，不能减小。
            ReDim Preserve aResults(UBound(aResults) + 1)
        End If
        
        '使用表格中的“唯一标识”字段作为标本号
        strSample = UCase(xlSheet.cells(lngRow, 25))
        T = 2
        
        '第13列是CT值，第8列是检测目标，也就是N基因、O基因和CY5
        Do While T >= 0
            
            If xlSheet.cells(lngRow + T, 13) <> "" Then
                strResult = strResult & "|" & UCase(xlSheet.cells(lngRow + T, 8)) & "|" & UCase(xlSheet.cells(lngRow + T, 13))
            Else
                strResult = strResult & "|" & UCase(xlSheet.cells(lngRow + T, 8)) & "|" & "0"
            End If
            
            T = T - 1
            
        Loop
            
        If strSample <> "" And strResult <> "" Then
            aResults(UBound(aResults)) = strDate & "|" & strPreSample & strSample & "| |咽拭子|0" & strResult
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
'功能：根据传入的纯数字返回带相应小数的10的n次幂
'参数：nNumber：如：15120000,要求返回：1.512E+07
'返回：数值型数据
    
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
        '小于零的数据
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


