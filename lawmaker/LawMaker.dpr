program LawMaker;

uses
  Forms,
  FileDialogs in 'FileDialogs.pas' {GetFileOpen},
  Files in 'Files.pas',
  Unit1 in 'Unit1.pas' {Form1},
  FileOperations in 'FileOperations.pas',
  ContManager in 'ContManager.pas' {ConMan},
  ProgressDialog in 'ProgressDialog.pas' {Progress},
  misc_utils in 'misc_utils.pas',
  Images in 'Images.pas',
  DragOut in 'DragOut.pas',
  DragIn in 'DragIn.pas',
  Containers in 'Containers.pas',
  Level in 'Level.pas',
  Mapper in 'Mapper.pas' {MapWindow},
  GlobalVars in 'GlobalVars.pas',
  MsgWindow in 'MsgWindow.pas' {MsgForm},
  M_about in 'M_about.pas' {AboutBox},
  Level_Utils in 'Level_Utils.pas',
  MultiSelection in 'MultiSelection.pas',
  M_scedit in 'M_scedit.pas' {SectorEditor},
  FieldEdit in 'FieldEdit.pas',
  M_obedit in 'M_obedit.pas' {ObjectEditor},
  M_vxedit in 'M_vxedit.pas' {VertexEditor},
  M_wledit in 'M_wledit.pas' {WallEditor},
  ResourcePicker in 'ResourcePicker.pas' {ResPicker},
  U_Options in 'U_Options.pas' {Options},
  FlagEditor in 'FlagEditor.pas' {FlagEdit},
  AboutCntMan in 'AboutCntMan.pas' {AboutContMan},
  Cons_checker in 'Cons_checker.pas' {Consistency},
  Q_Utils in 'Q_Utils.pas',
  Q_Walls in 'Q_Walls.pas' {FindWalls},
  Q_Objects in 'Q_Objects.pas' {FindObjects},
  Q_Sectors in 'Q_Sectors.pas' {FindSectors},
  M_tools in 'M_tools.pas' {ToolsWindow},
  LHEdit in 'LHEdit.pas' {LHEditor},
  M_stat in 'M_stat.pas' {StatWindow},
  Preview in 'Preview.pas',
  graph_files in 'graph_files.pas',
  CopyPaste in 'CopyPaste.pas',
  NWX in 'NWX.pas',
  Stitch in 'Stitch.pas',
  LECScripts in 'LECScripts.pas' {ScriptEdit},
  Olh_Oll in 'Olh_Oll.pas',
  Mission_edit in 'Mission_edit.pas' {MissionEdit},
  MsgPick in 'MsgPick.pas' {MsgPicker};

{$R *.RES}
{$R VER_INFO.RES}

begin
  Application.Initialize;
  Application.HelpFile := 'Lawmaker.hlp';
  Application.CreateForm(TMapWindow, MapWindow);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TOptions, Options);
  Application.CreateForm(TGetFileOpen, GetFileOpen);
  Application.CreateForm(TConMan, ConMan);
  Application.CreateForm(TProgress, Progress);
  Application.CreateForm(TMsgForm, MsgForm);
  Application.CreateForm(TResPicker, ResPicker);
  Application.CreateForm(TFlagEdit, FlagEdit);
  Application.CreateForm(TAboutContMan, AboutContMan);
  Application.CreateForm(TLHEditor, LHEditor);
  Application.CreateForm(TStatWindow, StatWindow);
  Application.CreateForm(TScriptEdit, ScriptEdit);
  Application.CreateForm(TMissionEdit, MissionEdit);
  Application.CreateForm(TMsgPicker, MsgPicker);
  Application.Run;
end.
