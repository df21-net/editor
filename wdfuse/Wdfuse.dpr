program Wdfuse;

uses
  Forms,
  Mapper in 'MAPPER.PAS' {MapWindow},
  M_global in 'M_GLOBAL.PAS',
  _math in '_MATH.PAS',
  _files in '_FILES.PAS',
  _strings in '_STRINGS.PAS',
  _undoc in '_UNDOC.PAS',
  C_util in 'C_UTIL.PAS',
  V_util in 'V_UTIL.PAS',
  R_util in 'R_UTIL.PAS',
  W_util in 'W_UTIL.PAS',
  M_io in 'M_IO.PAS',
  M_progrs in 'M_PROGRS.PAS' {ProgressWindow},
  M_util in 'M_UTIL.PAS',
  M_wledit in 'M_WLEDIT.PAS' {WallEditor},
  M_obedit in 'M_OBEDIT.PAS' {ObjectEditor},
  M_scedit in 'M_SCEDIT.PAS' {SectorEditor},
  M_newwdp in 'M_NEWWDP.PAS' {NewProjectDialog},
  M_flaged in 'M_FLAGED.PAS' {FlagEditor},
  M_editor in 'M_EDITOR.PAS',
  M_vxedit in 'M_VXEDIT.PAS' {VertexEditor},
  M_stat in 'M_STAT.PAS' {StatWindow},
  M_maput in 'M_MAPUT.PAS',
  M_option in 'M_OPTION.PAS' {OptionsDialog},
  M_find in 'M_FIND.PAS' {FindWindow},
  M_smledt in 'M_SMLEDT.PAS' {SmallTextEditor},
  M_multi in 'M_MULTI.PAS',
  M_resour in 'M_RESOUR.PAS' {ResourcePicker},
  M_obclas in 'M_OBCLAS.PAS' {OBClassWindow},
  M_obseq in 'M_OBSEQ.PAS' {OBSeqPicker},
  M_obsel in 'M_OBSEL.PAS' {OBSelector},
  M_tools in 'M_TOOLS.PAS' {ToolsWindow},
  M_mapfun in 'M_MAPFUN.PAS',
  M_diff in 'M_DIFF.PAS' {DIFFEditor},
  M_checks in 'M_CHECKS.PAS' {ChecksWindow},
  M_extern in 'M_EXTERN.PAS' {ExtToolsWindow},
  Gobdir in 'GOBDIR.PAS' {GOBDIRWindow},
  Gobs in 'GOBS.PAS' {GOBWindow},
  M_about in 'M_ABOUT.PAS' {AboutBox},
  L_util in 'L_UTIL.PAS',
  Lfddir in 'LFDDIR.PAS' {LFDDIRWindow},
  Lfds in 'LFDS.PAS' {LFDWindow},
  Toolkit in 'TOOLKIT.PAS' {TktWindow},
  T_info in 'T_INFO.PAS' {TktInfoWindow},
  T_convrt in 'T_CONVRT.PAS' {ConvertWindow},
  T_palopt in 'T_PALOPT.PAS' {TktPalette},
  M_wads in 'M_WADS.PAS',
  M_wadsut in 'M_WADSUT.PAS',
  m_WadMap in 'M_WADMAP.PAS' {MapSelectWindow},
  M_leved in 'M_LEVED.PAS' {LevelEditorWindow},
  M_query in 'M_QUERY.PAS' {QueryWindow},
  M_regist in 'M_REGIST.PAS' {RegisterWindow},
  Goledit in 'GOLEDIT.PAS' {GOLWindow},
  M_test in 'M_TEST.PAS' {TestWindow},
  I_util in 'I_UTIL.PAS',
  Infedit2 in 'INFEDIT2.PAS' {INFWindow2},
  M_duke in 'M_DUKE.PAS' {DukeConvertWindow},
  DFFiles in 'DFFILES.PAS',
  Render in 'RENDER.PAS' {Renderer},
  Stitch in 'STITCH.PAS',
  M_motif in 'M_MOTIF.PAS' {MotifWindow},
  _3d in '_3D.PAS',
  _3dmath in '_3DMATH.PAS',
  _3dpoly in '_3DPOLY.PAS',
  M_key in 'M_KEY.PAS' {AllKeys},
  vuecreat in 'VUECREAT.PAS' {VUECreator},
  vue_clr in 'VUE_CLR.PAS' {VUEClearWindow},
  vue_fldn in 'VUE_FLDN.PAS' {VUEFillDownWindow},
  vue_offs in 'VUE_OFFS.PAS' {VUEOffsetWindow},
  VUE_util in 'VUE_UTIL.PAS',
  Asc3do in 'ASC3DO.PAS' {ASCto3DOWindow},
  _conv3do in '_CONV3DO.PAS' {3doOptionWindow},
  _3doCNV in '_3DOCNV.PAS',
  _3dotasc in '_3DOTASC.PAS' {CNV3do2ascWindow};

