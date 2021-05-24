{**************************************************}
{                                                  }
{   _UNDOC   UNIT : undocumented Windows functions }
{                                                  }
{   Copyright (c) 1993-1995 by Yves BORCKMANS      }
{                                                  }
{**************************************************}
{  This unit must be tested with Windows95 !!!     }
{**************************************************}

UNIT _undoc;

interface

USES  WinTypes;

{$IFNDEF WDF32}
PROCEDURE UNDOCWIN_SwitchToThisWindow(HWindow : HWnd ; Restore : Bool);
FUNCTION  UNDOCWIN_GetHeapSpaces     (HModule : THandle) : LongInt;
FUNCTION  NODELPHI_hread(hf : Integer; buf : Pointer; cb : LongInt) : LongInt;
FUNCTION  NODELPHI_hwrite(hf : Integer; buf : Pointer; cb : LongInt) : LongInt;
{$ELSE}
{$ENDIF}

implementation

{$IFNDEF WDF32}
PROCEDURE UNDOCWIN_SwitchToThisWindow;   external 'USER'    {index 172} name 'SWITCHTOTHISWINDOW';
FUNCTION  UNDOCWIN_GetHeapSpaces;        external 'KERNEL'  {index 138} name 'GETHEAPSPACES';
FUNCTION  NODELPHI_hread;                external 'KERNEL'  {index ???} name '_HREAD';
FUNCTION  NODELPHI_hwrite;               external 'KERNEL'  {index ???} name '_HWRITE';
{$ELSE}
{$ENDIF}

{Initialization part}
BEGIN
END.