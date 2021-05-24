program Wdfuse32;

uses
  Forms,
  Mapper in 'MAPPER.PAS' {MapWindow},
  M_global in 'M_GLOBAL.PAS',
  _math in '_MATH.PAS',
  _files in '_FILES.PAS',
  _strings in '_STRINGS.PAS',
  _undoc in '_UNDOC.PAS',
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
  C_util32 in 'C_UTIL32.PAS',
  V_util32 in 'V_UTIL32.PAS',
  M_test in 'M_Test.pas' {TestWindow},
  I_util in 'i_util.pas',
  Infedit2 in 'infedit2.pas' {INFWindow2},
  D_util in 'D_Util.pas',
  M_duke in 'm_duke.pas' {DukeConvertWindow},
  render in 'render.pas' {Renderer},
  Stitch in 'stitch.pas',
  ZRender in 'ZRender.pas' {ZRenderer},
  _3d in '_3d.pas',
  _3dmath in '_3dmath.pas',
  CNVEdit in 'CNVEDIT.pas' {CNV_edit},
  df2art in 'df2art.pas',
  DFFiles in 'DFFiles.pas',
  _3doCNV in '_3doCNV.pas';

{$R *.RES}

begin
  Application.Title := 'WDFUSE32';
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
  Application.CreateForm(TTestWindow, TestWindow);
  Application.CreateForm(TINFWindow2, INFWindow2);
  Application.CreateForm(TDukeConvertWindow, DukeConvertWindow);
  Application.CreateForm(TChecksWindow, ChecksWindow);
  Application.CreateForm(TRenderer, Renderer);
  Application.CreateForm(TZRenderer, ZRenderer);
  Application.CreateForm(TCNV_edit, CNV_edit);
  Mapper.DO_CheckTheGobs;
  Mapper.HandleCommandLine;
  Application.Run;
end.