{$R *.RES}

begin
  Application.Title := 'WDFUSE';
  Application.HelpFile := 'WDFUSE.HLP';
  Application.CreateForm(TMapWindow, MapWindow);
  Application.CreateForm(TProgressWindow, ProgressWindow);
  Application.CreateForm(TWallEditor, WallEditor);
  Application.CreateForm(TObjectEditor, ObjectEditor);
  Application.CreateForm(TSectorEditor, SectorEditor);
  Application.CreateForm(TNewProjectDialog, NewProjectDialog);
  Application.CreateForm(TFlagEditor, FlagEditor);
  Application.CreateForm(TVertexEditor, VertexEditor);
  Application.CreateForm(TOptionsDialog, OptionsDialog);
  Application.CreateForm(TResourcePicker, ResourcePicker);
  Application.CreateForm(TOBClassWindow, OBClassWindow);
  Application.CreateForm(TOBSeqPicker, OBSeqPicker);
  Application.CreateForm(TOBSelector, OBSelector);
  Application.CreateForm(TToolsWindow, ToolsWindow);
  Application.CreateForm(TDIFFEditor, DIFFEditor);
  Application.CreateForm(TMapSelectWindow, MapSelectWindow);
  Application.CreateForm(TGOLWindow, GOLWindow);
  Application.CreateForm(TTestWindow, TestWindow);
  Application.CreateForm(TINFWindow2, INFWindow2);
  Application.CreateForm(TDukeConvertWindow, DukeConvertWindow);
  Application.CreateForm(TChecksWindow, ChecksWindow);
  Application.CreateForm(TRenderer, Renderer);
  Application.CreateForm(TMotifWindow, MotifWindow);
  Application.CreateForm(TStatWindow, StatWindow);
  Application.CreateForm(TFindWindow, FindWindow);
  Application.CreateForm(TSmallTextEditor, SmallTextEditor);
  Application.CreateForm(TExtToolsWindow, ExtToolsWindow);
  Application.CreateForm(TGOBDIRWindow, GOBDIRWindow);
  Application.CreateForm(TGOBWindow, GOBWindow);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TLFDDIRWindow, LFDDIRWindow);
  Application.CreateForm(TLFDWindow, LFDWindow);
  Application.CreateForm(TTktWindow, TktWindow);
  Application.CreateForm(TTktInfoWindow, TktInfoWindow);
  Application.CreateForm(TConvertWindow, ConvertWindow);
  Application.CreateForm(TTktPalette, TktPalette);
  Application.CreateForm(TLevelEditorWindow, LevelEditorWindow);
  Application.CreateForm(TQueryWindow, QueryWindow);
  Application.CreateForm(TRegisterWindow, RegisterWindow);
  Application.CreateForm(TAllKeys, AllKeys);
  Application.CreateForm(TVUECreator, VUECreator);
  Application.CreateForm(TVUEClearWindow, VUEClearWindow);
  Application.CreateForm(TVUEFillDownWindow, VUEFillDownWindow);
  Application.CreateForm(TVUEOffsetWindow, VUEOffsetWindow);
  Application.CreateForm(TASCto3DO, ASCto3DO);
  Application.CreateForm(TCONV3do, CONV3do);
  Application.CreateForm(TCNV3do2asc, CNV3do2asc);
  Mapper.DO_CheckTheGobs;
  Mapper.HandleCommandLine;
  Application.Run;
end.
