?
 TLFDWINDOW 0?,  TPF0
TLFDWindow	LFDWindowLeft? Top}BorderIconsbiSystemMenu
biMaximize CaptionWDFUSE LFD File ManagerClientHeight?ClientWidth	Color	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height?	Font.NameSystem
Font.Style 	Icon.Data
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
??????????*????  ?????????*???????????????*???????????????*?   ? ???  "???*? ??? ??? ? *??*? ??? ??? ? *??*? ??? ??? ??
??*? ???   ? ??
??*? ??? ??? ??
??*? ??? ??? ??
??*? ??? ??? ? *??*? ??? ??? ? *??*? ???   ?  ???*???????????????*???????????????""""""""""""""""                                                                                                                                
KeyPreview	OldCreateOrder	Position	poDefault
OnActivateFormActivateOnClose	FormCloseOnCreate
FormCreateOnKeyUp	FormKeyUpPixelsPerInch`
TextHeight TLabelDirLabelLeftTop0Width? HeightAutoSizeCaption"c:\...\embarcadero\studio\20.0\binFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold 
ParentFont  TLabelLabel1Left?Top? WidthLHeightCaptionLFD Entries  TBevelBevel1Left TopNWidth?Height ShapebsRightLine  TLabel
LabelTitleLeft?TopWidthAHeightCaptionLFD PATH  TPanelSpeedBarLeft Top Width	Height*AlignalTop
BevelInnerbvRaised
BevelOuter	bvLoweredCtl3D	ParentCtl3DTabOrder TSpeedButtonSpeedButtonHelpLeft?TopWidthFHeight$Hint(Help|Open the LFD File Manager Help FileCaptionHelp	NumGlyphsParentShowHintShowHint	OnClickSpeedButtonHelpClick  TBitBtn	LFDCreateLeftTopWidthFHeight$HintNew LFD | Create a new LFD fileCaptionCreate  	NumGlyphsParentShowHintShowHint	TabOrder OnClickLFDCreateClick  TBitBtn	LFDDeleteLeft? TopWidthFHeight$HintDelete current LFDCaptionDeleteEnabled	NumGlyphsParentShowHintShowHint	TabOrderOnClickLFDDeleteClick  TBitBtnLFDInfoLeft? TopWidthFHeight$Hint8Info on LFD | Give information on the LFD file directoryCaption   Info    Enabled	NumGlyphsParentShowHintShowHint	TabOrderOnClickLFDInfoClick  TBitBtnOpenLeftTTopWidthFHeight$HintNew LFD | Create a new LFD fileCaptionOpen	NumGlyphsParentShowHintShowHint	TabOrderOnClickLFDBrowseClick   TPanelSP_MainLeft Top?Width	HeightAlignalBottomBorderStylebsSingleFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameTimes New Roman
Font.Style 
ParentFontTabOrder	 TPanelSP_ProgressLeftTopWidth? HeightAlignalLeft
BevelOuter	bvLoweredFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameMS Sans Serif
Font.Style 
ParentFontTabOrder TGaugeProgressBarLeftTopWidth? HeightHint/Progress Bar | Show progress of long operationsAlignalClient	BackColor	clBtnFaceBorderStylebsNone	ForeColorclBlueParentShowHintProgress ShowHint	ExplicitHeight   TPanelSP_TextLeft? TopWidth9HeightHint&Shows status or context sensitive helpAlignalClient	AlignmenttaLeftJustify
BevelInner	bvLowered
BevelOuterbvNoneFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameMS Sans Serif
Font.Style 
ParentFontParentShowHintShowHintTabOrder    TListBox
LFDDirListLeft?TopNWidth? Height$Hint6LFD contents|LFD Contents (Right click for selections)DragModedmAutomaticIntegralHeight	MultiSelect	ParentShowHint	PopupMenuLFDPopupMenuShowHint	Sorted	TabOrder
OnDragDropLFDDirListDragDrop
OnDragOverLFDDirListDragOver  TDirectoryListBoxDirectoryListBox1LeftTop{Width? Height? DirLabelDirLabelFileListFileListBox1Font.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold 
ParentFontTabOrder  TDriveComboBoxDriveComboBox1LeftTopAWidthqHeightDirListDirectoryListBox1TabOrder  TFilterComboBoxFilterComboBox1AlignWithMargins	LeftTop?Width? HeightFilter?LFD *.LFD|*.LFD|LFD Assets|*.DLT;*.PLT;*.ANM;*.FLM;*.FON;*.VOC;*.VOIC;*.GMD;*.GMID;*.TXT;*.TEXT;*.DLTT;*.PLTT;*.ANIM;*.FILM;*.FONT|All Files   *.*|*.*TabOrderOnChangeFSTextChange  TEditFileNameEditLeftTop]Width? HeightFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold 
ParentFontTabOrderText*.*
OnKeyPressFileNameEditKeyPress  TBitBtnLFDAddLeft?TopNWidthfHeight"Hint1Add File(s) | Add the selected file(s) to the LFDCaptionAddEnabled	NumGlyphsParentShowHintShowHint	TabOrder OnClickLFDAddClick  TBitBtn	LFDRemoveLeft?Top? WidtheHeight"Hint3Remove File(s)|Remove selected file(s) from the LFDCaptionRemove  Enabled	NumGlyphsParentShowHintShowHint	TabOrderOnClickLFDRemoveClick  TBitBtn
LFDExtractLeft?ToptWidthfHeight"HintNExtract File(s)|Extract selected file(s) from the LFD to the current directoryCaption  Extract  EnabledFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height?	Font.NameSystem
Font.Style 	NumGlyphs
ParentFontParentShowHintShowHint	TabOrderOnClickLFDExtractClick  TBitBtn	BNRefreshLeft?Top?WidthfHeight3HintGRefresh | Refresh the File System list in case of external modificationCaptionRefresh
File ListFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height?	Font.NameSystem
Font.Style 	NumGlyphs
ParentFontParentShowHintShowHint	TabOrder
OnClickBNRefreshClick  TFileListBoxFileListBox1LeftTopNWidth? Height$Hint4File System|File System (Right click for selections)DragModedmAutomaticFileEditFileNameEditFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold IntegralHeight	MultiSelect	
ParentFontParentShowHint	PopupMenuFSPopupMenuShowHint	TabOrderOnClickFileListBox1Change
OnDblClickFileListBox1Change
OnDragDropFileListBox1DragDrop
OnDragOverFileListBox1DragOver  TPanelPanelLFDNameLeftTop/Width?HeightHint2LFD Name | Name of the currently selected LFD file
BevelInner	bvLowered
BevelOuterbvNoneFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold 
ParentFontParentShowHintShowHint	TabOrderOnClickPanelLFDNameClick  TPanelPanelLFDEntriesLeft?Top? WidtheHeightHint?# Entries| Number of directory entries in the selected LFD file
BevelOuter	bvLoweredParentShowHintShowHint	TabOrder  TListBoxLFDHintListBoxLeftToptWidth?Height9Color	clBtnFaceExtendedSelectFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameSystem
Font.StylefsBold Items.StringsS************************    Hints for LFD Manager Use  ****************************    OThe LFD file entries are in the large box on right side .The Working directory /files are displayed in the left hand large box.    #1 Create button  Creates a new LFD.(2 Delete button  Deletes an existing LFDB3 Info button  displays the information for the selected LFD file.24 Add button  adds the selected file(s) to the LFDI5.Extract button extracts the selected file(s) to the selected directory.:6.Remove button  removes the selected file(s) from the LFDN7.Mouse right button in either File listing box will bring up a selection menuT8. You can drag & drop files between File listing boxes with your mouse left button.U ************************   Opening  a LFD   *************************************** L1. Use the small file folder button on right to open a lfd file to work withV*************************   Selecting a directory    **********************************1. Use drive selction  to selct disk drive)2. Select directory you want to work with13. Refresh button updates the file listing box .  
ParentFontTabOrder  TRadioGroupRadioGroup1Left?Top? WidtheHeight9Caption     ColorsItems.StringsNoneNormalDarker TabOrderOnClickRadioGroup1Click  	TCheckBoxLFDChkBxLeft?Top(WidtheHeightCaption	Hide TextTabOrderOnClickLFDChkBxClick  TBitBtnLFDCancelBtnLeft?Top?WidthLHeightMargins.LeftMargins.TopMargins.RightMargins.BottomFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameMS Sans Serif
Font.StylefsBold KindbkCancelMargin	NumGlyphs
ParentFontSpacing?TabOrderOnClickLFDCancelBtnClick  TBitBtnLFDOKBtnLeft?Top?WidthNHeightMargins.LeftMargins.TopMargins.RightMargins.BottomFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height?	Font.NameMS Sans Serif
Font.StylefsBold KindbkOKMargin	NumGlyphs
ParentFontSpacing?TabOrderOnClickLFDOKBtnClick  TOpenDialogLFDBrowseLFD
DefaultExtlfdFileName*.lfdFilterLFD Files (*.LFD)|*.lfdOptionsofHideReadOnlyofPathMustExistofFileMustExist TitleChoose LFD fileLeft?Top  TSaveDialogLFDCreateSaveDialog
DefaultExtlfdFileName*.lfdFilterLFD Files (*.LFD)|*.LFDOptionsofOverwritePromptofHideReadOnlyofAllowMultiSelectofPathMustExistofNoReadOnlyReturn TitleCreate LFD fileLeft?Top  
TPopupMenuFSPopupMenuLefthTop 	TMenuItem
SelectAll1Caption
Select AllHintSelect All filesOnClickSelectAll1Click  	TMenuItemDeselectAll1CaptionDeSelect AllHintDeselect All filesOnClickDeselectAll1Click  	TMenuItemInvertSelection1CaptionInvert SelectionOnClickInvertSelection1Click  	TMenuItemN2Caption-  	TMenuItem
SelectANM1CaptionSelect *.ANMOnClickSelectANM1Click  	TMenuItem
SelectDLT1CaptionSelect *.DLTOnClickSelectANM1Click  	TMenuItem
SelectFLM1CaptionSelect *.FLMOnClickSelectANM1Click  	TMenuItem
SelectFNT1CaptionSelect *.FONOnClickSelectANM1Click  	TMenuItem
SelectGMD1CaptionSelect *.GMDOnClickSelectANM1Click  	TMenuItem
SelectPLT1CaptionSelect *.PLTOnClickSelectANM1Click  	TMenuItem
SelectTXT1CaptionSelect *.TXTOnClickSelectANM1Click  	TMenuItem
SelectVOC1CaptionSelect *.VOCOnClickSelectANM1Click   
TPopupMenuLFDPopupMenuLeftHTop 	TMenuItem
SelectAll2Caption
Select AllHintSelect All filesOnClickSelectAll2Click  	TMenuItemDeSelectAll2CaptionDeSelect AllHintDeselect All filesOnClickDeSelectAll2Click  	TMenuItemInvertSelection2CaptionInvert SelectionOnClickInvertSelection2Click  	TMenuItem	MenuItem3Caption-  	TMenuItemSelectANIM1CaptionSelect ANIM*OnClickSelectANIM1Click  	TMenuItemSelectDELT1CaptionSelect DELT*OnClickSelectANIM1Click  	TMenuItemSelectFILM1CaptionSelect FILM*OnClickSelectANIM1Click  	TMenuItemSelectFONT1CaptionSelect FONT*OnClickSelectANIM1Click  	TMenuItemSelectGMID1CaptionSelect GMID*OnClickSelectANIM1Click  	TMenuItemSelectPLTT1CaptionSelect PLTT*OnClickSelectANIM1Click  	TMenuItemSelectTEXT1CaptionSelect TEXT*OnClickSelectANIM1Click  	TMenuItemSelectVOIC1CaptionSelect VOIC*OnClickSelectANIM1Click    