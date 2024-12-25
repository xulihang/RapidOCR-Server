B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.8
@EndOfDesignText@
'Handler class
Sub Class_Globals
	
End Sub

Public Sub Initialize
	
End Sub

Sub Handle(req As ServletRequest, resp As ServletResponse)
	Try
		If req.Method == "POST" Then
			Dim filename As String = Rnd(0,100)&"-"&DateTime.Now
			Dim imgPath As String = File.Combine(File.Combine(File.DirApp,"tmp"),filename)
			Dim base64 As String = req.GetParameter("base64")
			Dim su As StringUtils
			File.WriteBytes(imgPath,"",su.DecodeBase64(base64))
			Dim result As Map
			result.Initialize
			Dim results As List = Main.engine.Detect(imgPath)
			result.Put("results",results)
			Log(results)
			'File.Delete(imgPath,"")
			Dim json As JSONGenerator
			json.Initialize(result)
			resp.ContentType="application/json"
			resp.Write(json.ToString)
		End If
	Catch
		resp.SendError(500, LastException)
	End Try
End Sub