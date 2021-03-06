
on run
	set theDefLoc to (path to desktop from user domain) as alias
	set theFileType to "com.adobe.illustrator.ai-image" as text
	set AppleScript's text item delimiters to {","}
	set theFileTypeList to every text item of theFileType
	set theWithPrompt to theFileType & "\nファイルをえらんでください\n"
	set theWithPromptMes to "ドロップレットにしても\n動作します"
	open (choose file default location theDefLoc ¬
		with prompt theWithPrompt & theWithPromptMes ¬
		of type theFileTypeList ¬
		invisibles true ¬
		with multiple selections allowed without showing package contents)
end run


on open DropObj
	
	set theFineNum to count of DropObj
	
	set progress completed steps to 1
	set progress description to "PDF変換ちゅう..."
	set progress additional description to "変換中！"
	
	set theComandText to ("date '+%Y%m%d'") as text
	set theDATE to (do shell script theComandText) as text
	set numCnt to 1 as number
	tell application "Adobe Illustrator"
		--------PDFのプリセット名をリスト形式で格納
		set PdfPreSetLabels to PDF presets as list
	end tell
	tell application "Finder"
		activate
		set chooseResult to choose from list PdfPreSetLabels with prompt "PDFプリセットを選んでください" OK button name "実行する" with title "プリセット選択"
	end tell
	set thePDFpre to (chooseResult) as text
	
	----------PDFプリセットの内容をここで定義します。（このやり方は好みの問題）
	if chooseResult is false then
		set thePDFpre to "[プレス品質]" as text
	else
		set thePDFpre to thePDFpre as text
	end if
	set numCntFiles to count of DropObj
	--------------------------------------------------繰り返しの始まり
	repeat with ObjFiles in DropObj
		set progress completed steps to numCnt
		set progress description to "PDF変換ちゅう...(" & numCnt & "/" & theFineNum & ")"
		set progress additional description to "変換中(" & numCnt & "/" & theFineNum & ")"
		--------------------------------------------------ファイルのinfoを取得
		set ObjRepFile to info for ObjFiles
		--------------------------------------------------ファイル名を取得
		set theFileName to name of ObjRepFile as text
		------------------------------------------------拡張子を取得
		set theExeName to name extension of ObjRepFile
		--------------------------------------------------保存するファイル名はここで定義
		---set thePdfPref to replace(thePDFpre, "[", "")
		---set thePdfPref to replace(thePdfPref, "]", "")
		---set thePdfPref to replace(thePdfPref, ":", "")
		---set theSaveFileName to (theFileName & "_" & thePdfPref & ".pdf")
		
		---set theSaveFileName to (theFileName & "_" & theDATE & ".pdf")
		set theSaveFileName to ((replace(theFileName, ".ai", "")) & "." & theDATE & ".pdf")
		---set theSaveFileName to ((replace((replace(theFileName, " ", "_")), ".ai", "")) & "." & theDATE & ".pdf")
		---set theSaveFileName to replace((replace(theFileName, " ", "_")), ".ai", ".pdf")
		------------------------------------------------
		set aliasOpenFile to ObjFiles as alias
		set theAliasOpenFile to aliasOpenFile as text
		------------------------------------------------使わないけど
		set theUnixPass to quoted form of (POSIX path of aliasOpenFile) as text
		
		tell application "Finder"
			------------------------------------------------ディレクトリーを取得
			set theParentPathToFile to (parent of aliasOpenFile) as text
			------------------------------------------------保存するファイル名を定義
			set theSaveFilePath to (theParentPathToFile & theSaveFileName) as text
		end tell
		------------------------------------------------使わないけど
		set theSaveUnixPass to quoted form of (POSIX path of theSaveFilePath) as text
		--------------------------------------------------Illustrator呼び出し
		tell application "Adobe Illustrator"
			--------------------------------------------------Illustrator　アクティブ
			activate
			--------------------------------------------------ファイルを開く
			open aliasOpenFile without dialogs
			------------------開いたファイルをactivDocとして定義
			set activDoc to document 1
			---------------------PDFで別名で保存		
			save activDoc in file theSaveFilePath as pdf with options ¬
				{class:PDF save options ¬
					, PDF preset:thePDFpre ¬
					}
			----------------------アクティブドキュメントを保存しないで閉じる
			close activDoc saving no
			----------------------イラストレーターを解放
		end tell
		----カウントアップ
		set numCnt to numCnt + 1 as number
	end repeat
	
end open

-----------------------------文字の置き換えのサブルーチン　使わないけど
to replace(theText, orgStr, newStr)
	set oldDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to orgStr
	set tmpList to every text item of theText
	set AppleScript's text item delimiters to newStr
	set tmpStr to tmpList as text
	set AppleScript's text item delimiters to oldDelim
	return tmpStr
end replace
