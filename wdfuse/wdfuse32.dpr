program Wdfuse32;



uses
  Forms,
  MAPPER in 'MAPPER.PAS' {MapWindow},
  M_GLOBAL in 'M_GLOBAL.PAS',
  _MATH in '_MATH.PAS',
  _FILES in '_FILES.PAS',
  _STRINGS in '_STRINGS.PAS',
  _UNDOC in '_UNDOC.PAS',
  R_UTIL in 'R_UTIL.PAS',
  W_UTIL in 'W_UTIL.PAS',
  M_IO in 'M_IO.PAS',
  M_PROGRS in 'M_PROGRS.PAS' {ProgressWindow},
  M_UTIL in 'M_UTIL.PAS',
  M_wledit in 'M_wledit.pas' {WallEditor},
  M_OBEDIT in 'M_OBEDIT.PAS' {ObjectEditor},
  M_scedit in 'M_scedit.pas' {SectorEditor},
  M_NEWWDP in 'M_NEWWDP.PAS' {NewProjectDialog},
  M_flaged in 'M_flaged.pas' {FlagEditor},
  M_EDITOR in 'M_EDITOR.PAS',
  M_VXEDIT in 'M_VXEDIT.PAS' {VertexEditor},
  M_STAT in 'M_STAT.PAS' {StatWindow},
  M_MAPUT in 'M_MAPUT.PAS',
  M_OPTION in 'M_OPTION.PAS' {OptionsDialog},
  M_find in 'M_find.pas' {FindWindow},
  M_SMLEDT in 'M_SMLEDT.PAS' {SmallTextEditor},
  M_MULTI in 'M_MULTI.PAS',
  M_resour in 'M_resour.pas' {ResourcePicker},
  M_OBCLAS in 'M_OBCLAS.PAS' {OBClassWindow},
  M_obseq in 'M_obseq.pas' {OBSeqPicker},
  M_obsel in 'M_obsel.pas' {OBSelector},
  M_tools in 'M_tools.pas' {ToolsWindow},
  M_MAPFUN in 'M_MAPFUN.PAS',
  M_Diff in 'M_Diff.pas' {DIFFEditor},
  M_Checks in 'M_Checks.pas' {ChecksWindow},
  m_extern in 'm_extern.pas' {ExtToolsWindow},
  GOBDIR in 'GOBDIR.PAS' {GOBDIRWindow},
  Gobs in 'Gobs.pas' {GOBWindow},
  M_about in 'M_about.pas' {AboutBox},
  L_UTIL in 'L_UTIL.PAS',
  LFDDIR in 'LFDDIR.PAS' {LFDDIRWindow},
  LFDS in 'LFDS.PAS' {LFDWindow},
  T_INFO in 'T_INFO.PAS' {TktInfoWindow},
  T_CONVRT in 'T_CONVRT.PAS' {ConvertWindow},
  T_PALOPT in 'T_PALOPT.PAS' {TktPalette},
  M_WADS in 'M_WADS.PAS',
  M_WADSUT in 'M_WADSUT.PAS',
  M_WADMAP in 'M_WADMAP.PAS' {MapSelectWindow},
  m_leved in 'm_leved.pas' {LevelEditorWindow},
  M_QUERY in 'M_QUERY.PAS' {QueryWindow},
  M_REGIST in 'M_REGIST.PAS' {RegisterWindow},
  C_UTIL32 in 'C_UTIL32.PAS',
  v_util32 in 'v_util32.pas',
  M_test in 'M_test.pas' {TestWindow},
  i_util in 'i_util.pas',
  infedit2 in 'infedit2.pas' {INFWindow2},
  D_Util in 'D_Util.pas',
  m_duke in 'm_duke.pas' {DukeConvertWindow},
  render in 'render.pas' {Renderer},
  stitch in 'stitch.pas',
  ZRender in 'ZRender.pas' {ZRenderer},
  _3d in '_3d.pas',
  _3dmath in '_3dmath.pas',
  CNVEDIT in 'CNVEDIT.pas' {CNV_edit},
  df2art in 'df2art.pas',
  DFFiles in 'DFFiles.pas',
  _3doCNV in '_3doCNV.pas',
  M_key in 'M_key.pas' {AllKeys},
  toolkit in 'toolkit.pas' {TktWindow},
  G_Util in 'G_Util.pas',
  Vuecreat in 'Vuecreat.pas' {VUECreator},
  _conv3do in '_conv3do.pas' {CONV3do},
  Jsons in 'json\Jsons.pas',
  JsonsUtilsEx in 'json\JsonsUtilsEx.pas',
  LoggerPro.ConsoleAppender in 'logger\LoggerPro.ConsoleAppender.pas',
  LoggerPro.ElasticSearchAppender in 'logger\LoggerPro.ElasticSearchAppender.pas',
  LoggerPro.EMailAppender in 'logger\LoggerPro.EMailAppender.pas',
  LoggerPro.FileAppender in 'logger\LoggerPro.FileAppender.pas',
  LoggerPro.GlobalLogger in 'logger\LoggerPro.GlobalLogger.pas',
  LoggerPro.MemoryAppender in 'logger\LoggerPro.MemoryAppender.pas',
  LoggerPro.NSQAppender in 'logger\LoggerPro.NSQAppender.pas',
  LoggerPro.OutputDebugStringAppender in 'logger\LoggerPro.OutputDebugStringAppender.pas',
  LoggerPro in 'logger\LoggerPro.pas',
  LoggerPro.Proxy in 'logger\LoggerPro.Proxy.pas',
  LoggerPro.RESTAppender in 'logger\LoggerPro.RESTAppender.pas',
  LoggerPro.UDPSyslogAppender in 'logger\LoggerPro.UDPSyslogAppender.pas',
  LoggerPro.Utils in 'logger\LoggerPro.Utils.pas',
  LoggerPro.VCLListViewAppender in 'logger\LoggerPro.VCLListViewAppender.pas',
  LoggerPro.VCLMemoAppender in 'logger\LoggerPro.VCLMemoAppender.pas',
  ThreadSafeQueueU in 'logger\ThreadSafeQueueU.pas';

{$R *.RES}

begin
  Application.Title := 'WDFUSE32';
  Application.HelpFile := 'WDFUSE.HLP';
  Application.CreateForm(TMapWindow, MapWindow);
  Application.CreateForm(TProgressWindow, ProgressWindow);
  Application.CreateForm(TSectorEditor, SectorEditor);
  Application.CreateForm(TWallEditor, WallEditor);
  Application.CreateForm(TObjectEditor, ObjectEditor);
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
  Application.CreateForm(TAllKeys, AllKeys);
  Application.CreateForm(TTktWindow, TktWindow);
  Application.CreateForm(TVUECreator, VUECreator);
  Application.CreateForm(TCONV3do, CONV3do);
  Application.CreateForm(TGOBWindow, GOBWindow);
  Mapper.DO_CheckTheGobs;
  Mapper.HandleCommandLine;
  Application.Run;
end.
