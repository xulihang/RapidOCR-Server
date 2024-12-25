B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.9
@EndOfDesignText@
Sub Class_Globals
	Private engine As JavaObject
	Private modelsDir As String
	Private currentRecName As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	engine.InitializeNewInstance("com.benjaminwan.ocrlibrary.OcrEngine",Null)
	modelsDir = File.Combine(File.DirApp,"models")
End Sub

Public Sub InitModel(detName As String,clsName As String,keysName As String,recName As String) As Boolean
	If currentRecName <> recName Then
		currentRecName = recName
		Dim engineJO As JavaObject 
		engineJO.InitializeNewInstance("com.benjaminwan.ocrlibrary.OcrEngine",Null)
		Dim padding As Int = 50
		Dim boxScoreThresh As Float = 0.5
		Dim boxThresh As Float = 0.3
		Dim unClipRatio As Float = 1.6
		Dim doAngle As Boolean = True
		Dim mostAngle As Boolean = True
		Dim initModelsRet As Boolean = engineJO.RunMethod("initModels",Array(modelsDir, detName, clsName, recName, keysName))
		engineJO.RunMethod("setPadding",Array(padding)) '图像外接白框，用于提升识别率，文字框没有正确框住所有文字时，增加此值。
		engineJO.RunMethod("setBoxScoreThresh",Array(boxScoreThresh)) '文字框置信度门限，文字框没有正确框住所有文字时，减小此值
		engineJO.RunMethod("setBoxThresh",Array(boxThresh)) '请自行试验
		engineJO.RunMethod("setUnClipRatio",Array(unClipRatio)) '单个文字框大小倍率，越大时单个文字框越大
		engineJO.RunMethod("setDoAngle",Array(doAngle)) '启用(1)/禁用(0) 文字方向检测，只有图片倒置的情况下(旋转90~270度的图片)，才需要启用文字方向检测
		engineJO.RunMethod("setMostAngle",Array(mostAngle)) '启用(1)/禁用(0) 角度投票(整张图片以最大可能文字方向来识别)，当禁用文字方向检测时，此项也不起作用
		engine = engineJO
		Return initModelsRet
	End If
	Return True
End Sub

Public Sub Detect(imagePath As String) As List
	Dim maxSideLen As Int = 1024
	Dim ocrResult As JavaObject = engine.RunMethodJO("detect",Array(imagePath, maxSideLen))
	Dim regions As List
	regions.Initialize
	Dim blocks As List = ocrResult.RunMethod("getTextBlocks",Null)
	For Each block As JavaObject In blocks
		Dim region As Map
		region.Initialize
		region.Put("text",block.RunMethod("getText",Null))
		regions.Add(region)
		Dim points As List = block.RunMethod("getBoxPoint",Null)
		Dim convertedPoints As List
		convertedPoints.Initialize
		For Each point As JavaObject In points
			Dim p As Map
			p.Initialize
			p.Put("x",point.RunMethod("getX",Null))
			p.Put("y",point.RunMethod("getY",Null))
			convertedPoints.Add(p)
		Next
		region.Put("points",convertedPoints)
	Next
	Return regions
End Sub