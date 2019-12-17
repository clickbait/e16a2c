#NoEnv
SetBatchLines, -1

#Include Chrome.ahk

InputBox, StoreString, Store IDs, Please enter a comma seperated list of store IDs.,,,130
if ErrorLevel
	ExitApp

Stores := StrSplit(StoreString, ",", A_Space)

; Stores := [3440, 3441, 3439, 3438]

site := "http://examplewpsite.com.au"

FileCreateDir, ChromeProfile
ChromeInst := new Chrome("ChromeProfile", "http://google.com")

	if !(PageInst := ChromeInst.GetPage()) {
		ChromeInst.Kill()
	} else {

		For k, v in Stores {
			url := site "/wp-admin/post.php?post=" v "&action=edit"
			; --- Connect to the page ---
			PageInst.Call("Page.navigate", {"url": url})
			PageInst.WaitForLoad()

			try
				PageInst.Evaluate("jQuery('html, body').animate({scrollTop: (jQuery('#footer-thankyou').offset().top)},0);")
			catch e
			{
				MsgBox, % "Exception encountered in " e.What ":`n`n"
				. e.Message "`n`n"
				. "Specifically:`n`n"
				. Chrome.Jxon_Dump(Chrome.Jxon_Load(e.Extra), "`t")
			}

			Sleep, 3500
			PageInst.Evaluate("jQuery('#publish').click()")
			PageInst.WaitForLoad()
		}
	}

	try
		PageInst.Call("Browser.close") ; Fails when running headless
	catch
		ChromeInst.Kill()
	PageInst.Disconnect()

ExitApp
return