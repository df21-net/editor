{**************************************************}
{                                                  }
{   _STRINGS UNIT : supplementary String functions }
{                                                  }
{   Copyright (c) 1993-1995 by Yves BORCKMANS      }
{                                                  }
{**************************************************}

unit _strings;

interface
uses SysUtils, Classes;

Function LTrim (AString : String) : String;
Function RTrim (AString : String) : String;
Function Trim  (AString : String) : String;
Function Spaces(TotLen : Integer) : String;
Function LPad  (AString : String; TotLen : Integer) : String;
Function RPad  (AString : String; TotLen : Integer) : String;
Function IsWhiteSpace(AChar : Char) : Boolean;

TYPE
  TStringParser = class(TStringList)
    constructor Create(AString : String);
  end;

  TStringParserWithColon = class(TStringList)
    constructor Create(AString : String);
  end;


implementation

Function LTrim(AString : String) : String;
var i      : Integer;
    getout : Boolean;
begin
  getout := FALSE;
  if AString = '' then
    LTrim := ''
  else
    begin
      i := 1;
      while (i <= Length(AString)) and not getout do
        if AString[i] = ' ' then
         Inc(i)
        else
         getout := TRUE;
      LTrim := Copy(AString, i, 999);
    end;
end;

Function RTrim(AString : String) : String;
var i      : Integer;
    getout : Boolean;
begin
  getout := FALSE;
  if AString = '' then
    RTrim := ''
  else
    begin
      i := Length(AString);
      while (i >= 1) and not getout do
        if AString[i] = ' ' then
         Dec(i)
        else
         getout := TRUE;
      RTrim := Copy(AString, 1, i);
    end;
end;

Function  Trim(AString : String) : String;
begin
  Trim := LTrim(RTrim(AString));
end;

Function Spaces(TotLen : Integer) : String;
var i : Integer;
begin
  Result := '';
  for i := 1 to TotLen do Result := Result + ' ';
end;

Function  LPad(AString : String; TotLen : Integer) : String;
begin
  if TotLen > 255 then TotLen := 255;
  if TotLen < Length(AString) then
    LPad := AString
  else
    LPad := Spaces(TotLen - Length(AString)) + AString;
end;

Function RPad  (AString : String; TotLen : Integer) : String;
begin
  if TotLen > 255 then TotLen := 255;
  if TotLen < Length(AString) then
    RPad := AString
  else
    RPad := AString + Spaces(TotLen - Length(AString));
end;

Function IsWhiteSpace(AChar : Char) : Boolean;
begin
  if (AChar = ' ') or
     (AChar = #9 ) or
     (AChar = #10) or
     (AChar = #13)
  then
    IsWhiteSpace := TRUE
  else
    IsWhiteSpace := FALSE;
end;

constructor TStringParser.Create(AString : string);
var i : Integer;
    s : String;
    w : Boolean;
begin
  inherited Create;
  {set the original string as item 0}
  Add(AString);
  {parse the string now}
  if AString <> '' then
    begin
     { w := IsWhiteSpace(AString[1]); 1new line below}
       w := AString[1] in [#10,#13,' ',#9];
      s := '';
      for i := 1 to Length(AString) do
        begin
          if w then
           { if not IsWhiteSpace(AString[i]) then }
             if not (AString[i] in [#10,#13,' ',#9]) then
              begin
                s := AString[i];
                w := FALSE;
              end
            else
          else
            {if IsWhiteSpace(AString[i]) then }
             if  (AString[i] in [#10,#13,' ',#9]) then
              begin
                Add(s);
                s := '';
                w := TRUE;
              end
            else
              begin
                s := s + AString[i];
              end;
        end;
      if s <> '' then Add(s); 
    end;
end;

constructor TStringParserWithColon.Create(AString : string);
var i : Integer;
    s : String;
    w : Boolean;
begin
  inherited Create;
  {set the original string as item 0}
  Add(AString);
  {parse the string now}
  if AString <> '' then
    begin
      w := AString[1] in [#10,#13,' ',#9];
      s := '';
      for i := 1 to Length(AString) do
        begin
          if w then
            if not (AString[i] in [#10,#13,' ',#9]) then
              begin
                s := AString[i];
                w := FALSE;
              end
            else
          else
            if (AString[i] in [#10,#13,' ',#9]) then
              begin
                Add(s);
                s := '';
                w := TRUE;
              end
            else
              begin
                s := s + AString[i];
                if Astring[i] = ':' then
                 if i + 1 < Length(AString) then
                   if not (AString[i+1] in [#10,#13,' ',#9]) then
                   begin
                    Add(s);
                    s := '';
                   end;
              end;
        end;
      if s <> '' then Add(s);
    end;
end;


{Initialization part}
begin
end.
