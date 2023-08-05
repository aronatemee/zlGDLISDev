VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsLISDev_Gentier96R"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
'仪器:天隆 Gentier 96R
'作者:吴品江
'文件名格式要求:SMA-日期-...（目前叶酸默认导出文件只有年月日，没有时分秒）

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
    
    Dim result() As String
    Dim objFileSystem As New Scripting.FileSystemObject
    Dim excelApp As Object, excelBook As Object, excelSheet As Object
    Dim strDate As String, strSampleNo, strResult As String
    Dim iLastColNum As Integer, iLastRowNum, iRow As Integer
    Dim strParentPath As String, strOpenFile As String, strDateTemp As String
    
    Dim strOpenFileActually As String
    
    Dim strAssayType, strAssayYear, strAssayMonthDay As String
    
    Dim m As Integer
    
    On Error GoTo ErrorHandle
    
    ReDim result(0)
    result(0) = ""
    
    strParentPath = objFileSystem.GetParentFolderName(strFile)
    
    If Len(strParentPath) = 0 Then
        strParentPath = App.Path
    End If
    
    strOpenFileActually = Dir(strParentPath & "\*.xlsx")
    
    strOpenFile = strParentPath & "\" & strOpenFileActually
    
    Do While Right(strOpenFile, 1) <> "\"
        
        strDateTemp = Mid(Split(strOpenFileActually, "-")(1), 1, 8)
        
        Set excelApp = CreateObject("Excel.Application")
        Set excelBook = excelApp.Workbooks.open(strOpenFile)
        Set excelSheet = excelBook.Worksheets(1)
        iLastColNum = excelSheet.UsedRange.Columns.Count
        iLastRowNum = excelSheet.UsedRange.rows.Count
        
        strSampleNo = "": strResult = ""
        
        ' 坐标（1，8）是“孔号”，就是SMA检验。
        ' excelSheet.cells(第几行, 第几列), 注意，实际上是（纵坐标，横坐标）
        If excelSheet.cells(8, 1) = "孔号" Then

            'SMA assay
            
            For iRow = 9 To iLastRowNum

                If IsNumeric(excelSheet.cells(iRow, 4)) Then
                    If result(UBound(result)) <> "" Then
                        ReDim Preserve result(UBound(result) + 1)
                        result(UBound(result)) = ""
                    End If
                
                    strDate = Format(Replace(excelSheet.cells(2, 3), "/", "-"), "yyyy-mm-dd hh:mm:ss")
                
                    strSampleNo = excelSheet.cells(iRow, 4)
                
                    strResult = strResult & "|" & "SMN1-7" & "|" & excelSheet.cells(iRow, 8) & "|" & "SMN1-8" & "|" & excelSheet.cells(iRow, 12)
                
                    If IsNumeric(strSampleNo) Then
                        result(UBound(result)) = strDate & "|" & strSampleNo & "| |标本|0" & strResult
                    End If
                
                    strDate = "": strSampleNo = "": strResult = ""
                End If
                
            Next

        ElseIf excelSheet.cells(1, 1) = "孔位" Then

            '叶酸 assay
                
            For iRow = 2 To iLastRowNum Step 3
            
                If IsNumeric(excelSheet.cells(iRow, 2)) Then
                    If result(UBound(result)) <> "" Then
                        ReDim Preserve result(UBound(result) + 1)
                        result(UBound(result)) = ""
                    End If
                
                    strDate = Mid(strDateTemp, 1, 4) & "-" & Mid(strDateTemp, 5, 2) & "-" & Mid(strDateTemp, 7, 2) & " 00:00:00"
                
                    strSampleNo = excelSheet.cells(iRow, 2)
                
                    If excelSheet.cells(iRow + 2, 5) = "Cy5" And excelSheet.cells(iRow + 2, 10) = "通过" Then
                        If excelSheet.cells(iRow, 5) = "FAM" And excelSheet.cells(iRow, 10) = "C" And excelSheet.cells(iRow + 1, 5) = "VIC" And excelSheet.cells(iRow + 1, 10) = "T" Then
                            strResult = "|C677T|CT"
                        ElseIf excelSheet.cells(iRow, 5) = "FAM" And excelSheet.cells(iRow, 10) = "" And excelSheet.cells(iRow + 1, 5) = "VIC" And excelSheet.cells(iRow + 1, 10) = "T" Then
                            strResult = "|C677T|TT"
                        ElseIf excelSheet.cells(iRow, 5) = "FAM" And excelSheet.cells(iRow, 10) = "C" And excelSheet.cells(iRow + 1, 5) = "VIC" And excelSheet.cells(iRow + 1, 10) = "" Then
                            strResult = "|C677T|CC"
                        Else
                            strResult = strResult & "ERROR|error"
                        End If
                    End If
                
                    result(UBound(result)) = strDate & "|" & strSampleNo & "| |标本|0" & strResult
                
                    strDate = "": strSampleNo = "": strResult = ""
                
                End If

            Next

        End If
        
        '将读取过的文件转移到备份文件夹
        If Not objFileSystem.FolderExists("D:\Gen96R PCR仪-精准-备份") Then
        
            Call objFileSystem.CreateFolder("D:\Gen96R PCR仪-精准-备份")
        
        End If
        
        strAssayType = Split(strOpenFileActually, "-")(0)
        
        strAssayYear = Mid(Split(strOpenFileActually, "-")(1), 1, 4) & "年"
        
        strAssayMonthDay = Mid(Split(strOpenFileActually, "-")(1), 5, 2) & "." & Mid(Split(strOpenFileActually, "-")(1), 7, 2)
        
        '是否存在该检验的备份文件夹
        If Not objFileSystem.FolderExists("D:\Gen96R PCR仪-精准-备份" & "\" & strAssayType) Then
        
            Call objFileSystem.CreateFolder("D:\Gen96R PCR仪-精准-备份" & "\" & strAssayType)
            
        End If
        
        If Not objFileSystem.FolderExists("D:\Gen96R PCR仪-精准-备份" & "\" & strAssayType & "\" & strAssayYear) Then
        
            Call objFileSystem.CreateFolder("D:\Gen96R PCR仪-精准-备份" & "\" & strAssayType & "\" & strAssayYear)
            
        End If
        
        '是否存在该月日的备份文件夹
        If Not objFileSystem.FolderExists("D:\Gen96R PCR仪-精准-备份" & "\" & strAssayType & "\" & strAssayYear & "\" & strAssayMonthDay) Then
            
            Call objFileSystem.CreateFolder("D:\Gen96R PCR仪-精准-备份" & "\" & strAssayType & "\" & strAssayYear & "\" & strAssayMonthDay)
            
        End If
        
        excelBook.Close
        Set excelApp = Nothing
        Set excelBook = Nothing
        Set excelSheet = Nothing
        
        If strOpenFile <> "" And objFileSystem.FolderExists("D:\Gen96R PCR仪-精准-备份" & "\" & strAssayType & "\" & strAssayYear & "\" & strAssayMonthDay) Then
        
            '将SMA、叶酸移动到各自的文件夹内
            objFileSystem.CopyFile "D:\Gen96R PCR仪-精准" & "\" & strOpenFileActually, "D:\Gen96R PCR仪-精准-备份" & "\" & strAssayType & "\" & strAssayYear & "\" & strAssayMonthDay & "\" & strOpenFileActually, True
            
            objFileSystem.DeleteFile "D:\Gen96R PCR仪-精准" & "\" & strOpenFileActually, True
            
        End If
        
        strOpenFileActually = Dir
        strOpenFile = strParentPath & "\" & strOpenFileActually
    Loop
    
    
    ResultFromFile = result
    
    Exit Function
    
ErrorHandle:

    Debug.Print ("Error!")
    
    Exit Function

End Function

