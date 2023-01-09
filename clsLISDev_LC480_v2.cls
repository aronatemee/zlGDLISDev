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
'仪器:
'厂商:

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
    
    Dim aResults() As String

    Dim str标本 As String, str操作员 As String, str日期 As String, strDate As String

    Dim strFilePath As String, strNewFile As String, str标本号 As String, str_No As String
    
    '文件对象
    Dim objFile    As New Scripting.FileSystemObject

    '文件流对象
    Dim objStream  As TextStream
    
    Dim strLine As String, varItem As Variant, varTmp As Variant

    Dim strSample As String, strResult As String, blnReturn As Boolean

    Dim lngRow As Long, varline As Variant

    Dim strFileImage As String, j As Long
    
    Dim intlastcolnum As Long
    
    Dim T As Integer
    
    Dim strPreSample1, strPreSample2, strNewOpenFile, strPreNewOpenFile, strObservation, strItem As String
    
    '避免出现下标错误
    '给动态数组重新分配数据空间
    ReDim aResults(0)
    aResults(0) = ""
    ResultFromFile = aResults
    
    'strFile是最开始指定的文件，但是不一定存在，所以我们需要打开同目录下的别的文件，所以需要获得父目录
    strFilePath = objFile.GetParentFolderName(strFile)

    If Len(strFilePath) = 0 Then strFilePath = App.Path

    '*是通配符，可以模糊匹配
    strNewFile = strFilePath & "\*.txt"
    'Dir()获取符合要求的第一个文件名
    
    strPreNewOpenFile = Dir(strNewFile)
    strNewOpenFile = strFilePath & "\" & strPreNewOpenFile
    
    Do While Right(strNewOpenFile, 1) <> "\"
        
        Set objStream = objFile.OpenTextFile(strNewOpenFile)

        '循环读取文件流，直到末尾
        Do Until objStream.AtEndOfStream
            '按照行来分段读取
            strLine = objStream.ReadLine
                
            '第一行获取本文件的指标通道码和标本号前缀（用以确定是哪个文件的数据）
            If InStr(strLine, "Selected Filter") Then

                Do While InStr(strLine, "  ")
                    
                    strLine = Replace$(strLine, "  ", " ")
                    
                Loop
                strDate = Mid$(Split(strLine, " ")(1), 1, 4) & "-" & Mid$(Split(strLine, " ")(1), 5, 2) & "-" & Mid$(Split(strLine, " ")(1), 7, 2) & " " & Mid$(Split(strLine, " ")(1), 9, 2) & ":00:00"
                strObservation = Split(strLine, " ")(4)
                '如果是Sample行，就取cp字段值。
            ElseIf InStr(Split(strLine, Chr(&H9))(3), "Sample") <> 0 Then
                strSample = Split(strLine, Chr(&H9))(3)
                strItem = strObservation & "|" & IIf(Split(strLine, Chr(&H9))(4) = "", "0", Split(strLine, Chr(&H9))(4))
            End If
                
            If strSample <> "" And strItem <> "" Then
                If aResults(UBound(aResults)) <> "" Then
                    ReDim Preserve aResults(UBound(aResults) + 1)
                End If

                aResults(UBound(aResults)) = strDate & "|" & Replace$(strPreNewOpenFile, ".txt", "-") & strSample & "| |咽拭子|0|" & strItem
            End If
                
            strSample = "": strItem = ""
        Loop
            
        'Dir如果没有找到下一个符合要求的文件，就返回空字符串。
        strPreNewOpenFile = Dir
        strNewOpenFile = strFilePath & "\" & strPreNewOpenFile
    Loop
    
    objStream.Close
    ResultFromFile = aResults
End Function



