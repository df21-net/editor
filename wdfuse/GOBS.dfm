?
 TGOBWINDOW 0t:  TPF0
TGOBWindow	GOBWindowLeft[TopYCaptionWDFUSE GOB File ManagerClientHeight?ClientWidth?Color	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold 	Icon.Data
?             ?     (       @         ?                        ?  ?   ?? ?   ? ? ??  ??? ???   ?  ?   ?? ?   ? ? ??  ??? """"""""""""""""*???????????
???*???????????????*
??
?


?
? ???*
??







????*



?


?

????*



 ? ? ?? ?
?* ??
???????????* ??
???????????*???????????????*???????????????*????
???? ?????*????
??????????*????
??????????*???? 
???
?????*????
??????????*????  ?????????*???????????????*???????????????*???????????????*??  
?  
?  
??*? ? 
?
? ? ? ??*? ??
?
? ? ? ??*? ??
?
? ? ? ??*? ? 
?
? ?  
??*? ????
? ? ? ??*? ????
? ? ? ??*? ??
?
? ? ? ??*??  ??  
?  
??*???????????????*???????????????""""""""""""""""                                                                                                                                OldCreateOrder	Position	poDefault
OnActivateFormActivateOnClose	FormCloseOnCreate
FormCreatePixelsPerInch`
TextHeight TLabelDirLabelLeftTop(Width? HeightAutoSizeCaption"c:\...\embarcadero\studio\20.0\binColor	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold ParentColor
ParentFont  TLabelLabel1LeftXTop? WidthPHeightCaptionGOB EntriesColor	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold ParentColor
ParentFont  TPanelSpeedBarLeft Top Width?Height(AlignalTop
BevelInnerbvRaised
BevelOuter	bvLoweredCtl3D	ParentCtl3DTabOrder TSpeedButtonSpeedButtonHelpLefttTopWidthFHeight$Hint(Help|Open the GOB File Manager Help FileCaptionHelp	NumGlyphsParentShowHintShowHint	OnClickSpeedButtonHelpClick  TBitBtn	GOBCreateLeftTopWidthFHeight$HintNew GOB | Create a new GOB fileCaptionCreateLayout
blGlyphTop	NumGlyphsParentShowHintShowHint	TabOrder OnClickGOBCreateClick  TBitBtn	GOBDeleteLeft? TopWidthFHeight$HintDelete current GOBCaptionDeleteEnabledLayout
blGlyphTop	NumGlyphsParentShowHintShowHint	TabOrderOnClickGOBDeleteClick  TBitBtnGOBInfoLeft? TopWidthFHeight$Hint8Info on GOB | Give information on the GOB file directoryCaptionInfo  EnabledLayout
blGlyphTop	NumGlyphsParentShowHintShowHint	TabOrderOnClickGOBInfoClick  TBitBtn	GOBBrowseLeftTTopWidthFHeight$HintOpen  GOB | Open a GOB fileCaptionOpenLayout
blGlyphTop	NumGlyphsParentShowHintShowHint	TabOrderOnClickGOBBrowseClick   TPanelSP_MainLeft Top?Width?HeightAlignalBottomBorderStylebsSingleFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameTimes New Roman
Font.Style 
ParentFontTabOrder	 TPanelSP_ProgressLeftTopWidth? HeightAlignalLeft
BevelOuter	bvLoweredColorclBlackFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height?	Font.NameMS Sans Serif
Font.Style 
ParentFontTabOrder TGaugeProgressBarLeftTopWidth? HeightHint/Progress Bar | Show progress of long operations	BackColor	clBtnFaceBorderStylebsNoneColorclRed	ForeColorclBlueFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameMS Sans Serif
Font.Style ParentColor
ParentFontParentShowHintProgress ShowHint	   TPanelSP_TextLeftTop?Width?HeightHint&Shows status or context sensitive helpAlignalBottom	AlignmenttaLeftJustify
BevelInner	bvLowered
BevelOuterbvNoneFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameMS Sans Serif
Font.Style 
ParentFontParentShowHintShowHintTabOrder    TListBox
GOBDirListLeft?TopKWidth? Height4Hint6GOB contents|GOB Contents (Right click for selections)Color	clBtnFaceDragModedmAutomaticFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold IntegralHeight	MultiSelect	
ParentFontParentShowHint	PopupMenuGOBPopupMenuShowHint	Sorted	TabOrder
OnDragDropGOBDirListDragDrop
OnDragOverGOBDirListDragOver  TDirectoryListBoxDirectoryListBox1LeftTop{Width? Height? Color	clBtnFaceDirLabelDirLabelFileListFileListBox1Font.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold 
ParentFontTabOrder  TDriveComboBoxDriveComboBox1LeftTop?WidthrHeightColor	clBtnFaceDirListDirectoryListBox1Font.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold 
ParentFontTabOrder  TFilterComboBoxFilterComboBox1AlignWithMargins	Left? Top?WidthqHeightColorclCreamFilter?GOBs|*.GOB|GOB Assets|*.BM;*.FME;*.WAX;*.3DO;*.VOC;*.VUE;*.LEV;*.O;*.INF;*.GOL;*.PAL;*.CMP;*.LVL;*.LST;*.TXT;*.FNT;*.MSG|All Files   *.*|*.*TabOrderOnChangeFSTextChange  TEditFileNameEditLeftTop]Width? HeightFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold 
ParentFontTabOrderText*.GOB
OnKeyPressFileNameEditKeyPress  TBitBtnGOBAddLeft`TopQWidthFHeight$Hint1Add File(s) | Add the selected file(s) to the GOBCaptionAddEnabledLayout
blGlyphTop	NumGlyphsParentShowHintShowHint	TabOrder OnClickGOBAddClick  TBitBtn
GOBExtractLeft`TopuWidthFHeight$HintNExtract File(s)|Extract selected file(s) from the GOB to the current directoryCaption	Extract  EnabledLayout
blGlyphTop	NumGlyphsParentShowHintShowHint	TabOrderOnClickGOBExtractClick  TBitBtn	BNRefreshLeftOTopXWidthaHeight#HintGRefresh | Refresh the File System list in case of external modificationCaption    Refresh    File  List	NumGlyphsParentShowHintShowHint	TabOrder
WordWrap	OnClickBNRefreshClick  TBitBtn	GOBRemoveLeft`Top? WidthFHeight$Hint3Remove File(s)|Remove selected file(s) from the GOBCaptionRemove  EnabledLayout
blGlyphTop	NumGlyphsParentShowHintShowHint	TabOrderOnClickGOBRemoveClick  TFileListBoxFileListBox1Left? TopJWidth? Height4Hint4File System|File System (Right click for selections)Color	clBtnFaceDragModedmAutomaticFileEditFileNameEditFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold IntegralHeight	Mask*.GOBMultiSelect	
ParentFontParentShowHint	PopupMenuFSPopupMenuShowHint	TabOrderOnClickFileListBox1Change
OnDblClickFileListBox1Change
OnDragDropFileListBox1DragDrop
OnDragOverFileListBox1DragOver  TPanelPanelGOBNameLeft Top+Width?HeightHint2GOB Name | Name of the currently selected GOB file
BevelInner	bvLowered
BevelOuterbvNoneBorderStylebsSingleFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold 
ParentFontParentShowHintShowHint	TabOrder
OnDragDropPanelGOBNameDragDrop
OnDragOverPanelGOBNameDragOver  TListBoxGOBHintListBoxLeftTop?WidthAHeight6Color	clBtnFaceExtendedSelectFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold Items.StringsS************************    Hints for Gob Manager Use  ****************************    PThe Gob File  entries are in the large box on right side .The Working directory /files are displayed in the left hand large box.    #1 Create button  Creates a new GOB.(2 Delete button  Deletes an existing GOBB3 Info button  displays the information for the selected GOB file.24 Add button  adds the selected file(s) to the GOBI5.Extract button extracts the selected file(s) to the selected directory.:6.Remove button  removes the selected file(s) from the GOBN7.Mouse right button in either File listing box will bring up a selection menuT8. You can drag & drop files between File listing boxes with your mouse left button.U ************************   Opening  a GOB   *************************************** L1. Use the small file folder button on right to open a gob file to work withV*************************   Selecting a directory    **********************************1. Use drive selction  to selct disk drive)2. Select directory you want to work with13. Refresh button updates the file listing box .  
ParentFontTabOrder  TPanelPanelGOBEntriesLeftXTop? WidthQHeightHint?# Entries| Number of directory entries in the selected GOB file
BevelOuter	bvLoweredFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold 
ParentFontParentShowHintShowHint	TabOrder  TRadioGroupRadioGroup1LeftWTop? WidthQHeight9CaptionColorsItems.StringsNoneNormalDarker TabOrderOnClickRadioGroup1Click  	TCheckBoxGOBChkBxLeftXTopAWidthYHeightCaption	Hide TextTabOrderOnClickGOBChkBxClick  TBitBtnGOBOKBtnLeft[Top?WidthNHeightMargins.LeftMargins.TopMargins.RightMargins.BottomFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameMS Sans Serif
Font.StylefsBold KindbkOKMargin	NumGlyphs
ParentFontSpacing?TabOrderOnClickGOBOKBtnClick  TBitBtnGOBCancelBtnLeft\Top?WidthLHeightMargins.LeftMargins.TopMargins.RightMargins.BottomFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameMS Sans Serif
Font.StylefsBold KindbkCancelMargin	NumGlyphs
ParentFontSpacing?TabOrderOnClickGOBCancelBtnClick  TOpenDialogGOBBrowseGOB
DefaultExtgobFileName*.gobFilterGOB Files (*.GOB)|*.gobOptionsofHideReadOnlyofPathMustExistofFileMustExist TitleChoose GOB fileLeft   TSaveDialogGOBCreateSaveDialog
DefaultExtgobFileName*.gobFilterGOB Files (*.GOB)|*.GOBOptionsofOverwritePromptofHideReadOnlyofAllowMultiSelectofPathMustExistofNoReadOnlyReturn TitleCreate GOB fileLeftH  
TPopupMenuFSPopupMenuLeft  	TMenuItem
SelectAll1Caption
Select AllHintSelect All filesOnClickSelectAll1Click  	TMenuItemDeselectAll1CaptionDeSelect AllHintDeselect All filesOnClickDeselectAll1Click  	TMenuItemInvertSelection1CaptionInvert SelectionOnClickInvertSelection1Click  	TMenuItemN2Caption-  	TMenuItem
Select3DO1CaptionSelect *.3DOOnClickSelect3DO1Click  	TMenuItem	SelectBM1CaptionSelect *.BMOnClickSelect3DO1Click  	TMenuItem
SelectFME1CaptionSelect *.FMEOnClickSelect3DO1Click  	TMenuItem
SelectPAL1CaptionSelect *.PALOnClickSelect3DO1Click  	TMenuItem
SelectWAX1CaptionSelect *.WAXOnClickSelect3DO1Click  	TMenuItemN3Caption-  	TMenuItem
SelectGMD1CaptionSelect *.GMDOnClickSelect3DO1Click  	TMenuItem
SelectVOC1CaptionSelect *.VOCOnClickSelect3DO1Click  	TMenuItemN5Caption-  	TMenuItem
SelectLST1CaptionSelect *.LSTOnClickSelect3DO1Click  	TMenuItem
SelectLVL1CaptionSelect *.LVLOnClickSelect3DO1Click  	TMenuItem
SelectMSG1CaptionSelect *.MSGOnClickSelect3DO1Click  	TMenuItem
SelectTXT1CaptionSelect *.TXTOnClickSelect3DO1Click  	TMenuItem
SelectVUE1CaptionSelect *.VUEOnClickSelect3DO1Click  	TMenuItemN6Caption-  	TMenuItemLevels1CaptionSelect Level 	TMenuItemSelectSECBASE1CaptionSelect SECBASE.*OnClickSelectSECBASE1Click  	TMenuItemSelectTALAY1CaptionSelect TALAY.*OnClickSelectSECBASE1Click  	TMenuItemSelectSEWERS1CaptionSelect SEWERS.*OnClickSelectSECBASE1Click  	TMenuItemSelectTESTBASE1CaptionSelect TESTBASE.*OnClickSelectSECBASE1Click  	TMenuItemSelectGROMAS1CaptionSelect GROMAS.*OnClickSelectSECBASE1Click  	TMenuItemSelectDTENTION1CaptionSelect DTENTION.*OnClickSelectSECBASE1Click  	TMenuItemSelectRAMSHED1CaptionSelect RAMSHED.*OnClickSelectSECBASE1Click  	TMenuItemSelectROBOTICS1CaptionSelect ROBOTICS.*OnClickSelectSECBASE1Click  	TMenuItemSelectNARSHADA1CaptionSelect NARSHADA.*OnClickSelectSECBASE1Click  	TMenuItemSelectJABSHIP1CaptionSelect JABSHIP.*OnClickSelectSECBASE1Click  	TMenuItemSelectIMPCITY1CaptionSelect IMPCITY.*OnClickSelectSECBASE1Click  	TMenuItemSelectFUELSTAT1CaptionSelect FUELSTAT.*OnClickSelectSECBASE1Click  	TMenuItemSelectEXECUTOR1CaptionSelect EXECUTOR.*OnClickSelectSECBASE1Click  	TMenuItem
SelectARC1CaptionSelect ARC.*OnClickSelectSECBASE1Click    
TPopupMenuGOBPopupMenuLeft? 	TMenuItem
SelectAll2Caption
Select AllHintSelect All filesOnClickSelectAll2Click  	TMenuItemDeSelectAll2CaptionDeSelect AllHintDeselect All filesOnClickDeSelectAll2Click  	TMenuItemInvertSelection2CaptionInvert SelectionOnClickInvertSelection2Click  	TMenuItem	MenuItem3Caption-  	TMenuItem
Select3DO2CaptionSelect *.3DOOnClickSelect3DO2Click  	TMenuItem	SelectBM2CaptionSelect *.BMOnClickSelect3DO2Click  	TMenuItem
SelectFME2CaptionSelect *.FMEOnClickSelect3DO2Click  	TMenuItem
SelectPAL2CaptionSelect *.PALOnClickSelect3DO2Click  	TMenuItem
SelectWAX2CaptionSelect *.WAXOnClickSelect3DO2Click  	TMenuItem	MenuItem9Caption-  	TMenuItem
SelectGMD2CaptionSelect *.GMDOnClickSelect3DO2Click  	TMenuItem
SelectVOC2CaptionSelect *.VOCOnClickSelect3DO2Click  	TMenuItem
MenuItem12Caption-  	TMenuItem
SelectLST2CaptionSelect *.LSTOnClickSelect3DO2Click  	TMenuItem
SelectLVL2CaptionSelect *.LVLOnClickSelect3DO2Click  	TMenuItem
SelectMSG2CaptionSelect *.MSGOnClickSelect3DO2Click  	TMenuItem
SelectTXT2CaptionSelect *.TXTOnClickSelect3DO2Click  	TMenuItem
SelectVUE2CaptionSelect *.VUEOnClickSelect3DO2Click  	TMenuItem
MenuItem18Caption-  	TMenuItemLevels2CaptionSelect Level 	TMenuItemSelectSECBASE2CaptionSelect SECBASE.*OnClickSelectSECBASE2Click  	TMenuItemSelectTALAY2CaptionSelect TALAY.*OnClickSelectSECBASE2Click  	TMenuItemSelectSEWERS2CaptionSelect SEWERS.*OnClickSelectSECBASE2Click  	TMenuItemSelectTESTBASE2CaptionSelect TESTBASE.*OnClickSelectSECBASE2Click  	TMenuItemSelectGROMAS2CaptionSelect GROMAS.*OnClickSelectSECBASE2Click  	TMenuItemSelectDTENTION2CaptionSelect DTENTION.*OnClickSelectSECBASE2Click  	TMenuItemSelectRAMSHED2CaptionSelect RAMSHED.*OnClickSelectSECBASE2Click  	TMenuItemSelectROBOTICS2CaptionSelect ROBOTICS.*OnClickSelectSECBASE2Click  	TMenuItemSelectNARSHADA2CaptionSelect NARSHADA.*OnClickSelectSECBASE2Click  	TMenuItemSelectJABSHIP2CaptionSelect JABSHIP.*OnClickSelectSECBASE2Click  	TMenuItemSelectIMPCITY2CaptionSelect IMPCITY.*OnClickSelectSECBASE2Click  	TMenuItemSelectFUELSTAT2CaptionSelect FUELSTAT.*OnClickSelectSECBASE2Click  	TMenuItemSelectEXECUTOR2CaptionSelect EXECUTOR.*OnClickSelectSECBASE2Click  	TMenuItem
SelectARC2CaptionSelect ARC.*OnClickSelectSECBASE2Click     